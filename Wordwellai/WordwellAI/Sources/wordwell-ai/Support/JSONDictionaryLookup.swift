import ArgumentParser
import Foundation
import WordwellAICore

/// File-backed dictionary for the CLI. In the app, `DictionaryRepository` (SQLite/FTS) plays this role.
struct JSONDictionaryLookup: AIDictionaryLookup {
    private struct DictionaryFile: Decodable {
        let entries: [AIWordContext]
    }

    let entries: [String: AIWordContext]

    static func load(path: String?) throws -> JSONDictionaryLookup {
        let url: URL
        if let path {
            url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
        } else if let bundled = Bundle.module.url(forResource: "seed-dictionary", withExtension: "json") {
            url = bundled
        } else {
            throw ValidationError("Bundled seed dictionary not found.")
        }
        let file = try JSONDecoder().decode(DictionaryFile.self, from: Data(contentsOf: url))
        let pairs = file.entries.map { ($0.lemma.lowercased(), $0) }
        return JSONDictionaryLookup(entries: Dictionary(pairs, uniquingKeysWith: { first, _ in first }))
    }

    var allLemmas: [String] { entries.keys.sorted() }

    func wordContext(for lemma: String) async throws -> AIWordContext? {
        entries[lemma.lowercased()]
    }

    func distractors(for lemma: String, level: CEFRLevel?, limit: Int) async throws -> [String] {
        guard let word = entries[lemma.lowercased()] else { return [] }
        let target = (level ?? word.cefrLevel ?? .b1).index

        func distance(_ entry: AIWordContext) -> Int {
            abs((entry.cefrLevel ?? .b1).index - target)
        }

        return entries.values
            .filter { $0.lemma != word.lemma && $0.partOfSpeech == word.partOfSpeech }
            .sorted { (distance($0), $0.lemma) < (distance($1), $1.lemma) }
            .prefix(limit)
            .map(\.lemma)
    }
}
