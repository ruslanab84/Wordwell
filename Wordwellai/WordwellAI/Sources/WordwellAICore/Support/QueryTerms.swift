import Foundation

/// Shared tokenisation for definition retrieval. The app's search adapter should use the same
/// rules so CLI results and app results stay comparable.
public enum QueryTerms {
    private static let stopwords: Set<String> = [
        "a", "an", "the", "of", "to", "in", "on", "at", "for", "and", "or", "is", "are", "was", "were", "be",
        "it", "its", "that", "this", "with", "as", "by", "from", "who", "which", "what", "when", "where",
        "someone", "something", "person", "people", "thing", "word", "called", "means", "feeling",
        "very", "much", "into", "than", "then", "have", "has", "had", "do", "does", "you", "your", "my",
    ]

    /// Lowercase letter-only words without stopwords, unstemmed and de-duplicated in query order.
    /// Input for engines that stem on their own (SQLite FTS5 with the porter tokenizer).
    /// Letters only, so the result is safe to quote inside an FTS `MATCH` expression.
    public static func searchWords(_ text: String) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for piece in text.lowercased().split(whereSeparator: { !$0.isLetter }) {
            let word = String(piece)
            guard word.count > 1, !stopwords.contains(word), seen.insert(word).inserted else { continue }
            result.append(word)
        }
        return result
    }

    /// Lowercase, stopword-free, lightly stemmed terms (for the CLI's in-memory retrieval).
    public static func terms(_ text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !($0.isLetter || $0.isNumber) })
            .map(String.init)
            .filter { !stopwords.contains($0) && $0.count > 1 }
            .map(stem)
    }

    /// Light, language-specific stemmer: strips common suffixes, then keeps the first five letters so that
    /// "arrived / arrive", "travelling / travel" and "heights / height" meet. Rank noise is acceptable:
    /// retrieval only builds a shortlist, and the dictionary verifies every final result.
    public static func stem(_ word: String) -> String {
        var value = word
        if value.count > 4, value.hasSuffix("ies") {
            value = String(value.dropLast(3)) + "y"
        } else if value.count > 5, value.hasSuffix("ing") {
            value = String(value.dropLast(3))
        } else if value.count > 4, value.hasSuffix("ed") {
            value = String(value.dropLast(2))
        } else if value.count > 3, value.hasSuffix("s"), !value.hasSuffix("ss") {
            value = String(value.dropLast())
        }
        return String(value.prefix(5))
    }
}
