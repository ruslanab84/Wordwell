#if canImport(FoundationModels)
import Foundation
import WordwellAICore

@available(iOS 26.0, macOS 26.0, *)
extension GExplanation {
    func domain(languageCode: String?) -> SimpleExplanation {
        SimpleExplanation(senseID: senseID, explanation: explanation,
                          analogy: analogy.isBlank ? nil : analogy,
                          examples: examples, languageCode: languageCode)
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension GExplanation.PartiallyGenerated {
    var draft: ExplanationDraft {
        ExplanationDraft(senseID: senseID, explanation: explanation,
                         analogy: (analogy?.isBlank ?? true) ? nil : analogy,
                         examples: examples ?? [])
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension GComparison {
    func domain(first: String, second: String) -> WordComparison {
        WordComparison(first: first, second: second, coreDifference: coreDifference,
                       useFirstWhen: useFirstWhen, useSecondWhen: useSecondWhen,
                       examples: examples.map { .init(lemma: $0.lemma, sentence: $0.sentence) })
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension GIssue {
    var domain: SentenceIssue {
        let kind: SentenceIssue.Kind = switch self.kind {
        case .grammar: .grammar
        case .wordChoice: .wordChoice
        case .collocation: .collocation
        case .spelling: .spelling
        case .register: .register
        case .other: .other
        }
        return SentenceIssue(kind: kind, fragment: fragment, fix: fix, explanation: explanation)
    }
}

extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}
#endif
