import SwiftUI
import WordwellDesign
import WordwellDomain

/// Search sheet that returns the word to compare the current entry with.
struct CompareWordPicker: View {
    let repository: any DictionaryRepository
    let currentWordID: String
    let onPick: (WordSummary) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var results: [WordSummary] = []

    var body: some View {
        NavigationStack {
            List(results) { word in
                Button {
                    dismiss()
                    onPick(word)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(word.word).font(WordwellType.body)
                        Text(word.previewDefinition)
                            .font(WordwellType.meta)
                            .foregroundStyle(WordwellColor.secondaryText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: WordwellLayout.minimumTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .navigationTitle("Compare with")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "tell, speak, talk…")
            .task(id: query) {
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { results = []; return }
                let found = (try? await repository.search(trimmed, limit: 20)) ?? []
                guard !Task.isCancelled else { return }
                results = found.filter { $0.id != currentWordID }
            }
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }
}
