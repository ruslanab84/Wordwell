import WordwellDomain

public struct UnavailableDictionaryRepository: DictionaryRepository {
    public init() {}

    public func search(_ query: String, limit: Int) async throws -> [WordSummary] {
        throw DictionaryRepositoryError.notConfigured
    }

    public func suggestions(prefix: String, limit: Int) async throws -> [String] {
        throw DictionaryRepositoryError.notConfigured
    }

    public func entry(id: String) async throws -> WordEntry? {
        throw DictionaryRepositoryError.notConfigured
    }

    public func entry(lemma: String) async throws -> WordEntry? {
        throw DictionaryRepositoryError.notConfigured
    }

    public func featuredEntry(excluding wordID: String?) async throws -> WordEntry? {
        throw DictionaryRepositoryError.notConfigured
    }

    public func notificationEntries(excluding wordIDs: Set<String>, limit: Int) async throws -> [WordEntry] {
        throw DictionaryRepositoryError.notConfigured
    }
}
