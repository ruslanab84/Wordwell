import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

extension EnvironmentValues {
    /// Set once in `ContentView`; nil when on-device AI cannot exist (OS too old).
    @Entry var mistakeExplainer: (any MistakeExplainerService)?
}

/// «Explain mistake» after a wrong multiple-choice answer. Give it `.id(question.id)` so it resets per question.
struct ExplainMistakeCard: View {
    let mistake: MistakeContext
    let settings: any LearningSettingsRepository

    @Environment(\.mistakeExplainer) private var explainer

    private enum Phase {
        case idle, loading, result(MistakeExplanation), unavailable, failed
    }

    @State private var phase: Phase = .idle
    @State private var task: Task<Void, Never>?
    @State private var activeRequest: UUID?

    private var isLoading: Bool { if case .loading = phase { true } else { false } }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WordwellPrivacyCue()
            if case .idle = phase {
                Button("Explain mistake", action: explain)
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else {
                WordwellCard { content }
            }
        }
        .onDisappear { task?.cancel() }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch phase {
            case .idle: EmptyView()
            case .loading:
                HStack {
                    WordwellBodyText("Working on this device…", secondary: true)
                    Spacer()
                    Button("Stop") { task?.cancel() }
                        .frame(minHeight: WordwellLayout.minimumTouchTarget)
                }
            case .result(let result):
                WordwellBodyText(result.whyWrong)
                WordwellBodyText(result.whyRight)
            case .unavailable:
                WordwellBodyText("On-device AI is unavailable or turned off in Settings.", secondary: true)
            case .failed:
                WordwellBodyText("Could not explain this one. Try again.", secondary: true)
                Button("Try again", action: explain)
                    .frame(minHeight: WordwellLayout.minimumTouchTarget)
            }
        }
    }

    private func explain() {
        task?.cancel()
        let id = UUID()
        activeRequest = id
        phase = .loading
        task = Task {
            guard let explainer, let profile = try? await settings.profile(), profile.aiEnabled else {
                if activeRequest == id { phase = .unavailable }
                return
            }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage
            )
            do {
                let result = try await explainer.explain(mistake, learner: learner)
                try Task.checkCancellation()
                if activeRequest == id { phase = .result(result) }
            } catch is CancellationError {
                if activeRequest == id { phase = .idle }
            } catch let error as AIError {
                guard activeRequest == id else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: phase = .unavailable
                case .cancelled: phase = .idle
                default: phase = .failed
                }
            } catch {
                if activeRequest == id { phase = .failed }
            }
        }
    }
}
