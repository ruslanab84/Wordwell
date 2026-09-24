import Foundation

public struct FormMatch: Sendable, Hashable {
    /// Text as it appears in the sentence ("Decided").
    public let text: String
    public let range: Range<String.Index>
}

/// Whole-word, case-insensitive matching of a headword and its inflections.
public enum FormMatcher {
    public static func firstMatch(of forms: [String], in text: String) -> FormMatch? {
        let fullRange = NSRange(text.startIndex..., in: text)
        var best: FormMatch?

        for form in forms where !form.trimmed.isEmpty {
            let pattern = "\\b" + NSRegularExpression.escapedPattern(for: form.trimmed) + "\\b"
            guard
                let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
                let match = regex.firstMatch(in: text, range: fullRange),
                let range = Range(match.range, in: text)
            else { continue }

            if best == nil || range.lowerBound < best!.range.lowerBound {
                best = FormMatch(text: String(text[range]), range: range)
            }
        }
        return best
    }

    public static func contains(_ forms: [String], in text: String) -> Bool {
        firstMatch(of: forms, in: text) != nil
    }
}
