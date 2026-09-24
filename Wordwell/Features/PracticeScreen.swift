import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct PracticeScreen: View {
    let progress: any ProgressRepository
    let onStartReview: () -> Void
    let onStartSpeaking: () -> Void
    let onStartListening: () -> Void
    let onStartQuiz: () -> Void
    let onStartSkillsCheck: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var summary: PracticeSummary?
    @State private var activityUnavailable = false
    @State private var hasSkillsCheckDraft = false
    @State private var latestSkillsCheck: SkillsCheckResult?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Practice", subtitle: "Small steps, real progress every day") {
                    Image("PracticeArtwork")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 140, height: 110)
                        .foregroundStyle(WordwellColor.lineArt)
                }

                Text("Today’s practice")
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 8) { stats }
                } else {
                    HStack(alignment: .top, spacing: 8) { stats }
                }

                if activityUnavailable {
                    WordwellBodyText("Today’s activity could not be loaded.", secondary: true)
                }

                Button(action: onStartReview) {
                    WordwellListRow(title: "Vocabulary review", detail: "Revisit saved words and strengthen your memory") {
                        Image(systemName: "book.closed")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Start reviewing saved words")

                Button(action: onStartSpeaking) {
                    WordwellListRow(title: "Speaking", detail: "Practice real conversations") {
                        Image(systemName: "mic")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Start a speaking session")
                Button(action: onStartListening) {
                    WordwellListRow(title: "Listening", detail: "Hear words and choose what you heard") {
                        Image(systemName: "headphones")
                    }
                }
                .buttonStyle(.plain)
                Button(action: onStartQuiz) {
                    WordwellListRow(title: "Quick quiz", detail: "Test your understanding") {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
                .buttonStyle(.plain)

                Button(action: onStartSkillsCheck) {
                    WordwellListRow(title: "English Skills Check",
                                    detail: hasSkillsCheckDraft ? "Continue your four-part session" : "Read, listen, write, and speak · about 25 minutes") {
                        Image(systemName: "checklist")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint(hasSkillsCheckDraft ? "Continue your saved session" : "Start a four-part skills check")

                if let latestSkillsCheck {
                    WordwellBodyText("Latest check: \(latestSkillsCheck.readingCorrect)/5 reading · " +
                                     (latestSkillsCheck.listeningCorrect.map { "\($0)/5 listening" } ?? "listening unavailable"),
                                     secondary: true)
                }

                Text("A little progress each day adds up.")
                    .font(WordwellType.display(16, weight: .regular, relativeTo: .body))
                    .italic()
                    .foregroundStyle(WordwellColor.secondaryText)
                    .padding(.top, 10)
            }
            .padding(.horizontal, WordwellLayout.screenPadding)
            .padding(.vertical, WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .onAppear {
            hasSkillsCheckDraft = SkillsCheckDraftStore().load() != nil
            Task { await loadSummary() }
        }
    }

    @ViewBuilder
    private var stats: some View {
        WordwellStatBox(value: summary.map { String($0.dayStreak) } ?? "–", label: "day streak") {
            Image(systemName: "flame")
        }
        WordwellStatBox(value: summary.map { String($0.minutesToday) } ?? "–", label: "minutes today") {
            Image(systemName: "clock")
        }
        WordwellStatBox(value: summary.map { String($0.wordsReviewedToday) } ?? "–", label: "words reviewed") {
            Image(systemName: "book")
        }
    }

    private func loadSummary() async {
        do {
            summary = try await progress.practiceSummary()
            latestSkillsCheck = try? await progress.latestSkillsCheck()
            activityUnavailable = false
        } catch {
            activityUnavailable = true
        }
    }
}
