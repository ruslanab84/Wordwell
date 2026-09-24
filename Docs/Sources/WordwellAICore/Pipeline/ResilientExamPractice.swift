import Foundation

/// Decorator for exam practice: input limits → primary → validation + restricted-terms policy.
/// Invalid material is regenerated up to `maxAttempts`; nothing unvalidated reaches the UI.
public final class ResilientExamPractice: ExamPracticeService {
    public struct InputLimits: Sendable {
        public var maxAnswerCharacters = 4_000
        public var questionCount = 3...6
        public init() {}
    }

    private let primary: any ExamPracticeService
    private let validator: ExamValidator
    private let limits: InputLimits
    private let maxAttempts: Int

    public init(primary: any ExamPracticeService, policy: RestrictedTermsPolicy,
                limits: InputLimits = InputLimits(), maxAttempts: Int = 2) {
        self.primary = primary
        self.validator = ExamValidator(policy: policy)
        self.limits = limits
        self.maxAttempts = max(1, maxAttempts)
    }

    public var identifier: String { "resilient-exam(\(primary.identifier))" }
    public var promptVersion: String { primary.promptVersion }

    public func availability(languageCode: String?) async -> AIAvailability {
        await primary.availability(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {
        await primary.prewarm(for: task)
    }

    public func speakingTask(part: SpeakingPart, topicHint: String?, learner: LearnerProfile) async throws -> ExamSpeakingTask {
        try await attempt {
            try await primary.speakingTask(part: part, topicHint: topicHint, learner: learner)
        } validate: {
            try validator.validate($0)
        }
    }

    public func writingTask(kind: WritingTaskKind, topicHint: String?, learner: LearnerProfile) async throws -> ExamWritingTask {
        try await attempt {
            try await primary.writingTask(kind: kind, topicHint: topicHint, learner: learner)
        } validate: {
            try validator.validate($0)
        }
    }

    public func readingSet(questionCount: Int, topicHint: String?, learner: LearnerProfile) async throws -> ExamReadingSet {
        let count = min(max(questionCount, limits.questionCount.lowerBound), limits.questionCount.upperBound)
        return try await attempt {
            try await primary.readingSet(questionCount: count, topicHint: topicHint, learner: learner)
        } validate: {
            try validator.validate($0, questionCount: count)
        }
    }

    public func assess(speakingTranscript: String, task: ExamSpeakingTask, learner: LearnerProfile) async throws -> ExamAssessment {
        let transcript = try checkedAnswer(speakingTranscript)
        return try await attempt {
            try await primary.assess(speakingTranscript: transcript, task: task, learner: learner)
        } validate: {
            try validator.validate($0, response: transcript, minimumWords: nil)
        }
    }

    public func assess(writing: String, task: ExamWritingTask, learner: LearnerProfile) async throws -> ExamAssessment {
        let answer = try checkedAnswer(writing)
        return try await attempt {
            try await primary.assess(writing: answer, task: task, learner: learner)
        } validate: {
            try validator.validate($0, response: answer, minimumWords: task.minimumWords)
        }
    }

    // MARK: - Pipeline

    private func checkedAnswer(_ text: String) throws -> String {
        let trimmed = text.trimmed
        guard !trimmed.isEmpty else { throw AIError.invalidResponse("empty answer") }
        guard trimmed.count <= limits.maxAnswerCharacters else {
            throw AIError.inputTooLong(limit: limits.maxAnswerCharacters)
        }
        return trimmed
    }

    private func attempt<T>(_ operation: () async throws -> T, validate: (T) throws -> T) async throws -> T {
        var lastError = AIError.invalidResponse("no attempts")
        for _ in 0..<maxAttempts {
            do {
                return try validate(try await operation())
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }
        throw lastError
    }
}
