import Foundation
import WordwellDomain

public final class LocalIllustrationBindingRepository: IllustrationBindingRepository, Sendable {
    private struct Catalog: Decodable {
        let schemaVersion: Int
        let assets: [IllustrationBinding]
    }

    private let byLemma: [String: [IllustrationBinding]]

    public init() {
        let url = Bundle.module.url(forResource: "illustration_bindings", withExtension: "json", subdirectory: "IllustrationsSVG")
        let catalog = url.flatMap { try? Data(contentsOf: $0) }.flatMap { try? JSONDecoder().decode(Catalog.self, from: $0) }
        let assets = catalog?.schemaVersion == 2 ? catalog?.assets ?? [] : []
        byLemma = Dictionary(grouping: assets, by: { Self.key($0.lemma) })
    }

    public func binding(
        lemma: String,
        partOfSpeech: PartOfSpeech?,
        senseID: String?,
        context: IllustrationContext
    ) async throws -> IllustrationBinding? {
        byLemma[Self.key(lemma)]?
            .filter {
                $0.contexts.contains(context)
                    && ($0.partOfSpeech == partOfSpeech || $0.partOfSpeech == nil)
                    && ($0.senseID == senseID || $0.senseID == nil)
            }
            .max { lhs, rhs in
                specificity(lhs, partOfSpeech: partOfSpeech, senseID: senseID)
                    < specificity(rhs, partOfSpeech: partOfSpeech, senseID: senseID)
            }
    }

    private static func key(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func specificity(_ binding: IllustrationBinding, partOfSpeech: PartOfSpeech?, senseID: String?) -> Int {
        (binding.partOfSpeech == partOfSpeech && partOfSpeech != nil ? 1 : 0)
            + (binding.senseID == senseID && senseID != nil ? 2 : 0)
    }
}
