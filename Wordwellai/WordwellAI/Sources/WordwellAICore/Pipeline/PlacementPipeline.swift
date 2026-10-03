import Foundation

/// Placement from a short written sample. Questions are fixed (`PlacementPrompts.standard`);
/// the model only assesses. Level, length rules and confidence are computed in code, conservatively.
public struct PlacementPipeline: Sendable {
    private let service: any PlacementService
    private let validator: ExamValidator
    private let maxAttempts: Int
    private let maxCharacters = 3_000

    public init(service: any PlacementService, policy: RestrictedTermsPolicy, maxAttempts: Int = 2) {
        self.service = service
        self.validator = ExamValidator(policy: policy)
        self.maxAttempts = max(1, maxAttempts)
    }

    public func assess(_ answers: [PlacementAnswer]) async throws -> PlacementResult {
        let cleaned = answers
            .prefix(PlacementPrompts.maxAnswers)
            .compactMap { answer in answer.text.nilIfBlank.map { PlacementAnswer(promptID: answer.promptID, text: $0) } }
        guard !cleaned.isEmpty else { throw AIError.invalidResponse("no answers") }
        guard cleaned.reduce(0, { $0 + $1.text.count }) <= maxCharacters else {
            throw AIError.inputTooLong(limit: maxCharacters)
        }

        let combined = cleaned.map(\.text).joined(separator: "\n\n")
        var lastError = AIError.invalidResponse("no attempts")

        for _ in 0..<maxAttempts {
            do {
                let raw = try await service.assess(answers: cleaned)
                let assessment = try validator.validate(raw, response: combined,
                                                        minimumWords: PlacementPrompts.minimumWords)
                return result(for: assessment, answers: cleaned)
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }
        throw lastError
    }

    private func result(for assessment: ExamAssessment, answers: [PlacementAnswer]) -> PlacementResult {
        let wellAnswered = answers.filter { WordCounter.count($0.text) >= 12 }.count

        var confidence: PlacementConfidence
        if assessment.wordCount >= 120, wellAnswered >= PlacementPrompts.standard.count {
            confidence = .high
        } else if assessment.wordCount >= PlacementPrompts.minimumWords {
            confidence = .medium
        } else {
            confidence = .low
        }

        // Uneven profile (e.g. fluent vocabulary, weak grammar): the estimate is less reliable.
        let levels = assessment.criteria.map { $0.level.index }
        if let highest = levels.max(), let lowest = levels.min(), highest - lowest >= 3 {
            confidence = confidence.lowered
        }

        // A short sample can never place a learner above B1.
        let overall = assessment.overallLevel
        let starting = confidence == .low ? min(overall, .b1) : overall
        return PlacementResult(assessment: assessment, startingLevel: starting, confidence: confidence,
                               cappedByConfidence: starting != overall)
    }
}
