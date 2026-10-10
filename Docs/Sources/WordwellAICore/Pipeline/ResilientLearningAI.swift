import Foundation

/// Decorator used by the app: input limits → cache → primary → validation → optional fallback → cache.
/// Features depend on `LearningAI`, never on a concrete model.
public final class ResilientLearningAI: LearningAI {
    public enum FallbackPolicy: Sendable {
        case disabled
        /// Use `fallback` when the primary fails with a recoverable error.
        /// Enable a cloud fallback only after explicit user consent.
        case whenPrimaryFails
    }

    public struct InputLimits: Sendable {
        public var maxSentenceLength = 400
        public var maxTranscriptLength = 2_500
        public init() {}
    }

    private let primary: any LearningAI
    private let fallback: (any LearningAI)?
    private let policy: FallbackPolicy
    private let cache: AIResponseCache?
    private let validator: AIResponseValidator
    private let limits: InputLimits

    public init(primary: any LearningAI,
                fallback: (any LearningAI)? = nil,
                policy: FallbackPolicy = .disabled,
                cache: AIResponseCache? = nil,
                validator: AIResponseValidator = AIResponseValidator(),
                limits: InputLimits = InputLimits()) {
        self.primary = primary
        self.fallback = fallback
        self.policy = policy
        self.cache = cache
        self.validator = validator
        self.limits = limits
    }

    public var identifier: String { "resilient(\(primary.identifier))" }
    public var promptVersion: String { primary.promptVersion }

    // MARK: - AIProvider

    public func availability(languageCode: String?) async -> AIAvailability {
        let primaryAvailability = await primary.availability(languageCode: languageCode)
        guard !primaryAvailability.isAvailable, policy == .whenPrimaryFails, let fallback else {
            return primaryAvailability
        }
        let fallbackAvailability = await fallback.availability(languageCode: languageCode)
        return fallbackAvailability.isAvailable ? .available : primaryAvailability
    }

    public func prewarm(for task: AITask) async {
        await primary.prewarm(for: task)
    }

    // MARK: - LanguageAIService

    public func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async throws -> SimpleExplanation {
        try await run(key(.explain, word.lemma, learner, languageCode, variant: contextKey(word))) {
            try await $0.explain(word, learner: learner, languageCode: languageCode)
        } validate: {
            try validator.validate($0, for: word)
        }
    }

    public func explanationStream(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) -> AsyncThrowingStream<ExplanationDraft, any Error> {
        let cacheKey = key(.explain, word.lemma, learner, languageCode, variant: contextKey(word))
        let primary = primary
        let cache = cache
        let validator = validator

        return AsyncThrowingStream { continuation in
            let task = Task {
                if let cached = await cache?.value(SimpleExplanation.self, for: cacheKey) {
                    continuation.yield(ExplanationDraft(senseID: cached.senseID, explanation: cached.explanation,
                                                        analogy: cached.analogy, examples: cached.examples, isComplete: true))
                    continuation.finish()
                    return
                }
                do {
                    var last: ExplanationDraft?
                    for try await draft in primary.explanationStream(word, learner: learner, languageCode: languageCode) {
                        last = draft
                        continuation.yield(draft)
                    }
                    if let last, last.isComplete, let text = last.explanation {
                        let final = try validator.validate(
                            SimpleExplanation(senseID: last.senseID, explanation: text, analogy: last.analogy,
                                              examples: last.examples, languageCode: languageCode),
                            for: word
                        )
                        continuation.yield(ExplanationDraft(senseID: final.senseID, explanation: final.explanation,
                                                            analogy: final.analogy, examples: final.examples, isComplete: true))
                        await cache?.store(final, for: cacheKey)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// Not cached: "More examples" should return fresh sentences on every tap.
    public func examples(for word: AIWordContext, learner: LearnerProfile, count: Int) async throws -> [ExampleSentence] {
        let clamped = min(max(count, 1), 5)
        return try await run(nil) {
            try await $0.examples(for: word, learner: learner, count: clamped)
        } validate: {
            try Array(validator.validate($0, for: word).prefix(clamped))
        }
    }

    public func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async throws -> WordComparison {
        let pair = [first.lemma, second.lemma].map { $0.lowercased() }.sorted()
        return try await run(key(.compare, pair[0], learner, variant: pair[1])) {
            try await $0.compare(first, second, learner: learner)
        } validate: {
            try validator.validate($0, first: first, second: second)
        }
    }

    public func commonMistakes(for word: AIWordContext, learner: LearnerProfile) async throws -> [CommonMistake] {
        try await run(key(.commonMistakes, word.lemma, learner, variant: contextKey(word))) {
            try await $0.commonMistakes(for: word, learner: learner)
        } validate: {
            try validator.validate($0, for: word)
        }
    }

    public func quiz(for word: AIWordContext, distractors: [String], learner: LearnerProfile, questionCount: Int) async throws -> WordQuiz {
        try await run(nil) {
            try await $0.quiz(for: word, distractors: distractors, learner: learner, questionCount: questionCount)
        } validate: {
            try validator.validate($0)
        }
    }

    public func improve(sentence: String, target: AIWordContext?, learner: LearnerProfile) async throws -> SentenceImprovement {
        guard sentence.count <= limits.maxSentenceLength else {
            throw AIError.inputTooLong(limit: limits.maxSentenceLength)
        }
        return try await run(nil) {
            try await $0.improve(sentence: sentence, target: target, learner: learner)
        } validate: {
            validator.validate($0)
        }
    }

    // MARK: - SpeakingFeedbackService

    public func speakingPrompt(targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingPrompt {
        try await run(nil) {
            try await $0.speakingPrompt(targetWords: targetWords, learner: learner)
        } validate: {
            guard $0.topic.nilIfBlank != nil, !$0.guidingQuestions.isEmpty else {
                throw AIError.invalidResponse("empty speaking prompt")
            }
            return $0
        }
    }

    public func feedback(transcript: String, prompt: SpeakingPrompt, targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingFeedback {
        let transcript = String(transcript.prefix(limits.maxTranscriptLength))
        return try await run(nil) {
            try await $0.feedback(transcript: transcript, prompt: prompt, targetWords: targetWords, learner: learner)
        } validate: {
            try validator.validate($0, transcript: transcript)
        }
    }

    // MARK: - LearningInsightService

    public func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async throws -> WeeklyInsight {
        try await run(nil) {
            try await $0.weeklyInsight(stats, learner: learner)
        } validate: {
            try validator.validate($0)
        }
    }

    // MARK: - Pipeline

    private func run<T: Codable & Sendable>(
        _ cacheKey: AICacheKey?,
        _ operation: (any LearningAI) async throws -> T,
        validate: (T) throws -> T
    ) async throws -> T {
        if let cacheKey, let cached = await cache?.value(T.self, for: cacheKey) {
            return cached
        }

        let result: T
        do {
            result = try validate(try await operation(primary))
        } catch let error as AIError where error.allowsFallback && policy == .whenPrimaryFails && fallback != nil {
            result = try validate(try await operation(fallback!))
        }

        if let cacheKey {
            await cache?.store(result, for: cacheKey)
        }
        return result
    }

    private func key(_ task: AITask, _ lemma: String, _ learner: LearnerProfile,
                     _ languageCode: String? = nil, variant: String = "") -> AICacheKey {
        AICacheKey(task: task, lemma: lemma, level: learner.level, languageCode: languageCode ?? learner.nativeLanguageCode,
                   promptVersion: promptVersion, variant: variant)
    }

    private func contextKey(_ word: AIWordContext) -> String {
        ([word.partOfSpeech] + word.senses.map(\.id)).joined(separator: ",")
    }
}
