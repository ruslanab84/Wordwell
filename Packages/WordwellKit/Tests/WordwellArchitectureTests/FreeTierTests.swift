import Foundation
import Testing
import WordwellDomain

@Test func onlyB1AndAboveIllustrationsArePremium() {
    #expect(FreeTier.isIllustrationFree(tags: []))
    #expect(FreeTier.isIllustrationFree(tags: ["a1", "animals"]))
    #expect(FreeTier.isIllustrationFree(tags: ["a2"]))
    #expect(!FreeTier.isIllustrationFree(tags: ["b1"]))
    #expect(!FreeTier.isIllustrationFree(tags: ["food", "C1"]))
}

@Test func dailyQuotaStopsAtLimitAndResetsNextDay() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let today = Date(timeIntervalSince1970: 1_800_000_000)
    let tomorrow = today.addingTimeInterval(86_400)
    var quota = DailyQuota()
    let firstThree = (0..<3).map { _ in quota.consume(limit: 3, now: today, calendar: calendar) }
    let fourth = quota.consume(limit: 3, now: today, calendar: calendar)
    #expect(firstThree == [true, true, true])
    #expect(!fourth)
    #expect(quota.remaining(limit: 3, now: today, calendar: calendar) == 0)
    #expect(quota.remaining(limit: 3, now: tomorrow, calendar: calendar) == 3)
    let nextDay = quota.consume(limit: 3, now: tomorrow, calendar: calendar)
    #expect(nextDay)
}
