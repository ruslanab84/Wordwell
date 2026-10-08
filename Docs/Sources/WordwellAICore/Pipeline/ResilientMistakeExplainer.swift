import Foundation

/// Decorator: input check → primary → validation. Invalid output is regenerated up to `maxAttempts`.
/// Never cached: the explanation depends on the learner's level and chosen option.
public final class ResilientMistakeExplainer: MistakeExplainerService {
    public static let maxFieldCharacters = 600

    private let primary: any MistakeExplainerService
    private let validator: MistakeValidator
    private let maxAttempts: Int

    public init(primary: any MistakeExplainerService, validator: MistakeValidator = MistakeValidator(), maxAttempts: Int = 2) {
        self.primary = primary
        self.validator = validator
        self.maxAttempts = max(1, maxAttempts)
    }

    public var identifier: String { "resilient-mistake(\(primary.identifier))" }
    public var promptVersion: String { primary.promptVersion }

    public func availability(languageCode: String?) async -> AIAvailability {
        await primary.availability(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {
        await primary.prewarm(for: task)
    }

    public func explain(_ mistake: MistakeContext, learner: LearnerProfile) async throws -> MistakeExplanation {
        let chosen = mistake.chosen.trimmed
        let correct = mistake.correct.trimmed
        guard !chosen.isEmpty, !correct.isEmpty, chosen.normalizedForComparison != correct.normalizedForComparison else {
            throw AIError.invalidResponse("nothing to explain")
        }
        let fields = [mistake.topic, mistake.prompt, chosen, correct, mistake.fact]
        if fields.contains(where: { $0.trimmed.count > Self.maxFieldCharacters }) {
            throw AIError.inputTooLong(limit: Self.maxFieldCharacters)
        }

        var lastError = AIError.invalidResponse("no attempts")
        for _ in 0..<maxAttempts {
            do {
                return try validator.validate(try await primary.explain(mistake, learner: learner))
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }
        throw lastError
    }
}
