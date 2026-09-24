import Foundation
import SwiftData
import WordwellDomain

public enum ProgressRepositoryError: Error, Sendable {
    case unavailable
    case invalidGoal
}

@Model
private final class ReviewRecord {
    @Attribute(.unique) var id: UUID
    var wordID: String
    var reviewedAt: Date
    var answerQuality: Int
    var durationSeconds: Int

    init(_ event: ReviewEvent) {
        id = event.id
        wordID = event.wordID
        reviewedAt = event.reviewedAt
        answerQuality = event.answerQuality
        durationSeconds = event.durationSeconds
    }
}

@Model
private final class SpeakingRecord {
    @Attribute(.unique) var id: UUID
    var topicID: String
    var completedAt: Date
    var durationSeconds: Int

    init(_ event: SpeakingEvent) {
        id = event.id
        topicID = event.topicID
        completedAt = event.completedAt
        durationSeconds = event.durationSeconds
    }
}

@Model
private final class ListeningRecord {
    @Attribute(.unique) var id: UUID
    var completedAt: Date
    var durationSeconds: Int

    init(_ event: ListeningEvent) {
        id = event.id
        completedAt = event.completedAt
        durationSeconds = event.durationSeconds
    }
}

@Model
private final class QuizAnswerRecord {
    @Attribute(.unique) var id: UUID
    var wordID: String
    var answeredAt: Date
    var isCorrect: Bool
    var durationSeconds: Int

    init(_ event: QuizAnswerEvent) {
        id = event.id
        wordID = event.wordID
        answeredAt = event.answeredAt
        isCorrect = event.isCorrect
        durationSeconds = event.durationSeconds
    }
}

@Model
private final class DailyGoalRecord {
    @Attribute(.unique) var id: String
    var minutes: Int

    init(minutes: Int) {
        id = "daily"
        self.minutes = minutes
    }
}

@Model
private final class SkillsCheckRecord {
    @Attribute(.unique) var id: UUID
    var completedAt: Date
    var durationSeconds: Int
    var readingCorrect: Int
    var listeningCorrect: Int?
    var writingLevel: String?
    var speakingLevel: String?

    init(_ result: SkillsCheckResult) {
        id = result.id
        completedAt = result.completedAt
        durationSeconds = result.durationSeconds
        readingCorrect = result.readingCorrect
        listeningCorrect = result.listeningCorrect
        writingLevel = result.writingLevel
        speakingLevel = result.speakingLevel
    }

    func update(_ result: SkillsCheckResult) {
        completedAt = result.completedAt
        durationSeconds = result.durationSeconds
        readingCorrect = result.readingCorrect
        listeningCorrect = result.listeningCorrect
        writingLevel = result.writingLevel
        speakingLevel = result.speakingLevel
    }

    var result: SkillsCheckResult {
        SkillsCheckResult(id: id, completedAt: completedAt, durationSeconds: durationSeconds,
                          readingCorrect: readingCorrect, listeningCorrect: listeningCorrect,
                          writingLevel: writingLevel, speakingLevel: speakingLevel)
    }
}

public actor LocalProgressRepository: ProgressRepository {
    private let context: ModelContext

    public init(inMemory: Bool = false) throws {
        let schema = Schema([ReviewRecord.self, SpeakingRecord.self, ListeningRecord.self,
                             QuizAnswerRecord.self, DailyGoalRecord.self, SkillsCheckRecord.self])
        let configuration = ModelConfiguration("Practice", schema: schema, isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: schema, configurations: configuration)
        context = ModelContext(container)
    }

    public func recordReview(_ event: ReviewEvent) throws {
        context.insert(ReviewRecord(event))
        try context.save()
    }

    public func recordSpeaking(_ event: SpeakingEvent) throws {
        context.insert(SpeakingRecord(event))
        try context.save()
    }

    public func recordListening(_ event: ListeningEvent) throws {
        context.insert(ListeningRecord(event))
        try context.save()
    }

    public func recordQuizAnswer(_ event: QuizAnswerEvent) throws {
        context.insert(QuizAnswerRecord(event))
        try context.save()
    }

    public func recordSkillsCheck(_ result: SkillsCheckResult) throws {
        let id = result.id
        if let existing = try context.fetch(FetchDescriptor<SkillsCheckRecord>(
            predicate: #Predicate { $0.id == id }
        )).first {
            existing.update(result)
        } else {
            context.insert(SkillsCheckRecord(result))
        }
        try context.save()
    }

    public func latestSkillsCheck() throws -> SkillsCheckResult? {
        try context.fetch(FetchDescriptor<SkillsCheckRecord>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )).first?.result
    }

    public func mastery(for wordID: String) throws -> MasterySnapshot? {
        let reviews = try context.fetch(FetchDescriptor<ReviewRecord>(
            predicate: #Predicate { $0.wordID == wordID },
            sortBy: [SortDescriptor(\.reviewedAt, order: .reverse)]
        ))
        let quiz = try context.fetch(FetchDescriptor<QuizAnswerRecord>(
            predicate: #Predicate { $0.wordID == wordID },
            sortBy: [SortDescriptor(\.answeredAt, order: .reverse)]
        ))
        let attempts = (reviews.map { ($0.reviewedAt, $0.answerQuality >= 3) }
            + quiz.map { ($0.answeredAt, $0.isCorrect) })
            .sorted { $0.0 > $1.0 }
        guard let latest = attempts.first else { return nil }
        let correctStreak = attempts.prefix { $0.1 }.count
        let days = correctStreak == 0 ? 0 : min(1 << min(correctStreak - 1, 5), 30)
        let nextReviewAt = Calendar.current.date(byAdding: .day, value: days, to: latest.0)
        return MasterySnapshot(
            wordID: wordID,
            score: min(Double(correctStreak) / 5, 1),
            nextReviewAt: nextReviewAt,
            status: correctStreak == 0 ? .needsReview : correctStreak >= 5 ? .mastered : .learning
        )
    }

    public func snapshot() throws -> ProgressSnapshot {
        let reviews = try allReviews()
        let speaking = try allSpeaking()
        let listening = try allListening()
        let quiz = try allQuizAnswers()
        let mastered = Set(reviews.filter { $0.answerQuality >= 3 }.map(\.wordID)
            + quiz.filter(\.isCorrect).map(\.wordID))
        return ProgressSnapshot(
            wordsLearned: mastered.count,
            wordsReviewed: reviews.count + quiz.count,
            speakingSessions: speaking.count,
            listeningMinutes: listening.reduce(0) { $0 + $1.durationSeconds } / 60,
            quizAccuracy: quiz.isEmpty ? nil : Double(quiz.filter(\.isCorrect).count) / Double(quiz.count)
        )
    }

    public func practiceSummary() throws -> PracticeSummary {
        let reviews = try allReviews()
        let speaking = try allSpeaking()
        let listening = try allListening()
        let quiz = try allQuizAnswers()
        let skillsChecks = try allSkillsChecks()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let todayReviews = reviews.filter { calendar.isDate($0.reviewedAt, inSameDayAs: today) }
        let todaySpeaking = speaking.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }
        let practicedDays = Set(reviews.map { calendar.startOfDay(for: $0.reviewedAt) }
            + speaking.map { calendar.startOfDay(for: $0.completedAt) }
            + listening.map { calendar.startOfDay(for: $0.completedAt) }
            + quiz.map { calendar.startOfDay(for: $0.answeredAt) }
            + skillsChecks.map { calendar.startOfDay(for: $0.completedAt) })
        var day = practicedDays.contains(today)
            ? today : (calendar.date(byAdding: .day, value: -1, to: today) ?? today)
        var streak = 0
        while practicedDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        let seconds = todayReviews.reduce(0) { $0 + $1.durationSeconds }
            + todaySpeaking.reduce(0) { $0 + $1.durationSeconds }
            + listening.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }
                .reduce(0) { $0 + $1.durationSeconds }
            + quiz.filter { calendar.isDate($0.answeredAt, inSameDayAs: today) }
                .reduce(0) { $0 + $1.durationSeconds }
            + skillsChecks.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }
                .reduce(0) { $0 + $1.durationSeconds }
        return PracticeSummary(
            dayStreak: streak,
            minutesToday: (seconds + 59) / 60,
            wordsReviewedToday: Set(todayReviews.map(\.wordID)
                + quiz.filter { calendar.isDate($0.answeredAt, inSameDayAs: today) }.map(\.wordID)).count
        )
    }

    public func weeklyActivity() throws -> [DailyActivity] {
        let reviews = try allReviews()
        let speaking = try allSpeaking()
        let listening = try allListening()
        let quiz = try allQuizAnswers()
        let skillsChecks = try allSkillsChecks()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var secondsByDay: [Date: Int] = [:]
        for event in reviews { secondsByDay[calendar.startOfDay(for: event.reviewedAt), default: 0] += event.durationSeconds }
        for event in speaking { secondsByDay[calendar.startOfDay(for: event.completedAt), default: 0] += event.durationSeconds }
        for event in listening { secondsByDay[calendar.startOfDay(for: event.completedAt), default: 0] += event.durationSeconds }
        for event in quiz { secondsByDay[calendar.startOfDay(for: event.answeredAt), default: 0] += event.durationSeconds }
        for event in skillsChecks { secondsByDay[calendar.startOfDay(for: event.completedAt), default: 0] += event.durationSeconds }
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return DailyActivity(date: date, minutes: (secondsByDay[date, default: 0] + 59) / 60)
        }
    }

    public func dailyGoalMinutes() throws -> Int {
        try context.fetch(FetchDescriptor<DailyGoalRecord>()).first?.minutes ?? 10
    }

    public func setDailyGoalMinutes(_ minutes: Int) throws {
        guard (1...240).contains(minutes) else { throw ProgressRepositoryError.invalidGoal }
        if let record = try context.fetch(FetchDescriptor<DailyGoalRecord>()).first {
            record.minutes = minutes
        } else {
            context.insert(DailyGoalRecord(minutes: minutes))
        }
        try context.save()
    }

    private func allReviews() throws -> [ReviewRecord] {
        // ponytail: scan local review history; query by date if measured history growth makes this slow.
        try context.fetch(FetchDescriptor<ReviewRecord>())
    }

    private func allSpeaking() throws -> [SpeakingRecord] {
        try context.fetch(FetchDescriptor<SpeakingRecord>())
    }

    private func allListening() throws -> [ListeningRecord] {
        try context.fetch(FetchDescriptor<ListeningRecord>())
    }

    private func allQuizAnswers() throws -> [QuizAnswerRecord] {
        try context.fetch(FetchDescriptor<QuizAnswerRecord>())
    }

    private func allSkillsChecks() throws -> [SkillsCheckRecord] {
        try context.fetch(FetchDescriptor<SkillsCheckRecord>())
    }
}

public struct UnavailableProgressRepository: ProgressRepository {
    public init() {}
    public func recordReview(_ event: ReviewEvent) throws { throw ProgressRepositoryError.unavailable }
    public func recordSpeaking(_ event: SpeakingEvent) throws { throw ProgressRepositoryError.unavailable }
    public func recordListening(_ event: ListeningEvent) throws { throw ProgressRepositoryError.unavailable }
    public func recordQuizAnswer(_ event: QuizAnswerEvent) throws { throw ProgressRepositoryError.unavailable }
    public func recordSkillsCheck(_ result: SkillsCheckResult) throws { throw ProgressRepositoryError.unavailable }
    public func latestSkillsCheck() throws -> SkillsCheckResult? { throw ProgressRepositoryError.unavailable }
    public func mastery(for wordID: String) throws -> MasterySnapshot? { throw ProgressRepositoryError.unavailable }
    public func snapshot() throws -> ProgressSnapshot { throw ProgressRepositoryError.unavailable }
    public func practiceSummary() throws -> PracticeSummary { throw ProgressRepositoryError.unavailable }
    public func weeklyActivity() throws -> [DailyActivity] { throw ProgressRepositoryError.unavailable }
    public func dailyGoalMinutes() throws -> Int { throw ProgressRepositoryError.unavailable }
    public func setDailyGoalMinutes(_ minutes: Int) throws { throw ProgressRepositoryError.unavailable }
}
