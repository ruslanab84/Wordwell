import Foundation

public enum DictionaryRepositoryError: Error, Equatable, Sendable {
    case notConfigured
    case invalidDatabase
    case queryFailed
}

public protocol DictionaryRepository: Sendable {
    func search(_ query: String, limit: Int) async throws -> [WordSummary]
    func suggestions(prefix: String, limit: Int) async throws -> [String]
    func entry(id: String) async throws -> WordEntry?
    func entry(lemma: String) async throws -> WordEntry?
    /// `ids` restricts the pool to those entry ids (a vocabulary topic); nil means any word.
    func featuredEntry(excluding wordID: String?, among ids: Set<String>?) async throws -> WordEntry?
    func notificationEntries(excluding wordIDs: Set<String>, limit: Int, among ids: Set<String>?) async throws -> [WordEntry]
}

public extension DictionaryRepository {
    func featuredEntry(excluding wordID: String?) async throws -> WordEntry? {
        try await featuredEntry(excluding: wordID, among: nil)
    }

    func notificationEntries(excluding wordIDs: Set<String>, limit: Int) async throws -> [WordEntry] {
        try await notificationEntries(excluding: wordIDs, limit: limit, among: nil)
    }
}

public protocol WordLibraryRepository: Sendable {
    func save(wordID: String) async throws
    func remove(wordID: String) async throws
    func state(for wordID: String) async throws -> UserWordState?
    func allSavedWords() async throws -> [UserWordState]
    func update(_ state: UserWordState) async throws
    func recordViewed(wordID: String) async throws
    func recentlyViewedWordIDs(limit: Int) async throws -> [String]
    func collections() async throws -> [WordCollection]
    func createCollection(named name: String) async throws -> WordCollection
}

public protocol ProgressRepository: Sendable {
    func recordReview(_ event: ReviewEvent) async throws
    func recordSpeaking(_ event: SpeakingEvent) async throws
    func recordListening(_ event: ListeningEvent) async throws
    func recordQuizAnswer(_ event: QuizAnswerEvent) async throws
    /// Word IDs whose latest quiz answer was wrong, most recently missed first.
    func weakQuizWordIDs(limit: Int) async throws -> [String]
    func recordSkillsCheck(_ result: SkillsCheckResult) async throws
    func latestSkillsCheck() async throws -> SkillsCheckResult?
    func mastery(for wordID: String) async throws -> MasterySnapshot?
    func snapshot() async throws -> ProgressSnapshot
    func practiceSummary() async throws -> PracticeSummary
    func weeklyActivity() async throws -> [DailyActivity]
    func dailyGoalMinutes() async throws -> Int
    func setDailyGoalMinutes(_ minutes: Int) async throws
}

public protocol LearningSettingsRepository: Sendable {
    func hasSavedProfile() async throws -> Bool
    func profile() async throws -> LearningProfile
    func save(_ profile: LearningProfile) async throws
}

public protocol IllustrationBindingRepository: Sendable {
    func binding(
        lemma: String,
        partOfSpeech: PartOfSpeech?,
        senseID: String?,
        context: IllustrationContext
    ) async throws -> IllustrationBinding?
}
