import Foundation

public struct ConversationTurn: Codable, Sendable, Hashable, Identifiable {
    public enum Speaker: String, Codable, Sendable { case learner, partner }

    public let id: UUID
    public let speaker: Speaker
    public let text: String

    public init(id: UUID = UUID(), speaker: Speaker, text: String) {
        self.id = id
        self.speaker = speaker
        self.text = text
    }
}

/// A short role-play: fixed setting and objective, never an open chat.
public struct ConversationScenario: Codable, Sendable, Hashable, Identifiable {
    /// Learner replies after which the session ends.
    public static let maxLearnerTurns = 8

    public let id: String
    public let title: String
    /// Where the learner is, one sentence.
    public let setting: String
    /// Who the AI plays, e.g. "a check-in agent at an airport".
    public let partnerRole: String
    /// What the learner has to achieve, shown on screen.
    public let objective: String
    public let level: CEFRLevel
    public let targetLemmas: [String]
    /// First partner line. Bundled so a session starts instantly and offline.
    public let openingLine: String

    public init(id: String, title: String, setting: String, partnerRole: String, objective: String,
                level: CEFRLevel, targetLemmas: [String], openingLine: String) {
        self.id = id
        self.title = title
        self.setting = setting
        self.partnerRole = partnerRole
        self.objective = objective
        self.level = level
        self.targetLemmas = targetLemmas
        self.openingLine = openingLine
    }
}

public struct ConversationReply: Codable, Sendable, Hashable {
    public let text: String
    public let objectiveMet: Bool

    public init(text: String, objectiveMet: Bool) {
        self.text = text
        self.objectiveMet = objectiveMet
    }
}

public struct ConversationMistake: Codable, Sendable, Hashable {
    /// Exact fragment from a learner turn.
    public let original: String
    public let better: String
    public let why: String

    public init(original: String, better: String, why: String) {
        self.original = original
        self.better = better
        self.why = why
    }
}

public struct ConversationSummary: Codable, Sendable, Hashable {
    public let mistakes: [ConversationMistake]
    public let expressions: [String]
    /// Lemmas; the app resolves them against the dictionary before offering to save.
    public let wordsToSave: [String]
    public let objectiveMet: Bool

    public init(mistakes: [ConversationMistake], expressions: [String], wordsToSave: [String], objectiveMet: Bool) {
        self.mistakes = mistakes
        self.expressions = expressions
        self.wordsToSave = wordsToSave
        self.objectiveMet = objectiveMet
    }
}
