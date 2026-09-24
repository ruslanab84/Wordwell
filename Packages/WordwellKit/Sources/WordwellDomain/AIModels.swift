import Foundation

public enum AIUnavailableReason: String, Codable, Sendable {
    case notConfigured
    case deviceNotEligible
    case appleIntelligenceDisabled
    case modelNotReady
    case languageUnsupported
    case restricted
}

public enum AIAvailability: Equatable, Sendable {
    case available
    case unavailable(AIUnavailableReason)
}

public enum AIServiceError: Error, Equatable, Sendable {
    case unavailable(AIUnavailableReason)
    case invalidOutput
    case generationFailed
}

public struct AIContext: Codable, Equatable, Sendable {
    public let profile: LearningProfile
    public let weakWordIDs: [String]
    public let recentMistakeTags: [String]

    public init(
        profile: LearningProfile,
        weakWordIDs: [String] = [],
        recentMistakeTags: [String] = []
    ) {
        self.profile = profile
        self.weakWordIDs = weakWordIDs
        self.recentMistakeTags = recentMistakeTags
    }
}

public struct SimpleExplanation: Codable, Equatable, Sendable {
    public let senseID: String
    public let text: String

    public init(senseID: String, text: String) {
        self.senseID = senseID
        self.text = text
    }
}

public struct LocalizedExplanation: Codable, Equatable, Sendable {
    public let senseID: String
    public let languageCode: String
    public let text: String

    public init(senseID: String, languageCode: String, text: String) {
        self.senseID = senseID
        self.languageCode = languageCode
        self.text = text
    }
}

public struct GeneratedExample: Codable, Equatable, Sendable {
    public let senseID: String
    public let sentence: String

    public init(senseID: String, sentence: String) {
        self.senseID = senseID
        self.sentence = sentence
    }
}

public struct WordDifference: Codable, Equatable, Sendable {
    public let wordID: String
    public let distinction: String
    public let example: String

    public init(wordID: String, distinction: String, example: String) {
        self.wordID = wordID
        self.distinction = distinction
        self.example = example
    }
}

public struct WordComparison: Codable, Equatable, Sendable {
    public let summary: String
    public let differences: [WordDifference]
    public let commonTrap: String?

    public init(summary: String, differences: [WordDifference], commonTrap: String? = nil) {
        self.summary = summary
        self.differences = differences
        self.commonTrap = commonTrap
    }
}

public struct FeedbackMistake: Codable, Equatable, Sendable {
    public let explanation: String
    public let correction: String

    public init(explanation: String, correction: String) {
        self.explanation = explanation
        self.correction = correction
    }
}

public struct SentenceFeedback: Codable, Equatable, Sendable {
    public let original: String
    public let corrected: String
    public let explanation: String
    public let importantMistakes: [FeedbackMistake]
    public let naturalAlternative: String?

    public init(
        original: String,
        corrected: String,
        explanation: String,
        importantMistakes: [FeedbackMistake],
        naturalAlternative: String? = nil
    ) {
        self.original = original
        self.corrected = corrected
        self.explanation = explanation
        self.importantMistakes = importantMistakes
        self.naturalAlternative = naturalAlternative
    }
}

public struct QuizQuestion: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let prompt: String
    public let choices: [String]
    public let correctChoiceIndex: Int
    public let wordID: String

    public init(
        id: String,
        prompt: String,
        choices: [String],
        correctChoiceIndex: Int,
        wordID: String
    ) {
        self.id = id
        self.prompt = prompt
        self.choices = choices
        self.correctChoiceIndex = correctChoiceIndex
        self.wordID = wordID
    }
}

public struct QuizSession: Codable, Equatable, Sendable {
    public let questions: [QuizQuestion]

    public init(questions: [QuizQuestion]) {
        self.questions = questions
    }
}
