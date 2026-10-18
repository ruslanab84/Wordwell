import Foundation
import Testing
import WordwellDomain

@Test func dailyWordScheduleFindsWordByLocalDay() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Baku")!
    // 2027-01-15 21:30 UTC is already 2027-01-16 in Baku (UTC+4).
    let date = Date(timeIntervalSince1970: 1_800_049_800)
    #expect(DailyWordSchedule.dayKey(date, calendar: calendar) == "20270116")

    let word = DailyWord(day: "20270116", wordID: "oewn:lantern:n", word: "lantern", partOfSpeech: "noun",
                         ipa: "ˈlæntən", definition: "light enclosed in a protective case")
    let schedule = DailyWordSchedule(topicID: nil, variant: .uk, words: [word])
    #expect(schedule.word(on: date, calendar: calendar) == word)
    #expect(schedule.word(on: date.addingTimeInterval(86_400), calendar: calendar) == nil)

    let defaults = try #require(UserDefaults(suiteName: "DailyWordScheduleTests"))
    defer { defaults.removePersistentDomain(forName: "DailyWordScheduleTests") }
    schedule.save(to: defaults)
    #expect(DailyWordSchedule.load(from: defaults) == schedule)
}
