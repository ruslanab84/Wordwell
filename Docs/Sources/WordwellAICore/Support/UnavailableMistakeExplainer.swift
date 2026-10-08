import Foundation

/// Null provider: reports unavailability and never fabricates an explanation.
public struct UnavailableMistakeExplainer: MistakeExplainerService {
    public let reason: AIUnavailabilityReason
    public let identifier = "unavailable"
    public let promptVersion = "none"

    public init(reason: AIUnavailabilityReason) {
        self.reason = reason
    }

    public func availability(languageCode: String?) async -> AIAvailability { .unavailable(reason) }
    public func prewarm(for task: AITask) async {}

    public func explain(_ mistake: MistakeContext, learner: LearnerProfile) async throws -> MistakeExplanation {
        throw AIError.unavailable(reason)
    }
}
