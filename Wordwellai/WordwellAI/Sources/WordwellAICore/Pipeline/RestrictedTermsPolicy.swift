import Foundation

/// Rejects generated exam material that names real exams, exam boards or proprietary score terms.
///
/// The policy stores only 64-bit FNV-1a fingerprints of normalised terms, never plain text,
/// so neither the source code, the bundle nor the binary contains any brand name.
/// Add a term with `wordwell-ai exam fingerprint "<term>"` and paste the hex into the config.
public struct RestrictedTermsPolicy: Sendable {
    private let fingerprints: Set<UInt64>
    private let maxWords: Int

    public init(fingerprints: Set<UInt64>, maxWords: Int) {
        self.fingerprints = fingerprints
        self.maxWords = max(1, maxWords)
    }

    /// Tooling/tests only; production loads fingerprints from config.
    public init(plainTerms: [String]) {
        let normalized = plainTerms.map(Self.tokens).filter { !$0.isEmpty }
        self.init(fingerprints: Set(normalized.map { Self.hash($0.joined(separator: " ")) }),
                  maxWords: normalized.map(\.count).max() ?? 1)
    }

    public static func load(from url: URL) throws -> RestrictedTermsPolicy {
        struct File: Decodable {
            let maxWords: Int
            let fingerprints: [String]
        }
        let file = try JSONDecoder().decode(File.self, from: Data(contentsOf: url))
        let values = file.fingerprints.compactMap { UInt64($0.replacingOccurrences(of: "0x", with: ""), radix: 16) }
        return RestrictedTermsPolicy(fingerprints: Set(values), maxWords: file.maxWords)
    }

    public var isEmpty: Bool { fingerprints.isEmpty }

    public static func fingerprint(of term: String) -> UInt64 {
        hash(tokens(term).joined(separator: " "))
    }

    /// Matched fingerprints (1…maxWords word n-grams). Returned as hashes: callers never see brand text.
    public func violations(in text: String) -> [UInt64] {
        let words = Self.tokens(text)
        var found: [UInt64] = []
        for start in words.indices {
            for length in 1...maxWords where start + length <= words.count {
                let value = Self.hash(words[start..<(start + length)].joined(separator: " "))
                if fingerprints.contains(value) { found.append(value) }
            }
        }
        return found.uniqued()
    }

    public func violations(in texts: [String]) -> [UInt64] {
        texts.flatMap { violations(in: $0) }.uniqued()
    }

    // MARK: - Normalisation

    static func tokens(_ text: String) -> [String] {
        text.lowercased()
            .split(whereSeparator: { !($0.isLetter || $0.isNumber) })
            .map(String.init)
    }

    static func hash(_ text: String) -> UInt64 {
        var value: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in text.utf8 {
            value ^= UInt64(byte)
            value = value &* 0x0000_0100_0000_01b3
        }
        return value
    }
}
