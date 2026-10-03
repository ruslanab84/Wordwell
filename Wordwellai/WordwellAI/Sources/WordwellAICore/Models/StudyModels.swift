import Foundation

// MARK: - Reverse dictionary

public struct WordFinderMatch: Codable, Sendable, Hashable, Identifiable {
    public enum Source: String, Codable, Sendable {
        /// Proposed by the model and found by dictionary retrieval: strongest signal.
        case both
        case model
        case retrieval
    }

    public var id: String { lemma }
    public let lemma: String
    public let partOfSpeech: String
    public let cefrLevel: CEFRLevel?
    public let senseID: String
    /// Always the dictionary's definition, never model text.
    public let definition: String
    public let source: Source

    public init(lemma: String, partOfSpeech: String, cefrLevel: CEFRLevel?, senseID: String,
                definition: String, source: Source) {
        self.lemma = lemma
        self.partOfSpeech = partOfSpeech
        self.cefrLevel = cefrLevel
        self.senseID = senseID
        self.definition = definition
        self.source = source
    }
}

public struct ReverseLookupResult: Codable, Sendable, Hashable {
    public let matches: [WordFinderMatch]
    public let aiUsed: Bool
    /// Set when the model was unavailable and the result comes from retrieval only.
    public let aiUnavailableReason: AIUnavailabilityReason?

    public init(matches: [WordFinderMatch], aiUsed: Bool, aiUnavailableReason: AIUnavailabilityReason?) {
        self.matches = matches
        self.aiUsed = aiUsed
        self.aiUnavailableReason = aiUnavailableReason
    }
}

// MARK: - Story from my words

public struct WordStory: Codable, Sendable, Hashable {
    public let title: String
    public let paragraphs: [String]

    public init(title: String, paragraphs: [String]) {
        self.title = title
        self.paragraphs = paragraphs
    }
}

/// UTF-16 span inside one paragraph (NSString-compatible), ready for tap-to-define rendering.
public struct StoryHighlight: Codable, Sendable, Hashable {
    public let lemma: String
    public let location: Int
    public let length: Int

    public init(lemma: String, location: Int, length: Int) {
        self.lemma = lemma
        self.location = location
        self.length = length
    }
}

public struct ValidatedStory: Codable, Sendable, Hashable {
    public let title: String
    public let paragraphs: [String]
    /// One array per paragraph, sorted by location.
    public let highlights: [[StoryHighlight]]
    public let usedWords: [String]
    public let missingWords: [String]
    public let wordCount: Int
    public let averageSentenceLength: Double

    public var isComplete: Bool { missingWords.isEmpty }

    public init(title: String, paragraphs: [String], highlights: [[StoryHighlight]], usedWords: [String],
                missingWords: [String], wordCount: Int, averageSentenceLength: Double) {
        self.title = title
        self.paragraphs = paragraphs
        self.highlights = highlights
        self.usedWords = usedWords
        self.missingWords = missingWords
        self.wordCount = wordCount
        self.averageSentenceLength = averageSentenceLength
    }
}

public struct StoryProfile: Sendable, Hashable {
    public let wordRange: ClosedRange<Int>
    public let maxAverageSentenceWords: Double

    public static func `for`(_ level: CEFRLevel) -> StoryProfile {
        switch level {
        case .a1: StoryProfile(wordRange: 50...100, maxAverageSentenceWords: 9)
        case .a2: StoryProfile(wordRange: 70...130, maxAverageSentenceWords: 12)
        case .b1: StoryProfile(wordRange: 100...180, maxAverageSentenceWords: 16)
        case .b2: StoryProfile(wordRange: 130...230, maxAverageSentenceWords: 20)
        case .c1: StoryProfile(wordRange: 160...290, maxAverageSentenceWords: 24)
        case .c2: StoryProfile(wordRange: 190...330, maxAverageSentenceWords: 28)
        }
    }
}

// MARK: - Placement

public struct PlacementPrompt: Codable, Sendable, Hashable, Identifiable {
    public let id: Int
    public let text: String
    public let suggestedSentences: Int

    public init(id: Int, text: String, suggestedSentences: Int) {
        self.id = id
        self.text = text
        self.suggestedSentences = suggestedSentences
    }
}

/// Fixed, hand-written ladder from easy to demanding. Deterministic on purpose: placement must be
/// comparable between users and needs no model call to produce questions.
public enum PlacementPrompts {
    public static let standard: [PlacementPrompt] = [
        PlacementPrompt(id: 1, text: "Tell us about your typical day.", suggestedSentences: 3),
        PlacementPrompt(id: 2, text: "Describe a trip or event you remember well and explain why it was memorable.", suggestedSentences: 4),
        PlacementPrompt(id: 3, text: "Some people think technology makes life easier, others disagree. What is your opinion?", suggestedSentences: 5),
    ]
    /// Total words needed for a trustworthy estimate.
    public static let minimumWords = 60
    public static let maxAnswers = 5
}

public struct PlacementAnswer: Codable, Sendable, Hashable {
    public let promptID: Int
    public let text: String

    public init(promptID: Int, text: String) {
        self.promptID = promptID
        self.text = text
    }
}

public enum PlacementConfidence: String, Codable, Sendable, Comparable {
    case low, medium, high

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rank < rhs.rank }
    private var rank: Int { self == .low ? 0 : self == .medium ? 1 : 2 }

    var lowered: PlacementConfidence { self == .high ? .medium : .low }
}

public struct PlacementResult: Codable, Sendable, Hashable {
    public let assessment: ExamAssessment
    public let startingLevel: CEFRLevel
    public let confidence: PlacementConfidence
    /// True when a low-confidence result was capped so a short answer cannot place a learner too high.
    public let cappedByConfidence: Bool
    public static let disclaimerKey = "placement.disclaimer"

    public init(assessment: ExamAssessment, startingLevel: CEFRLevel, confidence: PlacementConfidence,
                cappedByConfidence: Bool) {
        self.assessment = assessment
        self.startingLevel = startingLevel
        self.confidence = confidence
        self.cappedByConfidence = cappedByConfidence
    }
}

// MARK: - Mistake patterns

public enum MistakePattern: String, Codable, Sendable, CaseIterable {
    case articles, prepositions, verbForms, agreement, plurals, wordOrder
    case spelling, wordChoice, collocation, register, other

    /// Key for the app's String Catalog.
    public var localizationKey: String { "mistake.pattern.\(rawValue)" }

    /// Patterns whose exercises can be verified by `MistakeClassifier` itself.
    public var isRuleVerifiable: Bool {
        switch self {
        case .articles, .prepositions, .verbForms, .agreement, .plurals, .wordOrder: true
        default: false
        }
    }
}

public struct MistakeRecord: Codable, Sendable, Hashable, Identifiable {
    public enum Source: String, Codable, Sendable {
        case manual, improveSentence, speaking, quiz
    }

    public let id: UUID
    /// Whole learner sentence containing the mistake.
    public let wrong: String
    /// The same sentence with the mistake fixed.
    public let right: String
    /// Model/user category. Only used when rules cannot decide.
    public let hint: SentenceIssue.Kind?
    public let explanation: String?
    public let date: Date
    public let source: Source

    public init(id: UUID = UUID(), wrong: String, right: String, hint: SentenceIssue.Kind? = nil,
                explanation: String? = nil, date: Date = Date(), source: Source = .manual) {
        self.id = id
        self.wrong = wrong
        self.right = right
        self.hint = hint
        self.explanation = explanation
        self.date = date
        self.source = source
    }

    public var pattern: MistakePattern {
        MistakeClassifier.classify(wrong: wrong, right: right, hint: hint)
    }
}

public struct PatternStat: Codable, Sendable, Hashable, Identifiable {
    public var id: MistakePattern { pattern }
    public let pattern: MistakePattern
    public let total: Int
    /// Mistakes in the last 7 days.
    public let recent: Int
    /// Recency-weighted count used for ranking.
    public let weight: Double
    /// Most recent distinct examples.
    public let examples: [MistakeRecord]

    public init(pattern: MistakePattern, total: Int, recent: Int, weight: Double, examples: [MistakeRecord]) {
        self.pattern = pattern
        self.total = total
        self.recent = recent
        self.weight = weight
        self.examples = examples
    }
}

public struct MistakeExercise: Codable, Sendable, Hashable {
    public let incorrect: String
    public let correct: String

    public init(incorrect: String, correct: String) {
        self.incorrect = incorrect
        self.correct = correct
    }
}

public struct MiniLessonContent: Codable, Sendable, Hashable {
    public let title: String
    public let rule: String
    public let tip: String?
    public let exercises: [MistakeExercise]

    public init(title: String, rule: String, tip: String?, exercises: [MistakeExercise]) {
        self.title = title
        self.rule = rule
        self.tip = tip
        self.exercises = exercises
    }
}

public struct WeeklyMistakeLesson: Codable, Sendable, Hashable {
    public let pattern: MistakePattern
    public let stat: PatternStat
    public let content: MiniLessonContent
    public let generatedAt: Date

    /// The learner's own mistakes (from the notebook, not model text).
    public var yourMistakes: [MistakeRecord] { stat.examples }

    public init(pattern: MistakePattern, stat: PatternStat, content: MiniLessonContent, generatedAt: Date) {
        self.pattern = pattern
        self.stat = stat
        self.content = content
        self.generatedAt = generatedAt
    }
}
