import Foundation

public enum CEFRLevel: String, Codable, Sendable, CaseIterable, Comparable {
    case a1 = "A1", a2 = "A2", b1 = "B1", b2 = "B2", c1 = "C1", c2 = "C2"

    public var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.index < rhs.index }
}

public enum AITask: String, Codable, Sendable, CaseIterable {
    case explain, examples, compare, commonMistakes, quiz, improveSentence
    case speakingPrompt, speakingFeedback, weeklyInsight
}

public struct LearnerProfile: Codable, Sendable, Hashable {
    public var level: CEFRLevel
    /// BCP-47 code for "Explain in my language", e.g. "ru".
    public var nativeLanguageCode: String?
    /// Personalises examples ("football", "cooking"). Stays on device.
    public var interests: [String]

    public init(level: CEFRLevel, nativeLanguageCode: String? = nil, interests: [String] = []) {
        self.level = level
        self.nativeLanguageCode = nativeLanguageCode
        self.interests = interests
    }
}

/// Verified dictionary data handed to the model. The only source of meanings.
public struct AIWordContext: Codable, Sendable, Hashable {
    public struct Sense: Codable, Sendable, Hashable {
        public let id: String
        public let definition: String
        public let example: String?

        public init(id: String, definition: String, example: String? = nil) {
            self.id = id
            self.definition = definition
            self.example = example
        }
    }

    public let lemma: String
    public let partOfSpeech: String
    public let cefrLevel: CEFRLevel?
    public let senses: [Sense]
    public let collocations: [String]
    /// Inflected forms used for validation: decides, decided, deciding.
    public let forms: [String]

    public init(lemma: String, partOfSpeech: String, cefrLevel: CEFRLevel?, senses: [Sense],
                collocations: [String] = [], forms: [String] = []) {
        self.lemma = lemma
        self.partOfSpeech = partOfSpeech
        self.cefrLevel = cefrLevel
        self.senses = senses
        self.collocations = collocations
        self.forms = forms
    }

    public var allForms: [String] {
        var seen = Set<String>()
        return ([lemma] + forms).filter { seen.insert($0.lowercased()).inserted }
    }
}

public struct WeeklyStats: Codable, Sendable, Hashable {
    public var wordsLearned: Int
    public var wordsReviewed: Int
    public var speakingSessions: Int
    public var listeningMinutes: Int
    /// 0...1
    public var quizAccuracy: Double
    public var streakDays: Int
    public var weakWords: [String]

    public init(wordsLearned: Int, wordsReviewed: Int, speakingSessions: Int, listeningMinutes: Int,
                quizAccuracy: Double, streakDays: Int, weakWords: [String] = []) {
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.speakingSessions = speakingSessions
        self.listeningMinutes = listeningMinutes
        self.quizAccuracy = quizAccuracy
        self.streakDays = streakDays
        self.weakWords = weakWords
    }
}
