#if canImport(SwiftData)
import Foundation
import SwiftData
import WordwellAICore

/// SwiftData-backed notebook. All work runs on the actor's own `ModelContext`, off the main thread.
/// Expansion of `@ModelActor` written out by hand so the initialiser stays `public`.
@available(iOS 17.0, macOS 14.0, *)
public actor SwiftDataMistakeNotebook: ModelActor, MistakeNotebook {
    public nonisolated let modelContainer: ModelContainer
    public nonisolated let modelExecutor: any ModelExecutor

    public init(modelContainer: ModelContainer) {
        let context = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: context)
        self.modelContainer = modelContainer
    }

    /// Local-only store. CloudKit is off on purpose: the notebook holds learner sentences, and
    /// `@Attribute(.unique)` is not supported with CloudKit sync. If the app already owns a container,
    /// add `MistakeEntity.self` to its schema instead of using this one.
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: MistakeEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        )
    }

    public func records(since date: Date? = nil) throws -> [MistakeRecord] {
        var descriptor = FetchDescriptor<MistakeEntity>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        if let date {
            descriptor.predicate = #Predicate<MistakeEntity> { $0.date >= date }
        }
        return try modelContext.fetch(descriptor).map(\.record)
    }

    /// An existing `id` is updated in place (unique attribute), never duplicated.
    public func add(_ records: [MistakeRecord]) throws {
        for record in records { modelContext.insert(MistakeEntity(record)) }
        try modelContext.save()
    }

    public func removeAll() throws {
        try modelContext.delete(model: MistakeEntity.self)
        try modelContext.save()
    }

    /// Keeps the store small: the analyzer only looks at a few weeks anyway.
    public func prune(olderThan cutoff: Date) throws {
        try modelContext.delete(model: MistakeEntity.self, where: #Predicate<MistakeEntity> { $0.date < cutoff })
        try modelContext.save()
    }

    public func count() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<MistakeEntity>())
    }
}
#endif
