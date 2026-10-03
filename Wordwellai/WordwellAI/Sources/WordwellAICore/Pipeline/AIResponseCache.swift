import Foundation

public struct AICacheKey: Hashable, Sendable {
    public let task: AITask
    public let lemma: String
    public let level: CEFRLevel
    public let languageCode: String?
    public let promptVersion: String
    public let variant: String

    public init(task: AITask, lemma: String, level: CEFRLevel, languageCode: String?,
                promptVersion: String, variant: String = "") {
        self.task = task
        self.lemma = lemma.lowercased()
        self.level = level
        self.languageCode = languageCode
        self.promptVersion = promptVersion
        self.variant = variant
    }

    public var rawValue: String {
        [task.rawValue, lemma, level.rawValue, languageCode ?? "en", promptVersion, variant].joined(separator: "|")
    }
}

/// Backing store. The app can provide a SwiftData/file implementation for offline reuse.
public protocol AICacheStorage: Sendable {
    func data(for key: String) async -> Data?
    func store(_ data: Data, for key: String) async
    func removeAll() async
}

public actor InMemoryAICacheStorage: AICacheStorage {
    private let capacity: Int
    private var entries: [String: Data] = [:]
    private var order: [String] = []

    public init(capacity: Int = 200) {
        self.capacity = max(1, capacity)
    }

    public func data(for key: String) -> Data? {
        guard let value = entries[key] else { return nil }
        touch(key)
        return value
    }

    public func store(_ data: Data, for key: String) {
        entries[key] = data
        touch(key)
        while order.count > capacity {
            entries[order.removeFirst()] = nil
        }
    }

    public func removeAll() {
        entries.removeAll()
        order.removeAll()
    }

    private func touch(_ key: String) {
        order.removeAll { $0 == key }
        order.append(key)
    }
}

/// Typed facade. Cache hit = zero tokens, zero latency, works offline.
public struct AIResponseCache: Sendable {
    private let storage: any AICacheStorage

    public init(storage: any AICacheStorage) {
        self.storage = storage
    }

    public func value<T: Decodable>(_ type: T.Type, for key: AICacheKey) async -> T? {
        guard let data = await storage.data(for: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    public func store<T: Encodable>(_ value: T, for key: AICacheKey) async {
        guard let data = try? JSONEncoder().encode(value) else { return }
        await storage.store(data, for: key.rawValue)
    }

    public func removeAll() async {
        await storage.removeAll()
    }
}
