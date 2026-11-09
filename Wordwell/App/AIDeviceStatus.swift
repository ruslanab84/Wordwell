import SwiftUI
import WordwellAICore
import WordwellAIFoundationModels
import WordwellDesign

/// What this device can do with Apple Intelligence, separate from the in-app AI toggle.
enum AIDeviceStatus: String, Equatable {
    case ready, notEnabled, preparing, unsupported

    static var current: AIDeviceStatus {
        #if DEBUG
        // Launch with `-aiDeviceStatus unsupported` to preview a state the simulator cannot reach.
        if let raw = UserDefaults.standard.string(forKey: "aiDeviceStatus"), let forced = AIDeviceStatus(rawValue: raw) {
            return forced
        }
        #endif
        switch GrammarAI.availability() {
        case .available: return .ready
        case .unavailable(.intelligenceDisabled): return .notEnabled
        case .unavailable(.modelNotReady): return .preparing
        case .unavailable: return .unsupported
        }
    }

    var showsAI: Bool { self != .unsupported }
    var needsSetup: Bool { self == .notEnabled || self == .preparing }

    var message: String {
        switch self {
        case .ready: "On-device AI is unavailable or turned off in Verbalex Settings."
        case .notEnabled: "To use AI features, turn on Apple Intelligence in the Settings app, under Apple Intelligence & Siri."
        case .preparing: "Apple Intelligence is still getting ready on this device. AI features will appear when it finishes."
        case .unsupported: "AI features are not available on this device."
        }
    }
}

extension EnvironmentValues {
    /// Set once in `ContentView` and refreshed when the app returns to the foreground.
    @Entry var aiDeviceStatus: AIDeviceStatus = .unsupported
}

/// Shows `content` when AI is ready, a setup note when the user can still enable it, and nothing otherwise.
struct AIGate<Content: View>: View {
    @Environment(\.aiDeviceStatus) private var status
    @ViewBuilder var content: Content

    var body: some View {
        if status == .ready {
            content
        } else if status.needsSetup {
            WordwellBodyText(status.message, secondary: true)
        }
    }
}
