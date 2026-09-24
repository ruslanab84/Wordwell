import Foundation
import WordwellDomain

public enum DailyWordsError: Error, Sendable {
    case insufficientWords
    case unavailable
    case invalidSelection
}

public struct DailyWordsSnapshot: Sendable {
    public let words: [WordEntry]
    public let learnedIDs: Set<String>
    public let goal: Int

    public var learnedCount: Int { learnedIDs.count }
}

public actor LocalDailyWordsService {
    private struct DayRecord: Codable {
        let date: Date
        let goal: Int
        let wordIDs: [String]
        var learnedIDs: Set<String>
    }

    private let dictionary: any DictionaryRepository
    private let library: any WordLibraryRepository
    private let defaults: UserDefaults
    private let planKey = "wordwell.dailyWords.plan"
    private let historyKey = "wordwell.dailyWords.history"

    public init(dictionary: any DictionaryRepository, library: any WordLibraryRepository,
                suiteName: String? = nil) {
        self.dictionary = dictionary
        self.library = library
        defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    public func today(goal: Int, on date: Date = .now) async throws -> DailyWordsSnapshot {
        guard (1...20).contains(goal) else { throw DailyWordsError.invalidSelection }
        if let record = try storedRecord(), Calendar.current.isDate(record.date, inSameDayAs: date) {
            return try await snapshot(for: record)
        }

        let saved = try await library.allSavedWords()
        var excluded = Set(defaults.stringArray(forKey: historyKey) ?? [])
        excluded.formUnion(saved.map(\.wordID))
        let words = try await dictionary.notificationEntries(excluding: excluded, limit: goal)
        guard words.count == goal else { throw DailyWordsError.insufficientWords }
        if let record = try storedRecord(),
           Calendar.current.isDate(record.date, inSameDayAs: date) || record.date > date {
            return try await snapshot(for: record)
        }

        let record = DayRecord(date: date, goal: goal, wordIDs: words.map(\.id), learnedIDs: [])
        try store(record)
        defaults.set(Array((defaults.stringArray(forKey: historyKey) ?? [])
            .suffix(200 - goal)) + words.map { $0.lemma.lowercased() }, forKey: historyKey)
        return DailyWordsSnapshot(words: words, learnedIDs: [], goal: goal)
    }

    public func markLearned(_ wordID: String, on date: Date = .now) async throws -> DailyWordsSnapshot {
        guard let record = try storedRecord(), Calendar.current.isDate(record.date, inSameDayAs: date),
              record.wordIDs.contains(wordID) else { throw DailyWordsError.invalidSelection }
        if !record.learnedIDs.contains(wordID) {
            try await library.save(wordID: wordID)
            guard var latest = try storedRecord(), Calendar.current.isDate(latest.date, inSameDayAs: date) else {
                throw DailyWordsError.invalidSelection
            }
            latest.learnedIDs.insert(wordID)
            try store(latest)
            return try await snapshot(for: latest)
        }
        return try await snapshot(for: record)
    }

    private func storedRecord() throws -> DayRecord? {
        guard let data = defaults.data(forKey: planKey) else { return nil }
        return try JSONDecoder().decode(DayRecord.self, from: data)
    }

    private func store(_ record: DayRecord) throws {
        defaults.set(try JSONEncoder().encode(record), forKey: planKey)
    }

    private func snapshot(for record: DayRecord) async throws -> DailyWordsSnapshot {
        var words: [WordEntry] = []
        for id in record.wordIDs {
            guard let word = try await dictionary.entry(id: id) else { throw DailyWordsError.unavailable }
            words.append(word)
        }
        return DailyWordsSnapshot(words: words, learnedIDs: record.learnedIDs, goal: record.goal)
    }
}
