import Foundation

/// Null provider: reports unavailability and never fabricates dialogue.
public struct UnavailableConversationService: ConversationService {
    public let reason: AIUnavailabilityReason
    public let identifier = "unavailable"
    public let promptVersion = "none"

    public init(reason: AIUnavailabilityReason) {
        self.reason = reason
    }

    public func availability(languageCode: String?) async -> AIAvailability { .unavailable(reason) }
    public func prewarm(for task: AITask) async {}

    public func reply(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationReply {
        throw AIError.unavailable(reason)
    }

    public func summary(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationSummary {
        throw AIError.unavailable(reason)
    }
}
