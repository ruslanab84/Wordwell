#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// Apple on-device model implementation of all learning AI contracts.
/// Wrap it in `ResilientLearningAI` for validation, caching and fallback.
@available(iOS 26.0, macOS 26.0, *)
public final class FoundationModelsLearningAI: LearningAI {
    public let identifier = "apple.on-device"
    public var promptVersion: String { AIPrompts.version }

    private let dictionary: any AIDictionaryLookup
    private let prompts: PromptBuilder
    private let assembler = QuizAssembler()
    private let warmer = SessionWarmer()

    public init(dictionary: any AIDictionaryLookup, prompts: PromptBuilder = PromptBuilder()) {
        self.dictionary = dictionary
        self.prompts = prompts
    }

    // MARK: - AIProvider

    public func availability(languageCode: String?) async -> AIAvailability {
        FMAvailability.current(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {
        guard FMAvailability.current(languageCode: nil).isAvailable, !Self.toolTasks.contains(task) else { return }
        await warmer.prewarm(task)
    }

    // MARK: - LanguageAIService

    public func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async throws -> SimpleExplanation {
        let prompt = await prompts.explain(word, learner: learner, languageCode: languageCode)
        return try await generate(.explain, prompt: prompt, languageCode: languageCode, as: GExplanation.self)
            .domain(languageCode: languageCode)
    }

    public func explanationStream(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) -> AsyncThrowingStream<ExplanationDraft, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try FMAvailability.require(languageCode: languageCode)
                    let prompt = await self.prompts.explain(word, learner: learner, languageCode: languageCode)
                    let session = await self.makeSession(for: .explain)
                    let stream = session.streamResponse(to: prompt, generating: GExplanation.self,
                                                        options: AIPrompts.options(for: .explain))
                    var latest = ExplanationDraft()
                    for try await snapshot in stream {
                        latest = snapshot.content.draft
                        continuation.yield(latest)
                    }
                    latest.isComplete = true
                    continuation.yield(latest)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: FMErrorMapper.map(error))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func examples(for word: AIWordContext, learner: LearnerProfile, count: Int) async throws -> [ExampleSentence] {
        let prompt = await prompts.examples(word, learner: learner, count: count)
        return try await generate(.examples, prompt: prompt, as: GExamples.self)
            .sentences.map { ExampleSentence(text: $0.text, senseID: $0.senseID) }
    }

    public func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async throws -> WordComparison {
        let prompt = await prompts.compare(first, second, learner: learner)
        return try await generate(.compare, prompt: prompt, as: GComparison.self)
            .domain(first: first.lemma, second: second.lemma)
    }

    public func commonMistakes(for word: AIWordContext, learner: LearnerProfile) async throws -> [CommonMistake] {
        let prompt = await prompts.commonMistakes(word, learner: learner)
        return try await generate(.commonMistakes, prompt: prompt, as: GMistakes.self)
            .mistakes.map { CommonMistake(incorrect: $0.incorrect, correct: $0.correct, explanation: $0.explanation) }
    }

    public func quiz(for word: AIWordContext, distractors: [String], learner: LearnerProfile, questionCount: Int) async throws -> WordQuiz {
        let count = min(max(questionCount, 1), 5)
        // One spare sentence absorbs validation losses without a second generation.
        let prompt = await prompts.gapSentences(word, learner: learner, count: count + 1)
        let generated = try await generate(.quiz, prompt: prompt, as: GGapSentences.self)
        return assembler.assemble(word: word, sentences: generated.sentences,
                                  distractors: distractors, questionCount: count)
    }

    public func improve(sentence: String, target: AIWordContext?, learner: LearnerProfile) async throws -> SentenceImprovement {
        let prompt = await prompts.improve(sentence, target: target, learner: learner)
        let generated = try await generate(.improveSentence, prompt: prompt, tools: [lookupTool], as: GImprovement.self)
        return SentenceImprovement(original: sentence, corrected: generated.corrected,
                                   issues: generated.issues.map(\.domain))
    }

    // MARK: - SpeakingFeedbackService

    public func speakingPrompt(targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingPrompt {
        let prompt = await prompts.speakingPrompt(targetWords, learner: learner)
        let generated = try await generate(.speakingPrompt, prompt: prompt, as: GSpeakingPrompt.self)
        return SpeakingPrompt(topic: generated.topic, guidingQuestions: generated.guidingQuestions,
                              targetWords: targetWords.map(\.lemma))
    }

    public func feedback(transcript: String, prompt: SpeakingPrompt, targetWords: [AIWordContext], learner: LearnerProfile) async throws -> SpeakingFeedback {
        let text = await prompts.speakingFeedback(transcript: transcript, prompt: prompt, words: targetWords, learner: learner)
        let generated = try await generate(.speakingFeedback, prompt: text, tools: [lookupTool], as: GSpeakingFeedback.self)

        // Target word usage is measured deterministically, not reported by the model.
        let used = targetWords.filter { FormMatcher.contains($0.allForms, in: transcript) }.map(\.lemma)
        let missed = targetWords.map(\.lemma).filter { !used.contains($0) }

        return SpeakingFeedback(summary: generated.summary, strengths: generated.strengths,
                                mistakes: generated.mistakes.map(\.domain), betterAnswer: generated.betterAnswer,
                                usedTargetWords: used, missedTargetWords: missed)
    }

    // MARK: - LearningInsightService

    public func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async throws -> WeeklyInsight {
        let prompt = await prompts.weeklyInsight(stats, learner: learner)
        let generated = try await generate(.weeklyInsight, prompt: prompt, as: GWeeklyInsight.self)
        return WeeklyInsight(headline: generated.headline, observation: generated.observation,
                             recommendation: generated.recommendation)
    }

    // MARK: - Engine

    private static let toolTasks: Set<AITask> = [.improveSentence, .speakingFeedback]

    private var lookupTool: LookupWordTool {
        LookupWordTool(dictionary: dictionary, prompts: prompts)
    }

    private func generate<T: Generable>(
        _ task: AITask,
        prompt: String,
        languageCode: String? = nil,
        tools: [any Tool] = [],
        as type: T.Type
    ) async throws -> T {
        do {
            try FMAvailability.require(languageCode: languageCode)
            let session: LanguageModelSession
            if tools.isEmpty {
                session = await makeSession(for: task)
            } else {
                session = LanguageModelSession(tools: tools, instructions: AIPrompts.instructions(for: task))
            }
            let response = try await session.respond(to: prompt, generating: T.self,
                                                     options: AIPrompts.options(for: task))
            return response.content
        } catch {
            throw FMErrorMapper.map(error)
        }
    }

    /// Prewarmed session if available, otherwise a fresh one. Never reused across requests.
    private func makeSession(for task: AITask) async -> LanguageModelSession {
        if let warm = await warmer.take(task) { return warm }
        return LanguageModelSession(instructions: AIPrompts.instructions(for: task))
    }
}
#endif
