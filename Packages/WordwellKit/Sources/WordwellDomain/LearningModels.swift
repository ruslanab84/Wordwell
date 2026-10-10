import Foundation

public enum EnglishVariant: String, Codable, Sendable {
    case uk, us, both
}

public enum LearningStatus: String, Codable, Sendable {
    case learning, needsReview, mastered
}

/// Languages the learner can pick for AI explanations (BCP-47 code, English name).
public enum SupportedLanguages {
    public static let all: [(code: String, name: String)] = [
        ("az", "Azerbaijani"), ("de", "German"), ("en", "English"),
        ("es", "Spanish"), ("fr", "French"), ("ru", "Russian"),
    ]

    public static func name(for code: String) -> String {
        all.first { $0.code == code }?.name ?? code
    }
}

public struct LearningProfile: Codable, Equatable, Sendable {
    public var cefrLevel: CEFRLevel
    public var explanationLanguage: String
    public var preferredEnglishVariant: EnglishVariant
    public var dailyGoalMinutes: Int
    public var dailyWordGoal: Int
    public var newWordsPerDay: Int
    public var aiEnabled: Bool
    /// `VocabularyTopic.id` restricting Home and notification words; nil means all words.
    public var wordTopicID: String?

    public init(
        cefrLevel: CEFRLevel,
        explanationLanguage: String,
        preferredEnglishVariant: EnglishVariant,
        dailyGoalMinutes: Int,
        dailyWordGoal: Int = 5,
        newWordsPerDay: Int = 0,
        aiEnabled: Bool = true,
        wordTopicID: String? = nil
    ) {
        self.cefrLevel = cefrLevel
        self.explanationLanguage = explanationLanguage
        self.preferredEnglishVariant = preferredEnglishVariant
        self.dailyGoalMinutes = dailyGoalMinutes
        self.dailyWordGoal = dailyWordGoal
        self.newWordsPerDay = newWordsPerDay
        self.aiEnabled = aiEnabled
        self.wordTopicID = wordTopicID
    }

    private enum CodingKeys: String, CodingKey {
        case cefrLevel, explanationLanguage, preferredEnglishVariant, dailyGoalMinutes, dailyWordGoal, newWordsPerDay, aiEnabled, wordTopicID
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cefrLevel = try values.decode(CEFRLevel.self, forKey: .cefrLevel)
        explanationLanguage = try values.decode(String.self, forKey: .explanationLanguage)
        preferredEnglishVariant = try values.decode(EnglishVariant.self, forKey: .preferredEnglishVariant)
        dailyGoalMinutes = try values.decode(Int.self, forKey: .dailyGoalMinutes)
        dailyWordGoal = try values.decodeIfPresent(Int.self, forKey: .dailyWordGoal) ?? 5
        newWordsPerDay = try values.decodeIfPresent(Int.self, forKey: .newWordsPerDay) ?? 0
        aiEnabled = try values.decodeIfPresent(Bool.self, forKey: .aiEnabled) ?? true
        wordTopicID = try values.decodeIfPresent(String.self, forKey: .wordTopicID)
    }
}

public struct UserWordState: Identifiable, Codable, Equatable, Sendable {
    public var id: String { wordID }
    public let wordID: String
    public var isFavorite: Bool
    public var collectionIDs: [String]
    public var status: LearningStatus
    public var personalExample: String?

    public init(
        wordID: String,
        isFavorite: Bool = false,
        collectionIDs: [String] = [],
        status: LearningStatus = .learning,
        personalExample: String? = nil
    ) {
        self.wordID = wordID
        self.isFavorite = isFavorite
        self.collectionIDs = collectionIDs
        self.status = status
        self.personalExample = personalExample
    }
}

public struct WordCollection: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public var name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct ReviewEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let wordID: String
    public let reviewedAt: Date
    public let answerQuality: Int
    public let durationSeconds: Int

    public init(id: UUID, wordID: String, reviewedAt: Date, answerQuality: Int, durationSeconds: Int = 0) {
        self.id = id
        self.wordID = wordID
        self.reviewedAt = reviewedAt
        self.answerQuality = answerQuality
        self.durationSeconds = durationSeconds
    }
}

public struct SpeakingEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let topicID: String
    public let completedAt: Date
    public let durationSeconds: Int

    public init(id: UUID, topicID: String, completedAt: Date, durationSeconds: Int) {
        self.id = id
        self.topicID = topicID
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }
}

public struct ListeningEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let completedAt: Date
    public let durationSeconds: Int

    public init(id: UUID = UUID(), completedAt: Date = .now, durationSeconds: Int) {
        self.id = id
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }
}

public struct QuizAnswerEvent: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let wordID: String
    public let answeredAt: Date
    public let isCorrect: Bool
    public let durationSeconds: Int

    public init(id: UUID = UUID(), wordID: String, answeredAt: Date = .now,
                isCorrect: Bool, durationSeconds: Int) {
        self.id = id
        self.wordID = wordID
        self.answeredAt = answeredAt
        self.isCorrect = isCorrect
        self.durationSeconds = durationSeconds
    }
}

public struct PracticeSummary: Equatable, Sendable {
    public let dayStreak: Int
    public let minutesToday: Int
    public let wordsReviewedToday: Int

    public init(dayStreak: Int, minutesToday: Int, wordsReviewedToday: Int) {
        self.dayStreak = dayStreak
        self.minutesToday = minutesToday
        self.wordsReviewedToday = wordsReviewedToday
    }
}

public struct SkillsCheckResult: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let completedAt: Date
    public let durationSeconds: Int
    public let readingCorrect: Int
    public let listeningCorrect: Int?
    public let writingLevel: String?
    public let speakingLevel: String?

    public init(id: UUID, completedAt: Date, durationSeconds: Int, readingCorrect: Int,
                listeningCorrect: Int?, writingLevel: String?, speakingLevel: String?) {
        self.id = id
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.readingCorrect = readingCorrect
        self.listeningCorrect = listeningCorrect
        self.writingLevel = writingLevel
        self.speakingLevel = speakingLevel
    }
}

public struct DailyActivity: Equatable, Sendable {
    public let date: Date
    public let minutes: Int

    public init(date: Date, minutes: Int) {
        self.date = date
        self.minutes = minutes
    }
}

public struct MasterySnapshot: Codable, Equatable, Sendable {
    public let wordID: String
    public let score: Double
    public let nextReviewAt: Date?
    public let status: LearningStatus

    public init(wordID: String, score: Double, nextReviewAt: Date?, status: LearningStatus) {
        self.wordID = wordID
        self.score = score
        self.nextReviewAt = nextReviewAt
        self.status = status
    }
}

public struct ProgressSnapshot: Codable, Equatable, Sendable {
    public let wordsLearned: Int
    public let wordsReviewed: Int
    public let speakingSessions: Int
    public let listeningMinutes: Int
    public let quizAccuracy: Double?

    public init(
        wordsLearned: Int,
        wordsReviewed: Int,
        speakingSessions: Int,
        listeningMinutes: Int,
        quizAccuracy: Double?
    ) {
        self.wordsLearned = wordsLearned
        self.wordsReviewed = wordsReviewed
        self.speakingSessions = speakingSessions
        self.listeningMinutes = listeningMinutes
        self.quizAccuracy = quizAccuracy
    }
}
