import Foundation
import WordwellAICore
import WordwellData
import WordwellDomain

struct DictionaryAILookupAdapter: AIDictionaryLookup {
    let repository: any DictionaryRepository

    func wordContext(for lemma: String) async throws -> AIWordContext? {
        try await repository.entry(lemma: lemma)?.aiContext()
    }

    // Single-word, same-part-of-speech picks from the Top 3000 list. Searching the dictionary by first
    // letter returned junk ("b", "B", "hollow-horned"); case-twin options made the validator drop every question.
    // ponytail: random pick can land a synonym of the answer; add a synonym exclusion if learners report it.
    func distractors(for lemma: String, level: WordwellAICore.CEFRLevel?, limit: Int) async throws -> [String] {
        guard let entry = try await repository.entry(lemma: lemma) else { return [] }
        return distractors(for: entry, limit: limit)
    }

    /// Prefer this overload: a lemma alone can resolve to another part of speech ("run" the noun).
    func distractors(for entry: WordEntry, limit: Int) -> [String] {
        guard limit > 0 else { return [] }
        return Array(Self.commonWords.filter {
            $0.partOfSpeech == entry.partOfSpeech && !$0.word.contains(" ")
                && $0.word.caseInsensitiveCompare(entry.lemma) != .orderedSame
        }.shuffled().prefix(limit).map(\.word))
    }

    private static let commonWords = CommonWordsCatalog.load()
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
