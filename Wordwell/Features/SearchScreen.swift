import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct SearchScreen: View {
    let repository: any DictionaryRepository
    let semantic: (any SemanticSearchService)?
    let settings: any LearningSettingsRepository
    let onOpenWord: (String) -> Void

    @AppStorage("wordwell.searchHistory") private var searchHistoryData = Data()
    @State private var query = ""
    @State private var retry = 0
    @State private var phase: Phase = .idle

    private enum Phase {
        case idle, loading, results([WordSummary]), failed
    }

    private enum MeaningPhase {
        case idle, loading, results([AIWordContext]), unavailable, failed
    }

    @State private var meaning: MeaningPhase = .idle
    @State private var meaningTask: Task<Void, Never>?

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
            if semantic != nil, !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                meaningSection
            }
        }
        .onChange(of: query) { meaningTask?.cancel(); meaning = .idle }
        .onDisappear { meaningTask?.cancel() }
        .searchable(text: $query, prompt: "Search words or meanings")
        .onSubmit(of: .search) { recordSearch() }
        .task(id: Request(query: query, retry: retry)) {
            await search()
        }
    }

    @ViewBuilder
    private var meaningSection: some View {
        WordwellPrivacyCue()
        switch meaning {
        case .idle:
            Button("Find by meaning", action: findByMeaning)
                .buttonStyle(WordwellButtonStyle(.secondary))
        case .loading:
            HStack {
                WordwellBodyText("Working on this device…", secondary: true)
                Spacer()
                Button("Stop") { meaningTask?.cancel() }
                    .frame(minHeight: WordwellLayout.minimumTouchTarget)
            }
        case .results(let words):
            if words.isEmpty {
                WordwellBodyText("No matching dictionary words found. Try describing it differently.", secondary: true)
            } else {
                Text("By meaning")
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                ForEach(words, id: \.lemma) { word in
                    Button { openMeaningWord(word.lemma) } label: {
                        WordwellListRow(title: word.lemma,
                                        detail: "\(word.partOfSpeech) · \(word.senses.first?.definition ?? "")") {
                            Image(systemName: "book")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        case .unavailable:
            WordwellBodyText("On-device AI is unavailable or turned off in Settings.", secondary: true)
        case .failed:
            WordwellBodyText("Could not search by meaning. Try again.", secondary: true)
            Button("Try again", action: findByMeaning)
                .frame(minHeight: WordwellLayout.minimumTouchTarget)
        }
    }

    private func openMeaningWord(_ lemma: String) {
        Task {
            guard let entry = try? await repository.entry(lemma: lemma) else { return }
            recordSearch()
            onOpenWord(entry.id)
        }
    }

    private func findByMeaning() {
        guard let semantic else { return }
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        meaningTask?.cancel()
        meaning = .loading
        let requested = query
        meaningTask = Task {
            guard let profile = try? await settings.profile(), profile.aiEnabled else {
                if requested == query { meaning = .unavailable }
                return
            }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage)
            do {
                let result = try await semantic.find(meaning: text, learner: learner)
                try Task.checkCancellation()
                if requested == query { meaning = .results(result) }
            } catch is CancellationError {
                if requested == query { meaning = .idle }
            } catch let error as AIError {
                guard requested == query else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: meaning = .unavailable
                case .cancelled: meaning = .idle
                default: meaning = .failed
                }
            } catch {
                if requested == query { meaning = .failed }
            }
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
