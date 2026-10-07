import SwiftUI
import WordwellData
import WordwellDesign
import WordwellDomain

struct LibraryScreen: View {
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository
    let illustrations: any IllustrationBindingRepository
    let onOpenWord: (String) -> Void

    @State private var tab: LibraryTab = .topics
    @State private var query = ""
    @State private var saved: [SavedEntry] = []
    @State private var commonWords: [CommonWord] = []
    @State private var wordIllustrations: [String: IllustrationBinding] = [:]
    @State private var collections: [WordCollection] = []
    @State private var isLoading = true
    @State private var failed = false
    @State private var showingNewCollection = false
    @State private var collectionName = ""
    @State private var message: String?

    private enum LibraryTab: String, CaseIterable {
        case topics = "Topics", common = "Top 3000", words = "Words", phrases = "Phrases", collections = "Collections"
    }

    private struct SavedEntry: Identifiable {
        let entry: WordEntry
        let state: UserWordState
        var id: String { entry.id }
    }

    private var filtered: [SavedEntry] {
        saved.filter { item in
            (tab != .phrases || item.entry.partOfSpeech == .phrase || item.entry.word.contains(" "))
                && (query.isEmpty || item.entry.word.localizedCaseInsensitiveContains(query)
                    || item.entry.senses.first?.definition.localizedCaseInsensitiveContains(query) == true)
        }
    }

    private var filteredTopics: [VocabularyTopic] {
        VocabularyTopic.all.filter { topic in
            query.isEmpty || topic.title.localizedCaseInsensitiveContains(query)
                || topic.words.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    private var filteredCommonWords: [CommonWord] {
        query.isEmpty ? commonWords : commonWords.filter { $0.word.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        FeaturePage(title: "Library", subtitle: "Explore words by topic and save your favorites") {
            tabs

            if tab == .topics {
                topicsContent
            } else if tab == .common {
                commonContent
            } else if isLoading {
                ProgressView("Loading library")
            } else if failed {
                ContentUnavailableView {
                    Label("Library unavailable", systemImage: "books.vertical")
                } description: {
                    Text("Your saved words could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            } else {
                switch tab {
                case .topics, .common:
                    EmptyView()
                case .words:
                    section("Saved words") { wordList(filtered, empty: "Saved words will appear here. Open a dictionary entry to save one.") }
                case .phrases:
                    section("Phrases") { wordList(filtered, empty: "Saved phrases will appear here.") }
                case .collections:
                    collectionsContent
                }
            }
        }
        .searchable(text: $query, prompt: searchPrompt)
        .onAppear { Task { await load() } }
        .alert("New collection", isPresented: $showingNewCollection) {
            TextField("Collection name", text: $collectionName)
            Button("Create") { Task { await createCollection() } }
            Button("Cancel", role: .cancel) { collectionName = "" }
        }
        .alert("Library", isPresented: Binding(
            get: { message != nil },
            set: { if !$0 { message = nil } }
        )) {
            Button("OK", role: .cancel) { message = nil }
        } message: {
            Text(message ?? "")
        }
    }

    private var searchPrompt: String {
        switch tab {
        case .topics: "Search topics or words"
        case .common: "Search the top 3000"
        default: "Search saved words"
        }
    }

    private var tabs: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(LibraryTab.allCases, id: \.self) { option in
                    Button {
                        tab = option
                        query = ""
                    } label: {
                        Text(option.rawValue)
                            .font(WordwellType.button)
                            .foregroundStyle(tab == option ? WordwellColor.ink : WordwellColor.secondaryText)
                            .padding(.horizontal, 16)
                            .frame(minHeight: WordwellLayout.minimumTouchTarget)
                            .overlay(alignment: .bottom) {
                                (tab == option ? WordwellColor.ink : WordwellColor.border)
                                    .frame(height: tab == option ? 2 : 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(tab == option ? .isSelected : [])
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var topicsContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if filteredTopics.isEmpty {
                WordwellBodyText("No topics found. Try another word.", secondary: true)
            } else {
                ForEach(filteredTopics) { topic in
                    NavigationLink(value: AppRoute.topic(id: topic.id)) {
                        WordwellListRow(
                            title: topic.title,
                            detail: "\(topic.words.count) words · \(topic.words.prefix(3).joined(separator: ", "))"
                        ) {
                            Image(systemName: topic.symbol)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var commonContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if commonWords.isEmpty {
                ContentUnavailableView("Word list unavailable", systemImage: "list.number",
                                       description: Text("The top 3000 list could not be loaded."))
            } else if filteredCommonWords.isEmpty {
                WordwellBodyText("No words found. Try another word.", secondary: true)
            } else {
                WordwellBodyText("The 3,000 most frequently used English words, most common first.", secondary: true)
                    .padding(.bottom, 8)
                ForEach(filteredCommonWords) { item in
                    NavigationLink(value: AppRoute.dictionaryEntry(wordID: item.id)) {
                        WordwellListRow(
                            title: item.word,
                            detail: [item.partOfSpeech?.rawValue, "#\(item.rank)"].compactMap { $0 }.joined(separator: " · ")
                        ) {
                            Image(systemName: "text.book.closed")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task { if commonWords.isEmpty { commonWords = CommonWordsCatalog.load() } }
    }

    private var collectionsContent: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Button {
                collectionName = ""
                showingNewCollection = true
            } label: {
                Label("New collection", systemImage: "plus")
            }
            .buttonStyle(WordwellButtonStyle(.secondary))

            if collections.isEmpty {
                WordwellBodyText("Create a collection to organize your saved words.", secondary: true)
            } else {
                ForEach(collections) { collection in
                    let members = filtered.filter { $0.state.collectionIDs.contains(collection.id) }
                    section("\(collection.name) · \(members.count)") {
                        if members.isEmpty {
                            WordwellBodyText("Use a saved word’s menu to add it here.", secondary: true)
                        } else {
                            ForEach(members) { item in wordRow(item.entry, state: item.state) }
                        }
                    }
                }
            }
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(WordwellType.sectionLabel)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    @ViewBuilder
    private func wordList(_ items: [SavedEntry], empty: String) -> some View {
        if items.isEmpty {
            WordwellBodyText(empty, secondary: true)
        } else {
            ForEach(items) { item in wordRow(item.entry, state: item.state) }
        }
    }

    private func wordRow(_ entry: WordEntry, state: UserWordState?) -> some View {
        HStack(spacing: 6) {
            Button { onOpenWord(entry.id) } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(entry.word)
                                .font(WordwellType.cardHeadline)
                                .foregroundStyle(WordwellColor.ink)
                            if let level = entry.cefrLevel {
                                WordwellCEFRBadge(level: level.rawValue, band: band(for: level))
                            }
                        }
                        Text("\(entry.partOfSpeech.rawValue) · \(entry.senses.first?.definition ?? "")")
                            .font(WordwellType.meta)
                            .foregroundStyle(WordwellColor.secondaryText)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if let illustration = wordIllustrations[entry.id] {
                        BoundIllustration(binding: illustration)
                            .frame(width: 48, height: 42)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(WordwellColor.mutedIcon)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: WordwellLayout.minimumTouchTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let state, !collections.isEmpty {
                Menu {
                    ForEach(collections) { collection in
                        Button {
                            Task { await toggle(collection.id, in: state) }
                        } label: {
                            if state.collectionIDs.contains(collection.id) {
                                Label(collection.name, systemImage: "checkmark")
                            } else {
                                Text(collection.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: WordwellLayout.minimumTouchTarget, height: WordwellLayout.minimumTouchTarget)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Collections for \(entry.word)")
            }
        }
        .padding(.vertical, WordwellLayout.rowPadding)
        .overlay(alignment: .bottom) { WordwellColor.border.frame(height: 1) }
    }

    private func band(for level: CEFRLevel) -> WordwellCEFRBand {
        switch level {
        case .a1, .a2: .beginner
        case .b1, .b2: .intermediate
        case .c1, .c2: .advanced
        }
    }

    private func load() async {
        isLoading = true
        failed = false
        do {
            let states = try await library.allSavedWords()
            let groups = try await library.collections()
            var words: [SavedEntry] = []
            for state in states {
                if let entry = try await dictionary.entry(id: state.wordID) {
                    words.append(SavedEntry(entry: entry, state: state))
                }
            }
            var bindings: [String: IllustrationBinding] = [:]
            for entry in words.map(\.entry) {
                bindings[entry.id] = try? await illustrations.binding(
                    lemma: entry.lemma, partOfSpeech: entry.partOfSpeech,
                    senseID: entry.senses.first?.id, context: .library
                )
            }
            guard !Task.isCancelled else { return }
            saved = words
            wordIllustrations = bindings
            collections = groups
        } catch {
            guard !Task.isCancelled else { return }
            failed = true
        }
        isLoading = false
    }

    private func createCollection() async {
        do {
            _ = try await library.createCollection(named: collectionName)
            collectionName = ""
            await load()
        } catch WordLibraryError.invalidCollectionName {
            message = "Enter a collection name."
        } catch WordLibraryError.duplicateCollectionName {
            message = "A collection with that name already exists."
        } catch {
            message = "The collection could not be created. Please try again."
        }
    }

    private func toggle(_ collectionID: String, in state: UserWordState) async {
        var updated = state
        if updated.collectionIDs.contains(collectionID) {
            updated.collectionIDs.removeAll { $0 == collectionID }
        } else {
            updated.collectionIDs.append(collectionID)
        }
        do {
            try await library.update(updated)
            await load()
        } catch {
            message = "The word could not be moved. Please try again."
        }
    }
}

struct TopicWordsScreen: View {
    let topic: VocabularyTopic
    let dictionary: any DictionaryRepository

    @State private var entries: [WordEntry] = []
    @State private var isLoading = true
    @State private var failed = false

    var body: some View {
        FeaturePage(title: topic.title, subtitle: "\(topic.words.count) useful words") {
            if isLoading {
                ProgressView("Loading words")
            } else if failed {
                ContentUnavailableView {
                    Label("Words unavailable", systemImage: "book.closed")
                } description: {
                    Text("This topic could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            } else {
                ForEach(entries) { entry in
                    NavigationLink(value: AppRoute.dictionaryEntry(wordID: entry.id)) {
                        WordwellListRow(
                            title: entry.word,
                            detail: entry.senses.first?.definition ?? "Open dictionary entry"
                        ) {
                            Image(systemName: "book")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        failed = false
        do {
            var loaded: [WordEntry] = []
            for id in topic.wordIDs {
                guard let entry = try await dictionary.entry(id: id) else {
                    throw DictionaryRepositoryError.invalidDatabase
                }
                loaded.append(entry)
            }
            guard !Task.isCancelled else { return }
            entries = loaded
        } catch {
            guard !Task.isCancelled else { return }
            failed = true
        }
        isLoading = false
    }
}
