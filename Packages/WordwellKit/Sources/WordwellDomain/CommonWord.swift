import Foundation

/// A frequency-ranked entry of the bundled "Top 3000" list; `id` is a dictionary entry id (`oewn:<lemma>:<pos>`).
public struct CommonWord: Identifiable, Hashable, Sendable {
    public let id: String
    public let rank: Int
    public let word: String
    public let partOfSpeech: PartOfSpeech?

    public init?(id: String, rank: Int) {
        let parts = id.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0] == "oewn", !parts[1].isEmpty else { return nil }
        self.id = id
        self.rank = rank
        word = parts[1].replacingOccurrences(of: "_", with: " ")
        partOfSpeech = switch parts[2] {
        case "n": .noun
        case "v": .verb
        case "a", "s": .adjective
        case "r": .adverb
        default: nil
        }
    }
}
