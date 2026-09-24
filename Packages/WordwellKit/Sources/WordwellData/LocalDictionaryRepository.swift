import Foundation
import SQLite3
import WordwellDomain

private final class SQLiteConnection: @unchecked Sendable {
    let handle: OpaquePointer

    init(_ handle: OpaquePointer) { self.handle = handle }
    deinit { sqlite3_close(handle) }
}

public actor LocalDictionaryRepository: DictionaryRepository {
    private let database: SQLiteConnection
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    public init(databaseURL: URL) throws {
        var handle: OpaquePointer?
        guard sqlite3_open_v2(databaseURL.path, &handle, SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX, nil) == SQLITE_OK,
              let handle else {
            if let handle { sqlite3_close(handle) }
            throw DictionaryRepositoryError.invalidDatabase
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, "SELECT 1 FROM entries LIMIT 1", -1, &statement, nil) == SQLITE_OK,
              sqlite3_step(statement) == SQLITE_ROW else {
            sqlite3_finalize(statement)
            sqlite3_close(handle)
            throw DictionaryRepositoryError.invalidDatabase
        }
        sqlite3_finalize(statement)
        database = SQLiteConnection(handle)
    }

    public init() throws {
        guard let url = Bundle.module.url(forResource: "Dictionary", withExtension: "sqlite") else {
            throw DictionaryRepositoryError.notConfigured
        }
        try self.init(databaseURL: url)
    }

    public func search(_ query: String, limit: Int) throws -> [WordSummary] {
        try Task.checkCancellation()
        let tokens = query.split(whereSeparator: { !$0.isLetter && !$0.isNumber })
        guard !tokens.isEmpty, limit > 0 else { return [] }
        let expression = tokens.map { "\"\($0)\"*" }.joined(separator: " ")
        let key = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return try rows(
            """
            SELECT e.id, e.word, e.pos, e.preview
            FROM entry_search s JOIN entries e ON e.id = s.id
            WHERE entry_search MATCH ?
            ORDER BY CASE WHEN e.word_key = ? THEN 0
                          WHEN e.word_key >= ? AND e.word_key < ? THEN 1 ELSE 2 END,
                     bm25(entry_search, 0.0, 8.0, 5.0, 1.0), e.word_key, e.pos
            LIMIT ?
            """,
            strings: [expression, key, key, key + "\u{10ffff}"], limit: limit
        ) { statement in
            WordSummary(
                id: Self.string(statement, 0), word: Self.string(statement, 1),
                partOfSpeech: PartOfSpeech(rawValue: Self.string(statement, 2))!,
                previewDefinition: Self.string(statement, 3)
            )
        }
    }

    public func suggestions(prefix: String, limit: Int) throws -> [String] {
        try Task.checkCancellation()
        let key = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !key.isEmpty, limit > 0 else { return [] }
        return try rows(
            "SELECT DISTINCT word FROM entries WHERE word_key >= ? AND word_key < ? ORDER BY word_key LIMIT ?",
            strings: [key, key + "\u{10ffff}"], limit: limit
        ) { Self.string($0, 0) }
    }

    public func entry(id: String) throws -> WordEntry? {
        try entry(sql: "SELECT payload FROM entries WHERE id = ?", key: id)
    }

    public func entry(lemma: String) throws -> WordEntry? {
        try entry(
            sql: "SELECT payload FROM entries WHERE word_key = ? ORDER BY CASE pos WHEN 'noun' THEN 0 WHEN 'verb' THEN 1 WHEN 'adjective' THEN 2 ELSE 3 END, id LIMIT 1",
            key: lemma.lowercased()
        )
    }

    public func featuredEntry(excluding wordID: String?) throws -> WordEntry? {
        try Task.checkCancellation()
        let ids = try rows(
            """
            SELECT id FROM entries
            WHERE word NOT GLOB '*[^a-z]*' AND length(word) BETWEEN 4 AND 10
              AND pos IN ('noun', 'verb', 'adjective')
              AND word_key <> COALESCE((SELECT word_key FROM entries WHERE id = ?), '')
            ORDER BY random() LIMIT 1
            """,
            strings: [wordID ?? ""]
        ) { Self.string($0, 0) }
        guard let id = ids.first else { return nil }
        return try entry(id: id)
    }

    public func notificationEntries(excluding wordIDs: Set<String>, limit: Int) throws -> [WordEntry] {
        guard limit > 0 else { return [] }
        let payloads = try rows(
            """
            SELECT payload FROM entries
            WHERE word NOT GLOB '*[^a-z]*' AND length(word) BETWEEN 4 AND 10
              AND pos IN ('noun', 'verb', 'adjective')
              AND (json_extract(payload, '$.ipaUK') IS NOT NULL OR json_extract(payload, '$.ipaUS') IS NOT NULL)
            ORDER BY random() LIMIT ?
            """,
            strings: [], limit: min(500, max(100, limit * 5))
        ) { Self.string($0, 0) }
        var seen = Set<String>()
        var entries: [WordEntry] = []
        for payload in payloads {
            guard let data = payload.data(using: .utf8),
                  let entry = try? JSONDecoder().decode(WordEntry.self, from: data),
                  !wordIDs.contains(entry.id), !wordIDs.contains(entry.lemma.lowercased()),
                  seen.insert(entry.lemma.lowercased()).inserted else { continue }
            entries.append(entry)
            if entries.count == limit { break }
        }
        return entries
    }

    private func entry(sql: String, key: String) throws -> WordEntry? {
        let payloads = try rows(sql, strings: [key]) { Self.string($0, 0) }
        guard let payload = payloads.first, let data = payload.data(using: .utf8) else { return nil }
        do { return try JSONDecoder().decode(WordEntry.self, from: data) }
        catch { throw DictionaryRepositoryError.invalidDatabase }
    }

    private func rows<T>(
        _ sql: String, strings: [String], limit: Int? = nil,
        transform: (OpaquePointer) -> T
    ) throws -> [T] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database.handle, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else { throw DictionaryRepositoryError.queryFailed }
        defer { sqlite3_finalize(statement) }
        for (index, value) in strings.enumerated() {
            guard sqlite3_bind_text(statement, Int32(index + 1), value, -1, transient) == SQLITE_OK else {
                throw DictionaryRepositoryError.queryFailed
            }
        }
        if let limit {
            guard sqlite3_bind_int(statement, Int32(strings.count + 1), Int32(min(limit, 500))) == SQLITE_OK else {
                throw DictionaryRepositoryError.queryFailed
            }
        }
        var result: [T] = []
        while true {
            try Task.checkCancellation()
            switch sqlite3_step(statement) {
            case SQLITE_ROW: result.append(transform(statement))
            case SQLITE_DONE: return result
            default: throw DictionaryRepositoryError.queryFailed
            }
        }
    }

    private static func string(_ statement: OpaquePointer, _ column: Int32) -> String {
        guard let value = sqlite3_column_text(statement, column) else { return "" }
        return String(cString: value)
    }
}
