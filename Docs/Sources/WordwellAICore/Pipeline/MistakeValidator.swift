import Foundation

/// Structural checks only; factual grounding comes from the `fact` in the prompt.
public struct MistakeValidator: Sendable {
    public var maxCharacters = 300

    public init() {}

    public func validate(_ explanation: MistakeExplanation) throws -> MistakeExplanation {
        let wrong = explanation.whyWrong.trimmed
        let right = explanation.whyRight.trimmed
        guard !wrong.isEmpty, !right.isEmpty else { throw AIError.invalidResponse("empty explanation") }
        guard wrong.count <= maxCharacters, right.count <= maxCharacters else { throw AIError.invalidResponse("explanation too long") }
        return MistakeExplanation(whyWrong: wrong, whyRight: right)
    }
}
