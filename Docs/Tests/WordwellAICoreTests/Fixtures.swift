import Foundation
@testable import WordwellAICore

enum Fixtures {
    static let decide = AIWordContext(
        lemma: "decide", partOfSpeech: "verb", cefrLevel: .b1,
        senses: [.init(id: "s1", definition: "to choose after thinking"), .init(id: "s2", definition: "to cause a result")],
        forms: ["decides", "decided", "deciding"]
    )
    static let learner = LearnerProfile(level: .b1)
}

/// Deterministic RNG for shuffle-dependent tests.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

actor CallCounter {
    private(set) var count = 0
    func increment() { count += 1 }
}

/// Minimal LearningAI stub: only `explain` is scripted, everything else throws.
struct StubLearningAI: LearningAI {
    let identifier: String
    let promptVersion = "test"
    let counter = CallCounter()
    let explainResult: @Sendable () throws -> SimpleExplanation
    var promptResult: @Sendable () throws -> SpeakingPrompt = { throw AIError.cancelled }
    var feedbackResult: @Sendable () throws -> SpeakingFeedback = { throw AIError.cancelled }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}

    func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async throws -> SimpleExplanation {
        await counter.increment()
        return try explainResult()
    }

    func explanationStream(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) -> AsyncThrowingStream<ExplanationDraft, any Error> {
        AsyncThrowingStream { $0.finish() }
    }
    func examples(for word: AIWordContext, learner: LearnerProfile, count: Int) async throws -> [ExampleSentence] { throw AIError.cancelled }
    func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async throws -> WordComparison { throw AIError.cancelled }
    func commonMistakes(for word: AIWordContext, learner: LearnerProfile) async throws -> [CommonMistake] { throw AIError.cancelled }
    func quiz(for word: AIWordContext, distractors: [String], learner: LearnerProfile, questionCount: Int) async throws -> WordQuiz { throw AIError.cancelled }
    func improve(sentence: String, target: AIWordContext?, learner: LearnerProfile) async throws -> SentenceImprovement { throw AIError.cancelled }
    func speakingPrompt(targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingPrompt {
        await counter.increment()
        return try promptResult()
    }
    func feedback(transcript: String, prompt: SpeakingPrompt, targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingFeedback {
        await counter.increment()
        return try feedbackResult()
    }
    func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async throws -> WeeklyInsight { throw AIError.cancelled }
}

extension SimpleExplanation {
    static let valid = SimpleExplanation(senseID: "s1", explanation: "You choose after thinking.", analogy: nil,
                                         examples: ["She decided to stay."], languageCode: nil)
}
