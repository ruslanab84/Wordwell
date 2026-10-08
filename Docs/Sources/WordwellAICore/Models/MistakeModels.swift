import Foundation

/// A wrong multiple-choice answer plus the verified fact the explanation must rest on.
public struct MistakeContext: Codable, Sendable, Hashable {
    public enum Kind: String, Codable, Sendable { case grammar, vocabulary }

    public let kind: Kind
    /// Grammar lesson title or the headword.
    public let topic: String
    /// The question as shown (gap sentence or masked definition).
    public let prompt: String
    public let chosen: String
    public let correct: String
    /// Verified source text (lesson rule / dictionary definition). The model may not go beyond it.
    public let fact: String

    public init(kind: Kind, topic: String, prompt: String, chosen: String, correct: String, fact: String) {
        self.kind = kind
        self.topic = topic
        self.prompt = prompt
        self.chosen = chosen
        self.correct = correct
        self.fact = fact
    }
}

public struct MistakeExplanation: Codable, Sendable, Hashable {
    public let whyWrong: String
    public let whyRight: String

    public init(whyWrong: String, whyRight: String) {
        self.whyWrong = whyWrong
        self.whyRight = whyRight
    }
}
