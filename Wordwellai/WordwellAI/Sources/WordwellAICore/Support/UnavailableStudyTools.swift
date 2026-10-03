import Foundation

/// Null provider for unsupported devices/OS: every feature shows a proper unavailable state.
public struct UnavailableStudyTools: StudyToolsAI {
    public let reason: AIUnavailabilityReason
    public let identifier = "unavailable"
    public let promptVersion = "none"

    public init(reason: AIUnavailabilityReason) {
        self.reason = reason
    }

    public func availability(languageCode: String?) async -> AIAvailability { .unavailable(reason) }
    public func prewarm(for task: AITask) async {}

    public func proposeWords(for description: String, shortlist: [AIWordContext], learner: LearnerProfile) async throws -> [String] { throw error }
    public func story(using words: [AIWordContext], topicHint: String?, learner: LearnerProfile) async throws -> WordStory { throw error }
    public func assess(answers: [PlacementAnswer]) async throws -> ExamAssessment { throw error }
    public func lesson(for pattern: MistakePattern, examples: [MistakeRecord], learner: LearnerProfile) async throws -> MiniLessonContent { throw error }

    private var error: AIError { .unavailable(reason) }
}
