import Foundation

/// Proposals → cleanup → dictionary resolution. A headword the dictionary cannot resolve never reaches the UI.
/// Regenerates once when nothing resolves. Never cached.
public final class ResilientSemanticSearch: SemanticSearchService {
    public static let maxQueryCharacters = 200
    public static let maxResults = 8

    private let primary: any SemanticCandidateProvider
    private let dictionary: any AIDictionaryLookup
    private let maxAttempts: Int

    public init(primary: any SemanticCandidateProvider, dictionary: any AIDictionaryLookup, maxAttempts: Int = 2) {
        self.primary = primary
        self.dictionary = dictionary
        self.maxAttempts = max(1, maxAttempts)
    }

    public var identifier: String { "resilient-semantic-search(\(primary.identifier))" }
    public var promptVersion: String { primary.promptVersion }

    public func availability(languageCode: String?) async -> AIAvailability {
        await primary.availability(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {
        await primary.prewarm(for: task)
    }

    public func find(meaning query: String, learner: LearnerProfile) async throws -> [AIWordContext] {
        let text = query.trimmed
        guard !text.isEmpty else { throw AIError.invalidResponse("empty query") }
        guard text.count <= Self.maxQueryCharacters else { throw AIError.inputTooLong(limit: Self.maxQueryCharacters) }

        for _ in 0..<maxAttempts {
            let proposed = try await primary.candidates(for: text, learner: learner)
            let resolved = try await resolve(proposed)
            if !resolved.isEmpty { return resolved }
        }
        return []
    }

    private func resolve(_ proposed: [String]) async throws -> [AIWordContext] {
        var seen = Set<String>()
        var result: [AIWordContext] = []
        for raw in proposed {
            let lemma = raw.trimmed
            guard !lemma.isEmpty, lemma.count <= 40, seen.insert(lemma.lowercased()).inserted,
                  let context = try await dictionary.wordContext(for: lemma) else { continue }
            result.append(context)
            if result.count == Self.maxResults { break }
        }
        return result
    }
}
