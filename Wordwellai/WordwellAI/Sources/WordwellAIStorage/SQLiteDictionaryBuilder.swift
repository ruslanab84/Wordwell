#if canImport(SQLite3)
import Foundation
import WordwellAICore

public enum SQLiteDictionaryBuilder {
    /// Writes a fresh dictionary database. The file is built next to the target and moved into place,
    /// so a failed build never leaves a half-written database. Duplicate lemmas keep the first entry.
    public static func build(entries: [AIWordContext], to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let temporary = directory.appendingPathComponent(".\(url.lastPathComponent).\(UUID().uuidString).tmp")
        defer { try? FileManager.default.removeItem(at: temporary) }

        let connection = try SQLiteConnection(path: temporary.path, readOnly: false)
        try connection.execute(DictionarySchema.create)
        try connection.execute("BEGIN")

        let insertEntry = try connection.prepare(DictionarySchema.insertEntry)
        let insertFTS = try connection.prepare(DictionarySchema.insertFTS)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        var seen = Set<String>()
        for entry in entries {
            let lemma = entry.lemma.lowercased()
            guard !lemma.isEmpty, seen.insert(lemma).inserted else { continue }

            try insertEntry.bind(1, text: lemma)
            try insertEntry.bind(2, text: entry.partOfSpeech)
            try insertEntry.bind(3, int: entry.cefrLevel?.index)
            try insertEntry.bind(4, blob: try encoder.encode(entry))
            _ = try insertEntry.step()
            insertEntry.reset()

            try insertFTS.bind(1, text: lemma)
            try insertFTS.bind(2, text: entry.senses.map(\.definition).joined(separator: " "))
            try insertFTS.bind(3, text: entry.collocations.joined(separator: "; "))
            try insertFTS.bind(4, text: entry.forms.joined(separator: " "))
            _ = try insertFTS.step()
            insertFTS.reset()
        }

        try connection.execute("COMMIT")
        try connection.execute("INSERT INTO entry_fts(entry_fts) VALUES('optimize')")
        try connection.execute("PRAGMA user_version = \(DictionarySchema.version)")
        connection.close()

        if FileManager.default.fileExists(atPath: url.path) {
            _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
        } else {
            try FileManager.default.moveItem(at: temporary, to: url)
        }
    }
}
#endif
