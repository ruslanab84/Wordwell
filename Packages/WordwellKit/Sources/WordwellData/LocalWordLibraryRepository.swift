import Foundation
import SwiftData
import WordwellDomain

public enum WordLibraryError: Error, Equatable, Sendable {
    case unavailable
    case invalidCollectionName
    case duplicateCollectionName
}

@Model
private final class LibraryRecord {
    @Attribute(.unique) var wordID: String
    var stateData: Data?
    var savedAt: Date?
    var viewedAt: Date?

    init(wordID: String) {
        self.wordID = wordID
    }
}

@Model
private final class CollectionRecord {
    @Attribute(.unique) var id: String
    var name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public actor LocalWordLibraryRepository: WordLibraryRepository {
    private let context: ModelContext

    public init(inMemory: Bool = false) throws {
        let schema = Schema([LibraryRecord.self, CollectionRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: schema, configurations: configuration)
        context = ModelContext(container)
    }

    public func save(wordID: String) throws {
        let record = try record(for: wordID) ?? LibraryRecord(wordID: wordID)
        if record.modelContext == nil { context.insert(record) }
        if record.stateData == nil {
            record.stateData = try JSONEncoder().encode(UserWordState(wordID: wordID))
            record.savedAt = .now
            try context.save()
        }
    }

    public func remove(wordID: String) throws {
        guard let record = try record(for: wordID), record.stateData != nil else { return }
        record.stateData = nil
        record.savedAt = nil
        if record.viewedAt == nil { context.delete(record) }
        try context.save()
    }

    public func state(for wordID: String) throws -> UserWordState? {
        guard let data = try record(for: wordID)?.stateData else { return nil }
        return try JSONDecoder().decode(UserWordState.self, from: data)
    }

    public func allSavedWords() throws -> [UserWordState] {
        // ponytail: fetch all local records; add a filtered query if libraries grow large enough to measure a delay.
        try context.fetch(FetchDescriptor<LibraryRecord>())
            .filter { $0.stateData != nil }
            .sorted { ($0.savedAt ?? .distantPast) > ($1.savedAt ?? .distantPast) }
            .compactMap { try $0.stateData.map { try JSONDecoder().decode(UserWordState.self, from: $0) } }
    }

    public func update(_ state: UserWordState) throws {
        let record = try record(for: state.wordID) ?? LibraryRecord(wordID: state.wordID)
        if record.modelContext == nil { context.insert(record) }
        record.stateData = try JSONEncoder().encode(state)
        if record.savedAt == nil { record.savedAt = .now }
        try context.save()
    }

    public func recordViewed(wordID: String) throws {
        let record = try record(for: wordID) ?? LibraryRecord(wordID: wordID)
        if record.modelContext == nil { context.insert(record) }
        record.viewedAt = .now
        try context.save()
    }

    public func recentlyViewedWordIDs(limit: Int) throws -> [String] {
        guard limit > 0 else { return [] }
        return try context.fetch(FetchDescriptor<LibraryRecord>())
            .filter { $0.viewedAt != nil }
            .sorted { ($0.viewedAt ?? .distantPast) > ($1.viewedAt ?? .distantPast) }
            .prefix(limit)
            .map(\.wordID)
    }

    public func collections() throws -> [WordCollection] {
        try context.fetch(FetchDescriptor<CollectionRecord>())
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .map { WordCollection(id: $0.id, name: $0.name) }
    }

    public func createCollection(named name: String) throws -> WordCollection {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw WordLibraryError.invalidCollectionName }
        let existing = try context.fetch(FetchDescriptor<CollectionRecord>())
        guard !existing.contains(where: { $0.name.compare(trimmed, options: .caseInsensitive) == .orderedSame }) else {
            throw WordLibraryError.duplicateCollectionName
        }
        let collection = WordCollection(id: UUID().uuidString, name: trimmed)
        context.insert(CollectionRecord(id: collection.id, name: collection.name))
        try context.save()
        return collection
    }

    private func record(for wordID: String) throws -> LibraryRecord? {
        var descriptor = FetchDescriptor<LibraryRecord>(predicate: #Predicate { $0.wordID == wordID })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }
}

public struct UnavailableWordLibraryRepository: WordLibraryRepository {
    public init() {}
    public func save(wordID: String) throws { throw WordLibraryError.unavailable }
    public func remove(wordID: String) throws { throw WordLibraryError.unavailable }
    public func state(for wordID: String) throws -> UserWordState? { throw WordLibraryError.unavailable }
    public func allSavedWords() throws -> [UserWordState] { throw WordLibraryError.unavailable }
    public func update(_ state: UserWordState) throws { throw WordLibraryError.unavailable }
    public func recordViewed(wordID: String) throws { throw WordLibraryError.unavailable }
    public func recentlyViewedWordIDs(limit: Int) throws -> [String] { throw WordLibraryError.unavailable }
    public func collections() throws -> [WordCollection] { throw WordLibraryError.unavailable }
    public func createCollection(named name: String) throws -> WordCollection { throw WordLibraryError.unavailable }
}
