import Foundation

public protocol LanguageAIService: Sendable {
    func availability(for languageCode: String) async -> AIAvailability

    func explainSimply(
        entry: WordEntry,
        senseID: String,
        context: AIContext
    ) async throws -> SimpleExplanation

    func explainInUserLanguage(
        entry: WordEntry,
        senseID: String,
        context: AIContext
    ) async throws -> LocalizedExplanation

    func generateExamples(
        entry: WordEntry,
        senseID: String,
        context: AIContext,
        count: Int
    ) async throws -> [GeneratedExample]

    func compareWords(
        words: [WordEntry],
        context: AIContext
    ) async throws -> WordComparison

    func improveSentence(
        sentence: String,
        contextWord: WordEntry?,
        context: AIContext
    ) async throws -> SentenceFeedback

    func generateQuiz(
        words: [WordEntry],
        context: AIContext
    ) async throws -> QuizSession
}
