import Foundation
import Testing
import WordwellAI
import WordwellDomain

private let entry = WordEntry(
    id: "word-1", word: "careful", lemma: "careful", partOfSpeech: .adjective,
    senses: [DefinitionSense(id: "sense-1", definition: "Avoiding mistakes or harm", examples: ["Be careful."])]
)
private let context = AIContext(profile: LearningProfile(
    cefrLevel: .b1, explanationLanguage: "en", preferredEnglishVariant: .both, dailyGoalMinutes: 10
))

@Test @MainActor func entryCoachShowsUnavailableFallback() async {
    let coach = EntryAICoach(service: NoAIService(reason: .modelNotReady))
    await coach.run(.explainSimply, entry: entry, senseID: "sense-1", context: context)
    #expect(coach.phase == .unavailable(.modelNotReady))
}

@Test @MainActor func entryCoachShowsGenerationError() async {
    let coach = EntryAICoach(service: TestAIService(mode: .failure))
    await coach.run(.explainSimply, entry: entry, senseID: "sense-1", context: context)
    #expect(coach.phase == .failed)
}

@Test @MainActor func entryCoachDiscardsCancelledGeneration() async {
    let coach = EntryAICoach(service: TestAIService(mode: .waitForCancellation))
    let request = Task { await coach.run(.explainSimply, entry: entry, senseID: "sense-1", context: context) }
    await Task.yield()
    request.cancel()
    await request.value
    #expect(coach.phase == .idle)
}

@Test @MainActor func entryCoachKeepsTypedSuccess() async {
    let coach = EntryAICoach(service: TestAIService(mode: .success))
    await coach.run(.explainSimply, entry: entry, senseID: "sense-1", context: context)
    #expect(coach.phase == .success(.simple(SimpleExplanation(senseID: "sense-1", text: "Take care to avoid mistakes."))))
}

private struct TestAIService: LanguageAIService {
    enum Mode: Sendable { case success, failure, waitForCancellation }
    let mode: Mode

    func availability(for languageCode: String) async -> AIAvailability { .available }

    func explainSimply(entry: WordEntry, senseID: String, context: AIContext) async throws -> SimpleExplanation {
        switch mode {
        case .success: return SimpleExplanation(senseID: senseID, text: "Take care to avoid mistakes.")
        case .failure: throw AIServiceError.generationFailed
        case .waitForCancellation:
            try await Task.sleep(for: .seconds(30))
            return SimpleExplanation(senseID: senseID, text: "Late response")
        }
    }

    func explainInUserLanguage(entry: WordEntry, senseID: String, context: AIContext) async throws -> LocalizedExplanation {
        throw AIServiceError.generationFailed
    }
    func generateExamples(entry: WordEntry, senseID: String, context: AIContext, count: Int) async throws -> [GeneratedExample] {
        throw AIServiceError.generationFailed
    }
    func compareWords(words: [WordEntry], context: AIContext) async throws -> WordComparison {
        throw AIServiceError.generationFailed
    }
    func improveSentence(sentence: String, contextWord: WordEntry?, context: AIContext) async throws -> SentenceFeedback {
        throw AIServiceError.generationFailed
    }
    func generateQuiz(words: [WordEntry], context: AIContext) async throws -> QuizSession {
        throw AIServiceError.generationFailed
    }
}
