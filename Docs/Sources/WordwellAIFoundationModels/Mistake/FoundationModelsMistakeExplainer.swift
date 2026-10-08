#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// On-device wrong-answer explanation. Always wrap in `ResilientMistakeExplainer` (validation + regeneration).
@available(iOS 26.0, macOS 26.0, *)
public final class FoundationModelsMistakeExplainer: MistakeExplainerService {
    public let identifier = "apple.on-device.mistake"
    public var promptVersion: String { MistakePrompts.version }

    public init() {}

    public func availability(languageCode: String?) async -> AIAvailability {
        FMAvailability.current(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {}

    public func explain(_ mistake: MistakeContext, learner: LearnerProfile) async throws -> MistakeExplanation {
        do {
            try FMAvailability.require(languageCode: nil)
            let session = LanguageModelSession(instructions: MistakePrompts.instructions)
            let generated = try await session.respond(
                to: MistakePrompts.prompt(for: mistake, learner: learner),
                generating: GMistakeExplanation.self,
                options: MistakePrompts.options).content
            return MistakeExplanation(whyWrong: generated.whyWrong, whyRight: generated.whyRight)
        } catch {
            throw FMErrorMapper.map(error)
        }
    }
}
#endif
