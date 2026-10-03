import Foundation
import WordwellAICore

/// JSON file store for the CLI. In the app the notebook lives in SwiftData behind the same `[MistakeRecord]` model.
struct MistakeNotebookStore {
    let url: URL

    init(path: String?) {
        if let path {
            url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
        } else {
            url = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".wordwell-ai", isDirectory: true)
                .appendingPathComponent("mistakes.json")
        }
    }

    func load() throws -> [MistakeRecord] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([MistakeRecord].self, from: Data(contentsOf: url))
    }

    func save(_ records: [MistakeRecord]) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(records).write(to: url, options: .atomic)
    }

    func append(_ newRecords: [MistakeRecord]) throws {
        try save(try load() + newRecords)
    }
}
