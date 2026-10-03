#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// Holds one prewarmed, unused session per task. A session is handed out once
/// (single-turn tasks must not share transcript/context).
@available(iOS 26.0, macOS 26.0, *)
actor SessionWarmer {
    private var sessions: [AITask: LanguageModelSession] = [:]

    func prewarm(_ task: AITask) {
        guard sessions[task] == nil else { return }
        let session = LanguageModelSession(instructions: AIPrompts.instructions(for: task))
        session.prewarm()
        sessions[task] = session
    }

    func take(_ task: AITask) -> LanguageModelSession? {
        sessions.removeValue(forKey: task)
    }
}
#endif
