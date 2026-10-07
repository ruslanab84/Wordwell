import Foundation

/// Decorator for conversation: input limits → primary → validation. Invalid output is regenerated
/// up to `maxAttempts`; nothing unvalidated reaches the UI. Never cached: turns are user-specific.
public final class ResilientConversation: ConversationService {
    public struct InputLimits: Sendable {
        public var maxTurnCharacters = 500
        public var maxTurns = ConversationScenario.maxLearnerTurns * 2 + 1
        public init() {}
    }

    private let primary: any ConversationService
    private let validator: ConversationValidator
    private let limits: InputLimits
    private let maxAttempts: Int

    public init(primary: any ConversationService, validator: ConversationValidator = ConversationValidator(),
                limits: InputLimits = InputLimits(), maxAttempts: Int = 2) {
        self.primary = primary
        self.validator = validator
        self.limits = limits
        self.maxAttempts = max(1, maxAttempts)
    }

    public var identifier: String { "resilient-conversation(\(primary.identifier))" }
    public var promptVersion: String { primary.promptVersion }

    public func availability(languageCode: String?) async -> AIAvailability {
        await primary.availability(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {
        await primary.prewarm(for: task)
    }

    public func reply(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationReply {
        try checked(turns)
        return try await attempt {
            try validator.validate(try await primary.reply(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner))
        }
    }

    public func summary(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationSummary {
        try checked(turns)
        return try await attempt {
            try validator.validate(try await primary.summary(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner), turns: turns)
        }
    }

    // MARK: - Pipeline

    private func checked(_ turns: [ConversationTurn]) throws {
        guard turns.contains(where: { $0.speaker == .learner }) else { throw AIError.invalidResponse("no learner turns") }
        guard turns.count <= limits.maxTurns else { throw AIError.contextOverflow }
        if turns.contains(where: { $0.speaker == .learner && $0.text.trimmed.count > limits.maxTurnCharacters }) {
            throw AIError.inputTooLong(limit: limits.maxTurnCharacters)
        }
    }

    private func attempt<T>(_ operation: () async throws -> T) async throws -> T {
        var lastError = AIError.invalidResponse("no attempts")
        for _ in 0..<maxAttempts {
            do {
                return try await operation()
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }
        throw lastError
    }
}
