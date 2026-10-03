#if canImport(SQLite3)
import XCTest
import WordwellAICore
@testable import WordwellAIStorage

final class SQLiteDictionaryTests: XCTestCase {
    private var url: URL!

    private static func word(_ lemma: String, _ pos: String, _ level: CEFRLevel?, _ definition: String,
                             collocations: [String] = [], forms: [String] = []) -> AIWordContext {
        AIWordContext(lemma: lemma, partOfSpeech: pos, cefrLevel: level,
                      senses: [.init(id: "s1", definition: definition, example: "Example for \(lemma).")],
                      collocations: collocations, forms: forms)
    }

    private static let entries: [AIWordContext] = [
        word("vertigo", "noun", .c1, "a feeling of dizziness caused by looking down from a great height, or a fear of heights"),
        word("acrophobia", "noun", .c2, "an extreme fear of high places"),
        word("luggage", "noun", .a2, "the bags and cases that you take with you when you travel", collocations: ["hand luggage"]),
        word("complain", "verb", .b1, "to say that you are not satisfied with something", forms: ["complains", "complained", "complaining"]),
        word("arrive", "verb", .a2, "to reach a place at the end of a journey", forms: ["arrives", "arrived", "arriving"]),
        word("borrow", "verb", .a2, "to take something and give it back later", forms: ["borrows", "borrowed", "borrowing"]),
        word("lend", "verb", .a2, "to give something to someone for a short time", forms: ["lends", "lent", "lending"]),
        word("prefer", "verb", .a2, "to like one thing or person better than another"),
        word("unrated", "verb", nil, "a verb without a level"),
        word("Vertigo", "noun", .a1, "duplicate lemma that must be ignored"),
    ]

    override func setUpWithError() throws {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("dictionary-\(UUID().uuidString).sqlite")
        try SQLiteDictionaryBuilder.build(entries: Self.entries, to: url)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: url)
    }

    func test_buildKeepsFirstEntryOfDuplicateLemmas() async throws {
        let store = try SQLiteDictionary(url: url)
        let count = try await store.entryCount()
        XCTAssertEqual(count, Self.entries.count - 1)
        let vertigo = try await store.wordContext(for: "vertigo")
        XCTAssertEqual(vertigo?.cefrLevel, .c1)
    }

    func test_wordContextRoundTripAndCaseInsensitivity() async throws {
        let store = try SQLiteDictionary(url: url)
        let loaded = try await store.wordContext(for: "ARRIVE")
        XCTAssertEqual(loaded, Self.entries[4])
        let missing = try await store.wordContext(for: "zzz")
        XCTAssertNil(missing)
    }

    func test_ftsFindsWordsByDefinitionAndRanksBestFirst() async throws {
        let store = try SQLiteDictionary(url: url)
        let cases: [(String, String)] = [
            ("fear of heights", "vertigo"),
            ("a bag you take when travelling", "luggage"),
            ("to say you are not satisfied", "complain"),
            ("reach a place at the end of a journey", "arrive"),
            ("to like one thing better than another", "prefer"),
        ]
        for (query, expected) in cases {
            let found = try await store.candidates(matching: query, limit: 3)
            XCTAssertEqual(found.first?.lemma, expected, query)
        }
    }

    func test_ftsMatchesInflectedFormsViaPorterStemming() async throws {
        let store = try SQLiteDictionary(url: url)
        let found = try await store.candidates(matching: "arrived", limit: 3)
        XCTAssertEqual(found.first?.lemma, "arrive")
    }

    func test_limitAndEmptyQueries() async throws {
        let store = try SQLiteDictionary(url: url)
        let none = try await store.candidates(matching: "of the and", limit: 5)
        XCTAssertTrue(none.isEmpty, "only stopwords")
        let zero = try await store.candidates(matching: "fear", limit: 0)
        XCTAssertTrue(zero.isEmpty)
        let capped = try await store.candidates(matching: "give take fear place", limit: 2)
        XCTAssertLessThanOrEqual(capped.count, 2)
    }

    func test_hostileQueryNeverBreaksMatchSyntax() async throws {
        let store = try SQLiteDictionary(url: url)
        for query in ["fear\" OR heights", "NEAR(a b)", "col:x *", "a AND b NOT c", "\"unbalanced", "it's"] {
            _ = try await store.candidates(matching: query, limit: 3)
        }
        XCTAssertEqual(FTSQuery.match(for: "fear\" OR heights"), "\"fear\" OR \"heights\"")
        XCTAssertNil(FTSQuery.match(for: "   "))
    }

    func test_distractorsSamePartOfSpeechStableAndExcludeTarget() async throws {
        let store = try SQLiteDictionary(url: url)
        let first = try await store.distractors(for: "borrow", level: nil, limit: 2)
        let second = try await store.distractors(for: "borrow", level: nil, limit: 2)

        XCTAssertEqual(first, second, "same question, same options")
        XCTAssertEqual(first.count, 2)
        XCTAssertFalse(first.contains("borrow"))
        XCTAssertTrue(Set(first).isSubset(of: ["complain", "arrive", "lend", "prefer", "unrated"]), "verbs only: \(first)")
        let unknown = try await store.distractors(for: "zzz", level: nil, limit: 3)
        XCTAssertTrue(unknown.isEmpty)
    }

    func test_distractorsPreferCloserLevels() async throws {
        let store = try SQLiteDictionary(url: url)
        // Target B1 (complain): A2 verbs (distance 1) and the unrated one (treated as B1, distance 0) qualify; nothing else.
        let result = try await store.distractors(for: "complain", level: nil, limit: 1)
        XCTAssertEqual(result, ["unrated"])
    }

    func test_incompatibleSchemaVersionIsRejected() throws {
        let connection = try SQLiteConnection(path: url.path, readOnly: false)
        try connection.execute("PRAGMA user_version = 99")
        connection.close()

        XCTAssertThrowsError(try SQLiteDictionary(url: url)) { error in
            XCTAssertEqual(error as? SQLiteDictionaryError, .incompatibleSchema(found: 99, expected: DictionarySchema.version))
        }
    }

    func test_rebuildReplacesExistingFileAtomically() async throws {
        try SQLiteDictionaryBuilder.build(entries: [Self.entries[0]], to: url)
        let store = try SQLiteDictionary(url: url)
        let count = try await store.entryCount()
        XCTAssertEqual(count, 1)
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path)
            .filter { $0.hasSuffix(".tmp") && $0.contains(url.lastPathComponent) }
        XCTAssertTrue(leftovers.isEmpty)
    }

    func test_stableHashIsDeterministic() {
        XCTAssertEqual(SQLiteDictionary.stableHash("borrow|lend"), SQLiteDictionary.stableHash("borrow|lend"))
        XCTAssertNotEqual(SQLiteDictionary.stableHash("borrow|lend"), SQLiteDictionary.stableHash("borrow|arrive"))
    }
}
#endif
