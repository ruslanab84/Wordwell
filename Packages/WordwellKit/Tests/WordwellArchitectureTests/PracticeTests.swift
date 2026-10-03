import Foundation
import Testing
import WordwellData
import WordwellDomain

@Test func practicePersistsReviewAndComputesDailyActivity() async throws {
    let progress: any ProgressRepository = try LocalProgressRepository(inMemory: true)
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: today))

    try await progress.recordReview(ReviewEvent(
        id: UUID(), wordID: "family.n", reviewedAt: yesterday, answerQuality: 4, durationSeconds: 60
    ))
    try await progress.recordReview(ReviewEvent(
        id: UUID(), wordID: "branch.n", reviewedAt: .now, answerQuality: 1, durationSeconds: 75
    ))

    let summary = try await progress.practiceSummary()
    #expect(summary.dayStreak == 2)
    #expect(summary.minutesToday == 2)
    #expect(summary.wordsReviewedToday == 1)
    let mastery = try #require(try await progress.mastery(for: "branch.n"))
    #expect(mastery.status == .needsReview)
    #expect(mastery.nextReviewAt! <= .now)
    #expect(try await progress.mastery(for: "unseen.n") == nil)

    try await progress.recordReview(ReviewEvent(
        id: UUID(), wordID: "family.n", reviewedAt: .now, answerQuality: 4, durationSeconds: 30
    ))
    let repeated = try #require(try await progress.mastery(for: "family.n"))
    #expect(repeated.status == .learning)
    #expect(repeated.score == 0.4)
    #expect(repeated.nextReviewAt! > .now)
}

@Test func skillsCheckCountsOnceAndKeepsLatestLevelWithoutSavingAnswers() async throws {
    let progress: any ProgressRepository = try LocalProgressRepository(inMemory: true)
    let id = UUID()
    let original = SkillsCheckResult(id: id, completedAt: .now, durationSeconds: 125,
                                     readingCorrect: 4, listeningCorrect: 3,
                                     writingLevel: nil, speakingLevel: nil)
    try await progress.recordSkillsCheck(original)
    let assessed = SkillsCheckResult(id: id, completedAt: original.completedAt, durationSeconds: 125,
                                     readingCorrect: 4, listeningCorrect: 3,
                                     writingLevel: "B1", speakingLevel: "B2")
    try await progress.recordSkillsCheck(assessed)

    #expect(try await progress.latestSkillsCheck() == assessed)
    #expect(try await progress.practiceSummary().minutesToday == 3)
    #expect(try await progress.practiceSummary().dayStreak == 1)
    #expect(try await progress.snapshot().wordsReviewed == 0)
}

@Test func speakingCountsTowardProgressWithoutSavingTranscript() async throws {
    let progress: any ProgressRepository = try LocalProgressRepository(inMemory: true)
    try await progress.recordSpeaking(SpeakingEvent(
        id: UUID(), topicID: "memorable-day", completedAt: .now, durationSeconds: 45
    ))

    let snapshot = try await progress.snapshot()
    let summary = try await progress.practiceSummary()
    #expect(snapshot.speakingSessions == 1)
    #expect(summary.minutesToday == 1)
    #expect(summary.dayStreak == 1)
    #expect(summary.wordsReviewedToday == 0)
}

@Test func progressKeepsSevenDaysOfActivityAndSavedGoal() async throws {
    let progress: any ProgressRepository = try LocalProgressRepository(inMemory: true)
    let calendar = Calendar.current
    let threeDaysAgo = try #require(calendar.date(byAdding: .day, value: -3, to: .now))
    try await progress.recordReview(ReviewEvent(
        id: UUID(), wordID: "branch.n", reviewedAt: threeDaysAgo, answerQuality: 4, durationSeconds: 61
    ))
    try await progress.recordSpeaking(SpeakingEvent(
        id: UUID(), topicID: "day", completedAt: threeDaysAgo, durationSeconds: 59
    ))

    let days = try await progress.weeklyActivity()
    #expect(days.count == 7)
    #expect(days[3].minutes == 2)
    #expect(days[6].minutes == 0)
    #expect(try await progress.dailyGoalMinutes() == 10)
    try await progress.setDailyGoalMinutes(20)
    #expect(try await progress.dailyGoalMinutes() == 20)
    await #expect(throws: ProgressRepositoryError.self) {
        try await progress.setDailyGoalMinutes(0)
    }
}

private struct SeededRNG: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

@Test func offlineQuizAndListeningVaryAndPersistProgress() async throws {
    let dictionary: any DictionaryRepository = try LocalDictionaryRepository()
    var entries: [WordEntry] = []
    for lemma in ["family", "happy", "garden", "journey", "book", "learn", "listen", "speak", "river", "music"] {
        if let entry = try await dictionary.entry(lemma: lemma) { entries.append(entry) }
    }
    #expect(entries.count == 10)

    let targetIDs = entries.prefix(5).map(\.id)
    var rng = SeededRNG(state: 1)
    let quiz = DeterministicPractice.questions(from: entries, targetIDs: targetIDs, mode: .quiz, using: &rng)
    #expect(quiz.count == 5)
    #expect(Set(quiz.map(\.wordID)) == Set(targetIDs))
    #expect(quiz.allSatisfy { $0.choices.count == 4 && Set($0.choices).count == 4 })
    #expect(quiz.allSatisfy { $0.choices.indices.contains($0.correctChoiceIndex) })

    var same = SeededRNG(state: 1)
    #expect(DeterministicPractice.questions(from: entries.reversed(), targetIDs: targetIDs, mode: .quiz, using: &same) == quiz)
    let slots = Set((0..<20).flatMap { seed -> [Int] in
        var rng = SeededRNG(state: UInt64(seed))
        return DeterministicPractice.questions(from: entries, targetIDs: targetIDs, mode: .quiz, using: &rng)
            .map(\.correctChoiceIndex)
    })
    #expect(slots.count == 4)

    var listeningRNG = SeededRNG(state: 7)
    let listening = DeterministicPractice.questions(from: entries, targetIDs: [], mode: .listening, using: &listeningRNG)
    #expect(listening.count == 5)
    #expect(listening.allSatisfy { $0.prompt == "Which word do you hear?" && Set($0.choices).count == 4 })

    let progress: any ProgressRepository = try LocalProgressRepository(inMemory: true)
    try await progress.recordQuizAnswer(QuizAnswerEvent(wordID: quiz[0].wordID, isCorrect: true, durationSeconds: 20))
    try await progress.recordQuizAnswer(QuizAnswerEvent(wordID: quiz[1].wordID, isCorrect: false, durationSeconds: 20))
    try await progress.recordListening(ListeningEvent(durationSeconds: 90))
    let snapshot = try await progress.snapshot()
    #expect(snapshot.quizAccuracy == 0.5)
    #expect(snapshot.listeningMinutes == 1)
    #expect(snapshot.wordsReviewed == 2)
    #expect(try await progress.mastery(for: quiz[0].wordID)?.status == .learning)
    #expect(try await progress.mastery(for: quiz[1].wordID)?.status == .needsReview)
    #expect(try await progress.practiceSummary().minutesToday == 3)
    #expect(try await progress.weakQuizWordIDs(limit: 5) == [quiz[1].wordID])
}

@Test func quizPracticesOrderedTargetsAndMasksHeadword() {
    func entry(_ id: String, _ definition: String) -> WordEntry {
        WordEntry(id: id, word: id, lemma: id, partOfSpeech: .noun,
                  senses: [DefinitionSense(id: "\(id).1", definition: definition, examples: [])])
    }
    let entries = zip(["cat", "dog", "pen", "cup", "sun"], ["small pet", "loyal pet", "writing tool", "drinking vessel", "bright star"])
        .map { entry($0, "\($0): \($1)") }
    var rng = SeededRNG(state: 3)
    let quiz = DeterministicPractice.questions(from: entries, targetIDs: ["sun", "cup"], mode: .quiz, limit: 2, using: &rng)
    #expect(Set(quiz.map(\.wordID)) == ["sun", "cup"])
    #expect(quiz.allSatisfy { $0.choices.allSatisfy { !$0.contains("cat") && !$0.contains("sun") } })
    #expect(DeterministicPractice.questions(from: Array(entries.prefix(3)), targetIDs: [], mode: .quiz).isEmpty)
}

@Test func learningSettingsPersistLocally() async throws {
    let suite = "wordwell.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    let settings: any LearningSettingsRepository = LocalLearningSettingsRepository(suiteName: suite)
    #expect(try await settings.hasSavedProfile() == false)
    var profile = try await settings.profile()
    #expect(profile.cefrLevel == .b1)
    #expect(profile.dailyWordGoal == 5)
    profile.cefrLevel = .a2
    profile.dailyWordGoal = 10
    profile.preferredEnglishVariant = .uk
    profile.aiEnabled = false
    try await settings.save(profile)
    let reopened: any LearningSettingsRepository = LocalLearningSettingsRepository(suiteName: suite)
    #expect(try await reopened.hasSavedProfile())
    #expect(try await reopened.profile() == profile)
}

@Test func oldLearningProfileKeepsNotificationChoiceAndGetsDailyGoal() throws {
    let data = Data("""
    {"cefrLevel":"B1","explanationLanguage":"en","preferredEnglishVariant":"us","dailyGoalMinutes":10,"newWordsPerDay":2}
    """.utf8)
    let profile = try JSONDecoder().decode(LearningProfile.self, from: data)
    #expect(profile.dailyWordGoal == 5)
    #expect(profile.newWordsPerDay == 2)
}

@Test func dailyWordsStayFixedThroughRelaunchAndAdvanceNextDay() async throws {
    let suite = "wordwell.daily.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    let dictionary: any DictionaryRepository = try LocalDictionaryRepository()
    let library: any WordLibraryRepository = try LocalWordLibraryRepository(inMemory: true)
    let service = LocalDailyWordsService(dictionary: dictionary, library: library, suiteName: suite)
    let day = Calendar.current.startOfDay(for: .now)

    let first = try await service.today(goal: 3, on: day)
    #expect(first.words.count == 3)
    let learnedID = try #require(first.words.first?.id)
    let marked = try await service.markLearned(learnedID, on: day)
    #expect(marked.learnedCount == 1)
    #expect(try await library.state(for: learnedID) != nil)

    let reopened = LocalDailyWordsService(dictionary: dictionary, library: library, suiteName: suite)
    let sameDay = try await reopened.today(goal: 1, on: day)
    #expect(sameDay.goal == 3)
    #expect(sameDay.words.map(\.id) == first.words.map(\.id))
    #expect(sameDay.learnedIDs.contains(learnedID))

    let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: day))
    let nextDay = try await reopened.today(goal: 1, on: tomorrow)
    #expect(nextDay.goal == 1)
    #expect(nextDay.learnedCount == 0)
    #expect(!first.words.map(\.id).contains(nextDay.words[0].id))
}

@Test func failedDailyWordSaveDoesNotCountAsLearned() async throws {
    let suite = "wordwell.daily.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    let dictionary: any DictionaryRepository = try LocalDictionaryRepository()
    let library: any WordLibraryRepository = try LocalWordLibraryRepository(inMemory: true)
    let working = LocalDailyWordsService(dictionary: dictionary, library: library, suiteName: suite)
    let day = Calendar.current.startOfDay(for: .now)
    let wordID = try #require(try await working.today(goal: 1, on: day).words.first?.id)
    let unavailable = LocalDailyWordsService(dictionary: dictionary,
                                             library: UnavailableWordLibraryRepository(), suiteName: suite)
    await #expect(throws: WordLibraryError.self) {
        try await unavailable.markLearned(wordID, on: day)
    }
    #expect(try await working.today(goal: 1, on: day).learnedCount == 0)
}

@Test func unavailableDictionaryDoesNotCreateDailyList() async throws {
    let suite = "wordwell.daily.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    let library: any WordLibraryRepository = try LocalWordLibraryRepository(inMemory: true)
    let unavailable = LocalDailyWordsService(dictionary: UnavailableDictionaryRepository(),
                                             library: library, suiteName: suite)
    await #expect(throws: DictionaryRepositoryError.self) {
        try await unavailable.today(goal: 1)
    }
    let working = LocalDailyWordsService(dictionary: try LocalDictionaryRepository(),
                                         library: library, suiteName: suite)
    #expect(try await working.today(goal: 1).words.count == 1)
}
