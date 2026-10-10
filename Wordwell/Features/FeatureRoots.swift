import SwiftUI
import WordwellDesign
import WordwellDomain

struct HomeScreen: View {
    let library: any WordLibraryRepository
    let progress: any ProgressRepository
    let featuredWord: WordEntry?
    let isLoadingFeaturedWord: Bool
    let featuredReason: String?
    let onOpenWord: (String) -> Void
    let onSearch: () -> Void
    let onPractice: () -> Void
    @State private var savedCount = 0
    @State private var summary: PracticeSummary?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        FeaturePage(title: "Verbalex", subtitle: "A place to meet new words") {
            if let summary {
                WordwellBodyText("\(summary.minutesToday) minutes today · \(summary.dayStreak) day streak", secondary: true)
            }
            if isLoadingFeaturedWord {
                ProgressView("Loading word")
            } else if let featuredWord {
                VStack(alignment: .leading, spacing: 12) {
                    Text("New word for you")
                        .font(WordwellType.sectionLabel)
                        .foregroundStyle(WordwellColor.secondaryText)
                    Text(featuredWord.word)
                        .font(WordwellType.cardHeadline)
                        .foregroundStyle(WordwellColor.ink)
                    if let featuredReason {
                        WordwellBodyText(featuredReason, secondary: true)
                    }
                    WordwellBodyText(featuredWord.senses.first?.definition ?? "")
                    Button("Read the entry") { onOpenWord(featuredWord.id) }
                        .buttonStyle(WordwellButtonStyle(.primary))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                WordwellBodyText("The dictionary is unavailable right now.", secondary: true)
            }

            Button(action: onSearch) {
                WordwellListRow(title: "Search the dictionary", detail: "Explore words offline") {
                    Image(systemName: "magnifyingglass")
                }
            }
            .buttonStyle(.plain)
            Button(action: onPractice) {
                WordwellListRow(title: "Practice", detail: "Review, speak, listen, and quiz") {
                    Image(systemName: "pencil.line")
                }
            }
            .buttonStyle(.plain)
            WordwellBodyText("\(savedCount) saved \(savedCount == 1 ? "word" : "words")", secondary: true)
        }
        .onAppear { Task { await load() } }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await load() } }
        }
    }

    private func load() async {
        let saved = (try? await library.allSavedWords()) ?? []
        savedCount = saved.count
        summary = try? await progress.practiceSummary()
    }
}
