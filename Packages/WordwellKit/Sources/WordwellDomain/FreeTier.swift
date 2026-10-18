import Foundation

/// What the free tier includes. Premium lifts every limit here.
public enum FreeTier {
    public static let practiceSessionsPerDay = 3
    public static let aiRequestsPerDay = 3

    /// Illustrations tagged B1 and above are Premium; untagged, A1 and A2 stay free.
    public static func isIllustrationFree(tags: [String]) -> Bool {
        !tags.contains { ["b1", "b2", "c1", "c2"].contains($0.lowercased()) }
    }
}

/// A per-day usage counter that resets on the next calendar day.
public struct DailyQuota: Codable, Equatable, Sendable {
    public var day: Date
    public var used: Int

    public init(day: Date = .distantPast, used: Int = 0) {
        self.day = day
        self.used = used
    }

    public func remaining(limit: Int, now: Date = .now, calendar: Calendar = .current) -> Int {
        calendar.isDate(day, inSameDayAs: now) ? max(0, limit - used) : limit
    }

    /// Uses one slot if any are left today.
    public mutating func consume(limit: Int, now: Date = .now, calendar: Calendar = .current) -> Bool {
        if !calendar.isDate(day, inSameDayAs: now) { day = now; used = 0 }
        guard used < limit else { return false }
        used += 1
        return true
    }
}
