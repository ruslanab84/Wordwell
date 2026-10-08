import Testing
import WordwellDomain

private let work = VocabularyTopic.all[0]
private let home = VocabularyTopic.all[1]

@Test func wordForYouIsEmptyWithoutSignals() {
    #expect(WordForYou.candidates(.init(dayKey: "20261008")).isEmpty)
}

@Test func weakWordsSteerTopicAndAreExcluded() {
    let weak = work.wordIDs[0]
    let saved = work.wordIDs[1]
    let signals = WordForYouSignals(weakIDs: [weak], savedIDs: [saved], dayKey: "20261008")
    let result = WordForYou.candidates(signals)
    #expect(result.first?.topicID == work.id)
    #expect(result.first?.reason.hasPrefix("Near words you missed") == true)
    #expect(!result.contains { $0.wordID == weak || $0.wordID == saved })
}

@Test func viewedWordsGiveExploringReason() {
    let result = WordForYou.candidates(.init(viewedIDs: [home.wordIDs[0]], dayKey: "20261008"))
    #expect(result.first?.topicID == home.id)
    #expect(result.first?.reason == "Because you've been exploring \(home.title)")
}

@Test func masteredWordsAreSkipped() {
    let mastered = Set(home.wordIDs.prefix(5))
    let result = WordForYou.candidates(.init(viewedIDs: [home.wordIDs[10]], masteredIDs: mastered, dayKey: "d"))
    #expect(result.allSatisfy { !mastered.contains($0.wordID) })
}

@Test func settingsTopicRestrictsPool() {
    let result = WordForYou.candidates(.init(weakIDs: [work.wordIDs[0]], topicID: home.id, dayKey: "d"))
    #expect(result.isEmpty)
}

@Test func orderIsStablePerDayAndRotatesAcrossDays() {
    let base = WordForYouSignals(weakIDs: [work.wordIDs[0]], dayKey: "20261008")
    var next = base
    next.dayKey = "20261009"
    #expect(WordForYou.candidates(base) == WordForYou.candidates(base))
    #expect(WordForYou.candidates(base).map(\.wordID) != WordForYou.candidates(next).map(\.wordID))
}

@Test func levelReach() {
    #expect(WordForYou.isWithinReach(nil, learner: .a1))
    #expect(WordForYou.isWithinReach(.b2, learner: .b1))
    #expect(!WordForYou.isWithinReach(.c1, learner: .b1))
}
