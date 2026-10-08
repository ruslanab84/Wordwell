import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct ImproveSentenceScreen: View {
    let ai: any LearningAI
    let settings: any LearningSettingsRepository

    private enum Phase {
        case idle, loading, result(SentenceImprovement), unavailable, failed
    }

    @State private var draft = ""
    @State private var phase: Phase = .idle
    @State private var task: Task<Void, Never>?
    @State private var activeRequest: UUID?

    private var isLoading: Bool { if case .loading = phase { true } else { false } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Improve my sentence", subtitle: "Write in English, get gentle corrections")
                WordwellPrivacyCue()

                TextField("Write a sentence", text: $draft, axis: .vertical)
                    .font(WordwellType.body)
                    .lineLimit(3...8)
                    .padding(14)
                    .frame(minHeight: WordwellLayout.minimumTouchTarget, alignment: .topLeading)
                    .overlay { RoundedRectangle(cornerRadius: WordwellLayout.cardRadius).strokeBorder(WordwellColor.border, lineWidth: 1) }
                    .disabled(isLoading)

                Button("Improve my sentence", action: improve)
                    .buttonStyle(WordwellButtonStyle(.primary))
                    .disabled(isLoading || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if !isIdle { answer }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Improve my sentence")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { task?.cancel() }
    }

    private var isIdle: Bool { if case .idle = phase { true } else { false } }

    private var answer: some View {
        WordwellCard {
            VStack(alignment: .leading, spacing: 8) {
                switch phase {
                case .idle: EmptyView()
                case .loading:
                    WordwellBodyText("Working on this device…", secondary: true)
                case .result(let result):
                    Text("Improved sentence")
                        .font(WordwellType.sectionLabel)
                        .foregroundStyle(WordwellColor.ink)
                        .accessibilityAddTraits(.isHeader)
                    if result.isAlreadyCorrect {
                        WordwellBodyText("Looks good. No changes needed.")
                    } else {
                        WordwellBodyText("“\(result.corrected)”")
                        ForEach(Array(result.issues.enumerated()), id: \.offset) { _, issue in
                            WordwellBodyText("\(issue.fragment) → \(issue.fix): \(issue.explanation)", secondary: true)
                        }
                    }
                case .unavailable:
                    WordwellBodyText("On-device AI is unavailable or turned off in Settings.", secondary: true)
                case .failed:
                    WordwellBodyText("Could not check this sentence. Try again.", secondary: true)
                }
            }
        }
    }

    private func improve() {
        let sentence = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sentence.isEmpty else { return }
        task?.cancel()
        let id = UUID()
        activeRequest = id
        phase = .loading
        task = Task {
            guard let profile = try? await settings.profile(), profile.aiEnabled else {
                if activeRequest == id { phase = .unavailable }
                return
            }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage
            )
            do {
                let result = try await ai.improve(sentence: sentence, target: nil, learner: learner)
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
