#if canImport(SQLite3)
import Foundation
import WordwellAICore

/// One read-only SQLite file: `entry` (lookup by lemma) and `entry_fts` (FTS5, porter stemming).
/// Build it offline with `SQLiteDictionaryBuilder` (or `wordwell-ai db build`) and ship it in the app bundle.
enum DictionarySchema {
    /// Stored in `PRAGMA user_version`. Bump when the layout changes.
    static let version = 1

    static let create = """
    CREATE TABLE entry(
        lemma TEXT PRIMARY KEY,
        pos TEXT NOT NULL,
        cefr INTEGER,
        payload BLOB NOT NULL
    ) WITHOUT ROWID;
    CREATE INDEX entry_pos ON entry(pos, cefr);
    CREATE VIRTUAL TABLE entry_fts USING fts5(
        lemma, definitions, collocations, forms,
        tokenize = 'porter unicode61'
    );
    """

    static let insertEntry = "INSERT INTO entry(lemma, pos, cefr, payload) VALUES (?1, ?2, ?3, ?4)"
    static let insertFTS = "INSERT INTO entry_fts(lemma, definitions, collocations, forms) VALUES (?1, ?2, ?3, ?4)"

    static let lookup = "SELECT payload FROM entry WHERE lemma = ?1"

    /// bm25 weights follow the FTS column order: lemma, definitions, collocations, forms.
    static let search = """
    SELECT entry.payload FROM entry_fts
    JOIN entry ON entry.lemma = entry_fts.lemma
    WHERE entry_fts MATCH ?1
    ORDER BY bm25(entry_fts, 8.0, 2.0, 1.0, 1.0), entry.lemma
    LIMIT ?2
    """

    static let distractorPool = """
    SELECT lemma, COALESCE(cefr, 2) FROM entry
    WHERE pos = ?1 AND lemma != ?2 AND abs(COALESCE(cefr, 2) - ?3) <= 1
    ORDER BY lemma
    LIMIT 400
    """

    static let count = "SELECT COUNT(*) FROM entry"
}

/// Builds the FTS `MATCH` expression from free text. Only quoted letter-only words are emitted,
/// so user input can never inject FTS operators (`NEAR`, `col:`, `*`, unbalanced quotes).
enum FTSQuery {
    static let maxTerms = 12

    static func match(for query: String) -> String? {
        let words = QueryTerms.searchWords(query).prefix(maxTerms)
        guard !words.isEmpty else { return nil }
        return words.map { "\"\($0)\"" }.joined(separator: " OR ")
    }
}
#endif
