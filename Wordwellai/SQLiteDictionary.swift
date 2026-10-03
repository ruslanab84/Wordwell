#if canImport(SQLite3)
import Foundation
import WordwellAICore

public enum SQLiteDictionaryError: Error, Equatable {
    /// The file was built with another schema version. Rebuild it with the matching builder.
    case incompatibleSchema(found: Int, expected: Int)
}

/// Read-only dictionary over the bundled SQLite file.
/// Serves both AI protocols: `AIDictionaryLookup` (verification, quiz distractors) and
/// `DefinitionSearching` (FTS5 + bm25 retrieval for reverse lookup).
public actor SQLiteDictionary: AIDictionaryLookup, DefinitionSearching {
    private let connection: SQLiteConnection
    private let decoder = JSONDecoder()

    public init(url: URL) throws {
        let connection = try SQLiteConnection(path: url.path, readOnly: true)
        let found = try connection.userVersion()
        guard found == DictionarySchema.version else {
            connection.close()
            throw SQLiteDictionaryError.incompatibleSchema(found: found, expected: DictionarySchema.version)
        }
        self.connection = connection
    }

    public func entryCount() throws -> Int {
        let statement = try connection.cached(DictionarySchema.count)
        defer { statement.reset() }
        return try statement.step() ? (statement.int(0) ?? 0) : 0
    }

    // MARK: AIDictionaryLookup

    public func wordContext(for lemma: String) async throws -> AIWordContext? {
        let statement = try connection.cached(DictionarySchema.lookup)
        defer { statement.reset() }
        try statement.bind(1, text: lemma.lowercased())
        guard try statement.step(), let data = statement.data(0) else { return nil }
        return try decoder.decode(AIWordContext.self, from: data)
    }

    /// Same part of speech, CEFR within one level of the target. Order is a stable hash of
    /// (target, candidate): the same question always gets the same options, different words get different ones.
    public func distractors(for lemma: String, level: CEFRLevel?, limit: Int) async throws -> [String] {
        guard limit > 0, let word = try await wordContext(for: lemma) else { return [] }
        let target = (level ?? word.cefrLevel ?? .b1).index
        let key = lemma.lowercased()

        let statement = try connection.cached(DictionarySchema.distractorPool)
        defer { statement.reset() }
        try statement.bind(1, text: word.partOfSpeech)
        try statement.bind(2, text: key)
        try statement.bind(3, int: target)

        var pool: [(lemma: String, distance: Int)] = []
        while try statement.step() {
            guard let candidate = statement.text(0) else { continue }
            pool.append((candidate, abs((statement.int(1) ?? 2) - target)))
        }
        return pool
            .sorted { lhs, rhs in
                if lhs.distance != rhs.distance { return lhs.distance < rhs.distance }
                return Self.stableHash(key + "|" + lhs.lemma) < Self.stableHash(key + "|" + rhs.lemma)
            }
            .prefix(limit)
            .map { $0.lemma }
    }

    // MARK: DefinitionSearching

    public func candidates(matching query: String, limit: Int) async throws -> [AIWordContext] {
        guard limit > 0, let match = FTSQuery.match(for: query) else { return [] }
        let statement = try connection.cached(DictionarySchema.search)
        defer { statement.reset() }
        try statement.bind(1, text: match)
        try statement.bind(2, int: limit)

        var result: [AIWordContext] = []
        while try statement.step() {
            if let data = statement.data(0) { result.append(try decoder.decode(AIWordContext.self, from: data)) }
        }
        return result
    }

    /// FNV-1a. `String.hashValue` is randomised per process and would break reproducibility.
    static func stableHash(_ text: String) -> UInt64 {
        text.utf8.reduce(14_695_981_039_346_656_037) { ($0 ^ UInt64($1)) &* 1_099_511_628_211 }
    }
}
#endif
