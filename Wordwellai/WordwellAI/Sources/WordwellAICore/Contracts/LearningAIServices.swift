import Foundation

public protocol AIProvider: Sendable {
    /// Stable provider id, e.g. "apple.on-device".
    var identifier: String { get }
    /// Bumped on any prompt/schema change; part of every cache key.
    var promptVersion: String { get }

    func availability(languageCode: String?) async -> AIAvailability
    /// Call when a screen that will likely use `task` appears (e.g. Dictionary Entry → .explain).
    func prewarm(for task: AITask) async
}

/// Word-level AI features for Dictionary Entry, Library and Review.
public protocol LanguageAIService: AIProvider {
    func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async throws -> SimpleExplanation
    func explanationStream(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) -> AsyncThrowingStream<ExplanationDraft, any Error>
    func examples(for word: AIWordContext, learner: LearnerProfile, count: Int) async throws -> [ExampleSentence]
    func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async throws -> WordComparison
    func commonMistakes(for word: AIWordContext, learner: LearnerProfile) async throws -> [CommonMistake]
    /// Distractors come from the dictionary, never from the model.
    func quiz(for word: AIWordContext, distractors: [String], learner: LearnerProfile, questionCount: Int) async throws -> WordQuiz
    func improve(sentence: String, target: AIWordContext?, learner: LearnerProfile) async throws -> SentenceImprovement
}

public protocol SpeakingFeedbackService: AIProvider {
    func speakingPrompt(targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingPrompt
    /// `transcript` is speech-to-text output. Audio never reaches this layer.
    func feedback(transcript: String, prompt: SpeakingPrompt, targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingFeedback
}

public protocol LearningInsightService: AIProvider {
    func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async throws -> WeeklyInsight
}

public typealias LearningAI = LanguageAIService & SpeakingFeedbackService & LearningInsightService
