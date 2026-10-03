import Foundation

/// Storage for the mistakes notebook. The app implements it with SwiftData
/// (`SwiftDataMistakeNotebook` in `WordwellAIStorage`); tests and previews use `InMemoryMistakeNotebook`.
/// Sentences are learner text: keep them on the device.
public protocol MistakeNotebook: Sendable {
    /// Newest first. `nil` returns everything.
    func records(since date: Date?) async throws -> [MistakeRecord]
    /// Records with an existing `id` are replaced, never duplicated.
    func add(_ records: [MistakeRecord]) async throws
    func removeAll() async throws
}

public actor InMemoryMistakeNotebook: MistakeNotebook {
    private var storage: [UUID: MistakeRecord] = [:]

    public init(_ records: [MistakeRecord] = []) {
        for record in records { storage[record.id] = record }
    }

    public func records(since date: Date? = nil) -> [MistakeRecord] {
        storage.values
            .filter { record in date.map { record.date >= $0 } ?? true }
            .sorted { $0.date > $1.date }
    }

    public func add(_ records: [MistakeRecord]) {
        for record in records { storage[record.id] = record }
    }

    public func removeAll() {
        storage.removeAll()
    }
}
