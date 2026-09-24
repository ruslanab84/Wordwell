import Foundation
import WordwellAICore
import WordwellDomain

struct DictionaryAILookupAdapter: AIDictionaryLookup {
    let repository: any DictionaryRepository

    func wordContext(for lemma: String) async throws -> AIWordContext? {
        try await repository.entry(lemma: lemma)?.aiContext()
    }

    func distractors(for lemma: String, level: WordwellAICore.CEFRLevel?, limit: Int) async throws -> [String] {
        guard limit > 0, let entry = try await repository.entry(lemma: lemma),
              let firstLetter = lemma.first else { return [] }
        let candidates = try await repository.search(String(firstLetter), limit: 100)
        return Array(candidates.lazy
            .filter { $0.partOfSpeech == entry.partOfSpeech && $0.word.caseInsensitiveCompare(lemma) != .orderedSame }
            .filter { level == nil || $0.cefrLevel == nil || $0.cefrLevel?.rawValue == level?.rawValue }
            .map(\.word)
            .prefix(limit))
    }
}

extension WordEntry {
    func aiContext(senseID: String? = nil) -> AIWordContext {
        AIWordContext(
            lemma: lemma,
            partOfSpeech: partOfSpeech.rawValue,
            cefrLevel: cefrLevel.flatMap { WordwellAICore.CEFRLevel(rawValue: $0.rawValue) },
            senses: senses.filter { senseID == nil || $0.id == senseID }.map {
                AIWordContext.Sense(id: $0.id, definition: $0.definition, example: $0.examples.first)
            },
            // ponytail: WordNet payloads lack inflections; add forms here when the dictionary import includes them.
            collocations: collocations
        )
    }
}
