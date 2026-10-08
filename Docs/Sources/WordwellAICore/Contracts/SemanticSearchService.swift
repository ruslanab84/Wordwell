import Foundation

/// Meaning-based word lookup ("a word for being extremely tired"). Separate from `LearningAI`.
/// Returns dictionary-verified words only; implementations must not cache.
public protocol SemanticSearchService: AIProvider {
    func find(meaning query: String, learner: LearnerProfile) async throws -> [AIWordContext]
}

/// Raw proposals from a model, before dictionary verification.
public protocol SemanticCandidateProvider: AIProvider {
    func candidates(for query: String, learner: LearnerProfile) async throws -> [String]
}
