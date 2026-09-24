import SwiftUI
import WordwellDesign
import WordwellDomain

struct ProfileScreen: View {
    let library: any WordLibraryRepository
    let progress: any ProgressRepository
    let onProgress: () -> Void
    let onSettings: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var savedWords: Int?
    @State private var snapshot: ProgressSnapshot?
    @State private var loadFailed = false

    var body: some View {
        FeaturePage(title: "Profile", subtitle: "Your personal learning space") {
            if loadFailed {
                WordwellBodyText("Your learning summary could not be loaded.", secondary: true)
                Button("Try again") { Task { await load() } }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 8) { stats }
                } else {
                    HStack(spacing: 8) { stats }
                }
            }

            Button(action: onProgress) {
                WordwellListRow(title: "Progress", detail: "Activity, statistics, and goals") {
                    Image(systemName: "chart.bar")
                }
            }
            .buttonStyle(.plain)
            Button(action: onSettings) {
                WordwellListRow(title: "Settings", detail: "Learning, appearance, and AI") {
                    Image(systemName: "gearshape")
                }
            }
            .buttonStyle(.plain)
            WordwellBodyText("Your words and learning activity are stored on this device.", secondary: true)
        }
        .task { await load() }
    }

    @ViewBuilder
    private var stats: some View {
        WordwellStatBox(value: savedWords.map(String.init) ?? "–", label: "saved words") {
            Image(systemName: "bookmark")
        }
        WordwellStatBox(value: snapshot.map { String($0.wordsLearned) } ?? "–", label: "words learned") {
            Image(systemName: "book")
        }
    }

    private func load() async {
        do {
            savedWords = try await library.allSavedWords().count
            snapshot = try await progress.snapshot()
            loadFailed = false
        } catch {
            loadFailed = true
        }
    }
}
