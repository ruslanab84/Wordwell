#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// Grounds the model in verified dictionary data for words that were not inlined in the prompt
/// (e.g. a word the learner misused). Returns a compact rendering to save context tokens.
@available(iOS 26.0, macOS 26.0, *)
struct LookupWordTool: Tool {
    let name = "lookupWord"
    let description = "Returns verified dictionary data (senses, forms, collocations) for an English word."

    let dictionary: any AIDictionaryLookup
    let prompts: PromptBuilder

    @Generable
    struct Arguments {
        @Guide(description: "Base form of one English word, lowercase")
        var lemma: String
    }

    func call(arguments: Arguments) async throws -> String {
        let lemma = arguments.lemma.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !lemma.isEmpty, lemma.count <= 40,
              let word = try await dictionary.wordContext(for: lemma) else {
            return "NOT_FOUND: \(lemma). Do not guess its meaning."
        }
        return prompts.render(word, maxSenses: 2)
    }
}
#endif
