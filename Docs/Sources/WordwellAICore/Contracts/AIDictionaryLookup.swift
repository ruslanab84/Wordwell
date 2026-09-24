import Foundation

/// Narrow read-only view of the dictionary for AI features.
/// The app's `DictionaryRepository` adapts to this protocol; AI never writes dictionary data.
public protocol AIDictionaryLookup: Sendable {
    func wordContext(for lemma: String) async throws -> AIWordContext?
    /// Verified words used as quiz distractors (same part of speech, close CEFR level).
    func distractors(for lemma: String, level: CEFRLevel?, limit: Int) async throws -> [String]
}
