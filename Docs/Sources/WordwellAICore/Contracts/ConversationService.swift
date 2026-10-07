import Foundation

/// Scenario role-play. Separate from `LearningAI` so adding it never touches those conformers.
/// Turns are user-specific, so implementations must not cache.
public protocol ConversationService: AIProvider {
    /// The partner's next line. `turns` already contains the learner's latest message.
    func reply(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationReply
    func summary(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationSummary
}
