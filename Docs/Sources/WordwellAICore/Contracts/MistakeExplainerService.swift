import Foundation

/// Explains a wrong multiple-choice answer. Separate from `LearningAI` so adding it never touches those conformers.
/// The answer key comes from the caller; implementations must not cache (output depends on the learner's level and choice).
public protocol MistakeExplainerService: AIProvider {
    func explain(_ mistake: MistakeContext, learner: LearnerProfile) async throws -> MistakeExplanation
}
