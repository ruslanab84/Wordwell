#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// On-device scenario role-play. Always wrap in `ResilientConversation` (validation + regeneration).
@available(iOS 26.0, macOS 26.0, *)
public final class FoundationModelsConversation: ConversationService {
    public let identifier = "apple.on-device.conversation"
    public var promptVersion: String { ConversationPrompts.version }

    public init() {}

    public func availability(languageCode: String?) async -> AIAvailability {
        FMAvailability.current(languageCode: languageCode)
    }

    /// Instructions depend on the scenario, so there is nothing to prewarm by word task.
    public func prewarm(for task: AITask) async {}

    public func reply(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationReply {
        let generated = try await generate(
            .reply, scenario: scenario, as: GConversationReply.self,
            prompt: ConversationPrompts.replyPrompt(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner))
        return ConversationReply(text: generated.reply, objectiveMet: generated.objectiveMet)
    }

    public func summary(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationSummary {
        let generated = try await generate(
            .summary, scenario: scenario, as: GConversationSummary.self,
            prompt: ConversationPrompts.summaryPrompt(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner))
        return ConversationSummary(
            mistakes: generated.mistakes.map { ConversationMistake(original: $0.original, better: $0.better, why: $0.why) },
            expressions: generated.expressions,
            wordsToSave: generated.wordsToSave,
            objectiveMet: generated.objectiveMet)
    }

    // MARK: - Engine

    /// Fresh session per request: the transcript travels in the prompt (at most ~17 short turns).
    private func generate<T: Generable>(_ kind: ConversationPrompts.Kind, scenario: ConversationScenario, as type: T.Type, prompt: String) async throws -> T {
        do {
            try FMAvailability.require(languageCode: nil)
            let session = LanguageModelSession(instructions: ConversationPrompts.instructions(for: kind, scenario: scenario))
            return try await session.respond(to: prompt, generating: T.self, options: ConversationPrompts.options(for: kind)).content
        } catch {
            throw FMErrorMapper.map(error)
        }
    }
}
#endif
