#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

@available(iOS 26.0, macOS 26.0, *)
enum FMAvailability {
    static func current(languageCode: String?) -> AIAvailability {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            if let languageCode, !model.supportsLocale(Locale(identifier: languageCode)) {
                return .unavailable(.unsupportedLanguage)
            }
            return .available
        case .unavailable(.deviceNotEligible):
            return .unavailable(.deviceNotEligible)
        case .unavailable(.appleIntelligenceNotEnabled):
            return .unavailable(.intelligenceDisabled)
        case .unavailable(.modelNotReady):
            return .unavailable(.modelNotReady)
        case .unavailable:
            return .unavailable(.unknown)
        @unknown default:
            return .unavailable(.unknown)
        }
    }

    static func require(languageCode: String?) throws {
        if case .unavailable(let reason) = current(languageCode: languageCode) {
            throw AIError.unavailable(reason)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
enum FMErrorMapper {
    static func map(_ error: any Error) -> AIError {
        if let error = error as? AIError { return error }
        if error is CancellationError { return .cancelled }

        if let error = error as? LanguageModelSession.GenerationError {
            switch error {
            case .exceededContextWindowSize: return .contextOverflow
            case .guardrailViolation: return .guardrailViolation
            case .unsupportedLanguageOrLocale: return .unsupportedLanguage
            case .assetsUnavailable: return .unavailable(.modelNotReady)
            case .rateLimited: return .rateLimited
            default: return .generationFailed(String(describing: error))
            }
        }
        if let error = error as? LanguageModelSession.ToolCallError {
            return map(error.underlyingError)
        }
        return .generationFailed(String(describing: error))
    }
}
#endif
