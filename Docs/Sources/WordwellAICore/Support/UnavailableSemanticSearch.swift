import Foundation

/// Null provider: reports unavailability and never fabricates words.
public struct UnavailableSemanticSearch: SemanticSearchService {
    public let reason: AIUnavailabilityReason
    public let identifier = "unavailable"
    public let promptVersion = "none"

    public init(reason: AIUnavailabilityReason) {
        self.reason = reason
    }

    public func availability(languageCode: String?) async -> AIAvailability { .unavailable(reason) }
    public func prewarm(for task: AITask) async {}

    public func find(meaning query: String, learner: LearnerProfile) async throws -> [AIWordContext] {
        throw AIError.unavailable(reason)
    }
}
