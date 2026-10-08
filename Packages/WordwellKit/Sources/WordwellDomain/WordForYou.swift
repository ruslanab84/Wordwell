import Foundation

public struct WordForYouSignals: Sendable {
    public var weakIDs: [String]
    public var viewedIDs: [String]
    public var savedIDs: Set<String>
    public var masteredIDs: Set<String>
    public var topicID: String?
    /// Calendar day, e.g. "20261008"; the same day always yields the same order.
    public var dayKey: String

    public init(weakIDs: [String] = [], viewedIDs: [String] = [], savedIDs: Set<String> = [],
                masteredIDs: Set<String> = [], topicID: String? = nil, dayKey: String) {
        self.weakIDs = weakIDs
        self.viewedIDs = viewedIDs
        self.savedIDs = savedIDs
        self.masteredIDs = masteredIDs
        self.topicID = topicID
        self.dayKey = dayKey
    }
}

public struct WordForYouCandidate: Equatable, Sendable {
    public let wordID: String
    public let topicID: String
    public let reason: String
}

/// Deterministic "Word for You" ranking over the curated topic lists (spec §13). No AI involved.
public enum WordForYou {
    public static func candidates(_ signals: WordForYouSignals, topics: [VocabularyTopic] = VocabularyTopic.all) -> [WordForYouCandidate] {
        let pool = signals.topicID.map { id in topics.filter { $0.id == id } } ?? topics
        let weak = Set(signals.weakIDs)
        let viewed = Set(signals.viewedIDs)
        let skip = signals.savedIDs.union(signals.masteredIDs).union(weak)

        var result: [WordForYouCandidate] = []
        let scored = pool.enumerated().map { index, topic -> (Int, Int, VocabularyTopic, Bool) in
            let ids = Set(topic.wordIDs)
            let weakCount = ids.intersection(weak).count
            let score = 2 * weakCount + ids.intersection(viewed).count + ids.intersection(signals.savedIDs).count
            return (score, index, topic, weakCount > 0)
        }
        for (_, _, topic, hasWeak) in scored.filter({ $0.0 > 0 }).sorted(by: { ($1.0, $0.1) < ($0.0, $1.1) }) {
            let reason = hasWeak ? "Near words you missed in Quiz · \(topic.title)"
                                 : "Because you've been exploring \(topic.title)"
            let words = topic.wordIDs.filter { !skip.contains($0) }
                .sorted { (fnv("\(signals.dayKey)|\($0)"), $0) < (fnv("\(signals.dayKey)|\($1)"), $1) }
            result += words.map { WordForYouCandidate(wordID: $0, topicID: topic.id, reason: reason) }
        }
        return result
    }

    /// Entries without a CEFR level always pass; known ones may be at most one step above the learner.
    public static func isWithinReach(_ entry: CEFRLevel?, learner: CEFRLevel) -> Bool {
        guard let entry,
              let e = CEFRLevel.allCases.firstIndex(of: entry),
              let l = CEFRLevel.allCases.firstIndex(of: learner) else { return true }
        return e <= l + 1
    }

    // FNV-1a: Hasher is randomly seeded per launch, which would reshuffle the word on every start.
    private static func fnv(_ text: String) -> UInt64 {
        text.utf8.reduce(14695981039346656037) { ($0 ^ UInt64($1)) &* 1099511628211 }
    }
}
