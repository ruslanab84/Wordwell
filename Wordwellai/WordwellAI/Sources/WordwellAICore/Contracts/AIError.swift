import Foundation

public enum AIUnavailabilityReason: String, Codable, Sendable, Hashable {
    case deviceNotEligible
    case intelligenceDisabled
    case modelNotReady
    case unsupportedLanguage
    case osTooOld
    case providerDisabled
    case unknown
}

public enum AIAvailability: Sendable, Hashable {
    case available
    case unavailable(AIUnavailabilityReason)

    public var isAvailable: Bool {
        switch self {
        case .available: true
        case .unavailable: false
        }
    }
}

public enum AIError: Error, Sendable, Hashable {
    case unavailable(AIUnavailabilityReason)
    case guardrailViolation
    case contextOverflow
    case unsupportedLanguage
    case rateLimited
    case wordNotFound(String)
    case inputTooLong(limit: Int)
    case invalidResponse(String)
    case generationFailed(String)
    case cancelled

    /// Key for the app's String Catalog. UI never shows raw error text.
    public var localizationKey: String {
        switch self {
        case .unavailable(let reason): "ai.error.unavailable.\(reason.rawValue)"
        case .guardrailViolation: "ai.error.guardrail"
        case .contextOverflow: "ai.error.contextOverflow"
        case .unsupportedLanguage: "ai.error.unsupportedLanguage"
        case .rateLimited: "ai.error.rateLimited"
        case .wordNotFound: "ai.error.wordNotFound"
        case .inputTooLong: "ai.error.inputTooLong"
        case .invalidResponse, .generationFailed: "ai.error.generic"
        case .cancelled: "ai.error.cancelled"
        }
    }

    /// Errors a secondary provider may recover from. Guardrail and user-input errors never fall back.
    public var allowsFallback: Bool {
        switch self {
        case .unavailable, .contextOverflow, .unsupportedLanguage, .rateLimited,
             .invalidResponse, .generationFailed:
            true
        case .guardrailViolation, .wordNotFound, .inputTooLong, .cancelled:
            false
        }
    }
}
