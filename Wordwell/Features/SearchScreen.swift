import SwiftUI
import WordwellDesign
import WordwellDomain

struct SearchScreen: View {
    let repository: any DictionaryRepository
    let onOpenWord: (String) -> Void

    @AppStorage("wordwell.searchHistory") private var searchHistoryData = Data()
    @State private var query = ""
    @State private var retry = 0
    @State private var phase: Phase = .idle

    private enum Phase {
        case idle, loading, results([WordSummary]), failed
    }

    private struct Request: Hashable {
        let query: String
        let retry: Int
    }

    private var searchHistory: SearchHistory {
        (try? JSONDecoder().decode(SearchHistory.self, from: searchHistoryData)) ?? SearchHistory()
    }

    var body: some View {
        FeaturePage(title: "Search", subtitle: "Find the word you need") {
            switch phase {
            case .idle:
                if searchHistory.terms.isEmpty {
                    WordwellBodyText("Search words or meanings in the dictionary.", secondary: true)
                } else {
                    Text("Recent searches")
                        .font(WordwellType.sectionLabel)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(searchHistory.terms, id: \.self) { term in
                        Button {
                            query = term
                            recordSearch()
                        } label: {
                            WordwellListRow(title: term, detail: "Search again") {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .loading:
                ProgressView("Searching dictionary")
            case .results(let words):
                if words.isEmpty {
                    WordwellBodyText("No words found. Try another spelling or meaning.", secondary: true)
                } else {
                    ForEach(words) { word in
                        Button {
                            recordSearch()
                            onOpenWord(word.id)
                        } label: {
                            WordwellListRow(
                                title: word.word,
                                detail: "\(word.partOfSpeech.rawValue) · \(word.previewDefinition)"
                            ) {
                                Image(systemName: "book")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .failed:
                ContentUnavailableView {
                    Label("Dictionary unavailable", systemImage: "book.closed")
                } description: {
                    Text("The search could not be completed.")
                } actions: {
                    Button("Try again") { retry += 1 }
                }
            }
        }
        .searchable(text: $query, prompt: "Search words or meanings")
        .onSubmit(of: .search) { recordSearch() }
        .task(id: Request(query: query, retry: retry)) {
            await search()
        }
    }

    private func recordSearch() {
        var history = searchHistory
        history.record(query)
        if let data = try? JSONEncoder().encode(history) {
            searchHistoryData = data
        }
    }

    private func search() async {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            phase = .idle
            return
        }
        phase = .loading
        do {
            try await Task.sleep(for: .milliseconds(180))
            let words = try await repository.search(term, limit: 30)
            try Task.checkCancellation()
            phase = .results(words)
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed
        }
    }
}
