import WordwellDomain

public struct NoAIService: LanguageAIService {
    public let reason: AIUnavailableReason

    public init(reason: AIUnavailableReason = .notConfigured) {
        self.reason = reason
    }

    public func availability(for languageCode: String) async -> AIAvailability {
        .unavailable(reason)
    }

    public func explainSimply(
        entry: WordEntry,
        senseID: String,
        context: AIContext
    ) async throws -> SimpleExplanation {
        try unavailable()
    }

    public func explainInUserLanguage(
        entry: WordEntry,
        senseID: String,
        context: AIContext
    ) async throws -> LocalizedExplanation {
        try unavailable()
    }

    public func generateExamples(
        entry: WordEntry,
        senseID: String,
        context: AIContext,
        count: Int
    ) async throws -> [GeneratedExample] {
        try unavailable()
    }

    public func compareWords(
        words: [WordEntry],
        context: AIContext
    ) async throws -> WordComparison {
        try unavailable()
    }

    public func improveSentence(
        sentence: String,
        contextWord: WordEntry?,
        context: AIContext
    ) async throws -> SentenceFeedback {
        try unavailable()
    }

    public func generateQuiz(
        words: [WordEntry],
        context: AIContext
    ) async throws -> QuizSession {
        try unavailable()
    }

    private func unavailable<T>() throws -> T {
        throw AIServiceError.unavailable(reason)
    }
}
