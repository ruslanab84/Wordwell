import ArgumentParser
import Foundation
import WordwellAICore
import WordwellAIStorage

struct Database: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "db",
        abstract: "SQLite FTS5 dictionary, the same adapter the app ships: build and search.",
        discussion: "Build a file from the JSON dictionary, then pass it to `find --db` or `story --db`.",
        subcommands: [DatabaseBuild.self, DatabaseSearch.self]
    )
}

struct DatabaseBuild: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "build", abstract: "Build dictionary.sqlite from the JSON dictionary.")

    @Option(help: "Dictionary JSON file. Defaults to the bundled seed dictionary.") var dictionary: String?
    @Option(name: [.short, .long], help: "Output file.") var output = "dictionary.sqlite"

    func run() throws {
        let entries = try JSONDictionaryLookup.load(path: dictionary).entries.values.sorted { $0.lemma < $1.lemma }
        let url = URL(fileURLWithPath: (output as NSString).expandingTildeInPath)
        try SQLiteDictionaryBuilder.build(entries: entries, to: url)
        print("Built \(url.path): \(entries.count) entries")
    }
}

struct DatabaseSearch: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "search", abstract: "Search definitions with FTS5 (bm25 ranking).")

    @Argument(help: "Words from the definition you remember.") var query: String
    @Option(help: "Database built with `db build`.") var db = "dictionary.sqlite"
    @Option(help: "Maximum results.") var limit = 5

    func run() async throws {
        let store = try SQLiteDictionary(url: URL(fileURLWithPath: (db as NSString).expandingTildeInPath))
        let words = try await store.candidates(matching: query, limit: limit)
        guard !words.isEmpty else {
            print("No matches.")
            return
        }
        for (index, word) in words.enumerated() {
            print("\(index + 1). \(word.lemma) (\(word.partOfSpeech)) — \(word.senses.first?.definition ?? "")")
        }
    }
}
