import Foundation

/// Groups the mistakes notebook into ranked patterns. Pure and deterministic.
public struct MistakePatternAnalyzer: Sendable {
    public var windowDays: Int
    public var halfLifeDays: Double
    /// Occurrences inside the window needed before a pattern deserves a lesson.
    public var minOccurrences: Int
    public var maxExamples: Int

    public init(windowDays: Int = 28, halfLifeDays: Double = 14, minOccurrences: Int = 3, maxExamples: Int = 3) {
        self.windowDays = max(1, windowDays)
        self.halfLifeDays = max(1, halfLifeDays)
        self.minOccurrences = max(1, minOccurrences)
        self.maxExamples = max(1, maxExamples)
    }

    public func analyze(_ records: [MistakeRecord], now: Date = Date()) -> [PatternStat] {
        let day: TimeInterval = 86_400
        let windowStart = now.addingTimeInterval(-Double(windowDays) * day)

        let inWindow = records.filter { $0.date >= windowStart && $0.date <= now }
        let grouped = Dictionary(grouping: inWindow, by: \.pattern)

        let stats = grouped.map { pattern, items -> PatternStat in
            let weight = items.reduce(0.0) { sum, record in
                let ageDays = now.timeIntervalSince(record.date) / day
                return sum + pow(0.5, ageDays / halfLifeDays)
            }
            let recent = items.filter { now.timeIntervalSince($0.date) <= 7 * day }.count

            var seen = Set<String>()
            let examples = items
                .sorted { $0.date > $1.date }
                .filter { seen.insert(($0.wrong + "|" + $0.right).normalizedForComparison).inserted }
                .prefix(maxExamples)

            return PatternStat(pattern: pattern, total: items.count, recent: recent, weight: weight, examples: Array(examples))
        }

        return stats.sorted {
            if $0.weight != $1.weight { return $0.weight > $1.weight }
            if $0.total != $1.total { return $0.total > $1.total }
            return $0.pattern.rawValue < $1.pattern.rawValue
        }
    }

    /// The pattern to teach this week: highest weight among known patterns with enough evidence.
    public func lessonCandidate(in stats: [PatternStat]) -> PatternStat? {
        stats.first { $0.pattern != .other && $0.total >= minOccurrences }
    }
}
