import Foundation

/// Reverse dictionary: description → verified dictionary words.
///
/// 1. Deterministic retrieval over definitions (works offline, no AI).
/// 2. The model sees the retrieved shortlist and proposes words (it can also translate the description).
/// 3. Every proposed word must exist in the dictionary. The definition shown is always the dictionary's.
/// If the model is unavailable the result degrades to retrieval only, never to an error.
public struct ReverseDictionary: Sendable {
    public struct Configuration: Sendable {
        public var maxDescriptionLength = 200
        public var shortlistSize = 8
        public var defaultLimit = 5
        public init() {}
    }

    private let service: any WordFinderService
    private let dictionary: any SearchableDictionary
    private let configuration: Configuration

    public init(service: any WordFinderService, dictionary: any SearchableDictionary,
                configuration: Configuration = Configuration()) {
        self.service = service
        self.dictionary = dictionary
        self.configuration = configuration
    }

    public func find(_ description: String, learner: LearnerProfile, limit: Int? = nil,
                     useAI: Bool = true) async throws -> ReverseLookupResult {
        let query = description.trimmed
        guard !query.isEmpty else { throw AIError.invalidResponse("empty description") }
        guard query.count <= configuration.maxDescriptionLength else {
            throw AIError.inputTooLong(limit: configuration.maxDescriptionLength)
        }

        let shortlist = try await dictionary.candidates(matching: query, limit: configuration.shortlistSize)

        var proposed: [String] = []
        var aiUsed = false
        var unavailableReason: AIUnavailabilityReason?
        if useAI {
            do {
                proposed = try await service.proposeWords(for: query, shortlist: shortlist, learner: learner)
                aiUsed = true
            } catch let error as AIError where error.allowsFallback {
                if case .unavailable(let reason) = error { unavailableReason = reason }
            }
        }

        var candidates: [String: Candidate] = [:]
        for (rank, word) in shortlist.enumerated() {
            candidates[word.lemma.lowercased(), default: Candidate(word: word)].retrievalRank = rank
        }

        var seen = Set<String>()
        var modelRank = 0
        for raw in proposed {
            guard let lemma = Self.normalizedLemma(raw), seen.insert(lemma).inserted else { continue }
            defer { modelRank += 1 }
            guard let word = try await dictionary.wordContext(for: lemma) else { continue }
            var candidate = candidates[lemma] ?? Candidate(word: word)
            candidate.modelRank = modelRank
            candidates[lemma] = candidate
        }

        let queryTerms = Set(QueryTerms.terms(query))
        let matches = candidates.values
            .sorted { ($0.score, $1.word.lemma) > ($1.score, $0.word.lemma) }
            .prefix(max(1, limit ?? configuration.defaultLimit))
            .compactMap { $0.match(queryTerms: queryTerms) }

        return ReverseLookupResult(matches: Array(matches), aiUsed: aiUsed, aiUnavailableReason: unavailableReason)
    }

    // MARK: - Ranking

    private struct Candidate {
        let word: AIWordContext
        var modelRank: Int?
        var retrievalRank: Int?

        init(word: AIWordContext) { self.word = word }

        /// Agreement between the model and retrieval outranks either alone; the model outranks retrieval.
        var score: Double {
            switch (modelRank, retrievalRank) {
            case let (model?, retrieval?): 3.0 - 0.1 * Double(model) - 0.01 * Double(retrieval)
            case let (model?, nil): 2.0 - 0.1 * Double(model)
            case let (nil, retrieval?): 1.0 - 0.05 * Double(retrieval)
            case (nil, nil): 0
            }
        }

        var source: WordFinderMatch.Source {
            switch (modelRank, retrievalRank) {
            case (.some, .some): .both
            case (.some, nil): .model
            default: .retrieval
            }
        }

        func match(queryTerms: Set<String>) -> WordFinderMatch? {
            guard let sense = bestSense(queryTerms: queryTerms) else { return nil }
            return WordFinderMatch(lemma: word.lemma, partOfSpeech: word.partOfSpeech, cefrLevel: word.cefrLevel,
                                   senseID: sense.id, definition: sense.definition, source: source)
        }

        private func bestSense(queryTerms: Set<String>) -> AIWordContext.Sense? {
            word.senses.max { lhs, rhs in
                overlap(lhs, queryTerms) < overlap(rhs, queryTerms)
            }
        }

        private func overlap(_ sense: AIWordContext.Sense, _ terms: Set<String>) -> Int {
            Set(QueryTerms.terms(sense.definition)).intersection(terms).count
        }
    }

    /// Letters, hyphen and apostrophe only; rejects phrases and sentences the model may return.
    static func normalizedLemma(_ raw: String) -> String? {
        let value = raw.trimmed.lowercased()
        guard (1...30).contains(value.count),
              value.allSatisfy({ $0.isLetter || $0 == "-" || $0 == "'" }) else { return nil }
        return value
    }
}
