#if canImport(FoundationModels)
import Foundation
import FoundationModels

/// Keeps prompts inside the on-device context window.
/// Uses real token counting on iOS/macOS 26.4+, a conservative estimate before that.
@available(iOS 26.0, macOS 26.0, *)
public struct TokenBudget: Sendable {
    public var reservedOutputTokens: Int
    public var fallbackContextSize: Int

    public init(reservedOutputTokens: Int = 700, fallbackContextSize: Int = 4_096) {
        self.reservedOutputTokens = reservedOutputTokens
        self.fallbackContextSize = fallbackContextSize
    }

    public var contextSize: Int {
        if #available(iOS 26.4, macOS 26.4, *) {
            return SystemLanguageModel.default.contextSize
        }
        return fallbackContextSize
    }

    public func tokenCount(_ text: String) async -> Int {
        if #available(iOS 26.4, macOS 26.4, *) {
            if let count = try? await SystemLanguageModel.default.tokenCount(for: text) {
                return count
            }
        }
        // ~3 UTF-8 bytes per token overestimates for English, which is the safe direction.
        return text.utf8.count / 3 + 1
    }

    public func fits(prompt: String, instructions: String) async -> Bool {
        let used = await tokenCount(instructions + "\n" + prompt)
        return used + reservedOutputTokens <= contextSize
    }
}
#endif
