import Foundation

/// Null provider: used on unsupported devices/OS so features show a proper unavailable state.
public struct UnavailableLearningAI: LearningAI {
    public let reason: AIUnavailabilityReason
    public let identifier = "unavailable"
    public let promptVersion = "none"

    public init(reason: AIUnavailabilityReason) {
        self.reason = reason
    }

    public func availability(languageCode: String?) async -> AIAvailability { .unavailable(reason) }
    public func prewarm(for task: AITask) async {}

    public func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async throws -> SimpleExplanation { throw error }
    public func explanationStream(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) -> AsyncThrowingStream<ExplanationDraft, any Error> {
        AsyncThrowingStream { $0.finish(throwing: error) }
    }
    public func examples(for word: AIWordContext, learner: LearnerProfile, count: Int) async throws -> [ExampleSentence] { throw error }
    public func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async throws -> WordComparison { throw error }
    public func commonMistakes(for word: AIWordContext, learner: LearnerProfile) async throws -> [CommonMistake] { throw error }
    public func quiz(for word: AIWordContext, distractors: [String], learner: LearnerProfile, questionCount: Int) async throws -> WordQuiz { throw error }
    public func improve(sentence: String, target: AIWordContext?, learner: LearnerProfile) async throws -> SentenceImprovement { throw error }
    public func speakingPrompt(targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingPrompt { throw error }
    public func feedback(transcript: String, prompt: SpeakingPrompt, targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingFeedback { throw error }
    public func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async throws -> WeeklyInsight { throw error }

    private var error: AIError { .unavailable(reason) }
}
