import Foundation
import WordwellAICore

/// Deterministic definition retrieval for the CLI. In the app this is the SQLite/FTS repository.
extension JSONDictionaryLookup: DefinitionSearching {
    func candidates(matching query: String, limit: Int) async throws -> [AIWordContext] {
        let terms = QueryTerms.terms(query)
        guard !terms.isEmpty else { return [] }

        let scored: [(word: AIWordContext, score: Double)] = entries.values.map { entry in
            let definitionTerms = Set(entry.senses.flatMap { QueryTerms.terms($0.definition) })
            let collocationTerms = Set(entry.collocations.flatMap { QueryTerms.terms($0) })
            let lemmaTerm = QueryTerms.stem(entry.lemma.lowercased())

            var score = 0.0
            for term in terms {
                if definitionTerms.contains(term) { score += 2 }
                if collocationTerms.contains(term) { score += 1 }
                if term == lemmaTerm { score += 3 }
            }
            return (entry, score)
        }

        return scored
            .filter { $0.score > 0 }
            .sorted { ($0.score, $1.word.lemma) > ($1.score, $0.word.lemma) }
            .prefix(max(0, limit))
            .map { $0.word }
    }
}
