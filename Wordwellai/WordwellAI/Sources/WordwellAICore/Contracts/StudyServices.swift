import Foundation

/// Deterministic retrieval over dictionary definitions. The app adapts its SQLite/FTS repository to this;
/// the CLI uses an in-memory implementation.
public protocol DefinitionSearching: Sendable {
    func candidates(matching query: String, limit: Int) async throws -> [AIWordContext]
}

public typealias SearchableDictionary = AIDictionaryLookup & DefinitionSearching

/// Reverse dictionary: "fear of heights" → words. Output is untrusted until verified by the dictionary.
public protocol WordFinderService: AIProvider {
    func proposeWords(for description: String, shortlist: [AIWordContext], learner: LearnerProfile) async throws -> [String]
}

public protocol StoryService: AIProvider {
    func story(using words: [AIWordContext], topicHint: String?, learner: LearnerProfile) async throws -> WordStory
}

public protocol PlacementService: AIProvider {
    func assess(answers: [PlacementAnswer]) async throws -> ExamAssessment
}

public protocol MistakeLessonService: AIProvider {
    func lesson(for pattern: MistakePattern, examples: [MistakeRecord], learner: LearnerProfile) async throws -> MiniLessonContent
}

public typealias StudyToolsAI = WordFinderService & StoryService & PlacementService & MistakeLessonService
