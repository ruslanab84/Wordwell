import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct DictionaryEntryScreen: View {
    let wordID: String
    let repository: any DictionaryRepository
    let library: any WordLibraryRepository
    let settings: any LearningSettingsRepository
    let illustrations: any IllustrationBindingRepository
    let player: PronunciationPlayer

    @State private var phase: Phase = .loading
    @State private var isSaved = false
    @State private var isSaving = false
    @State private var saveFailed = false
    @State private var voiceUnavailable = false
    @State private var preferredVariant: EnglishVariant = .both
    @State private var illustration: IllustrationBinding?
    @State private var aiEnabled = true
    @State private var aiPhase: AIPhase = .idle
    @State private var selectedAIAction: AIAction?
    @State private var aiTask: Task<Void, Never>?
    @State private var sentenceDraft = ""
    @State private var showComparePicker = false
    @State private var compareContext: (entry: WordEntry, sense: DefinitionSense)?
    @State private var activeAIRequest: UUID?
    private let ai: any LearningAI

    init(wordID: String, repository: any DictionaryRepository, library: any WordLibraryRepository,
         settings: any LearningSettingsRepository, illustrations: any IllustrationBindingRepository,
         player: PronunciationPlayer, ai: any LearningAI) {
        self.wordID = wordID
        self.repository = repository
        self.library = library
        self.settings = settings
        self.illustrations = illustrations
        self.player = player
        self.ai = ai
    }

    private enum Phase {
        case loading
        case loaded(WordEntry)
        case missing
        case failed
    }

    private enum AIPhase: Equatable {
        case idle, loading, unavailable, failed
        case explanation(String)
        case examples([String])
        case improvement(SentenceImprovement)
        case comparison(WordwellAICore.WordComparison)
    }

    private enum AIAction: CaseIterable {
        case explainSimply, explainInUserLanguage, moreExamples

        var title: String {
            switch self {
            case .explainSimply: "Explain simply"
            case .explainInUserLanguage: "Explain in my language"
            case .moreExamples: "More examples"
            }
        }

        var loadingTitle: String {
            switch self {
            case .explainSimply: "Explaining simply…"
            case .explainInUserLanguage: "Explaining in my language…"
            case .moreExamples: "Finding examples…"
            }
        }

        var answerTitle: String {
            switch self {
            case .explainSimply: "Simple explanation"
            case .explainInUserLanguage: "Explanation in my language"
            case .moreExamples: "More examples"
            }
        }
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                ProgressView("Loading entry")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let entry):
                entryPage(entry)
            case .missing:
                ContentUnavailableView("Word unavailable", systemImage: "book.closed")
            case .failed:
                ContentUnavailableView {
                    Label("Dictionary unavailable", systemImage: "book.closed")
                } description: {
                    Text("The entry could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            }
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Dictionary")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: wordID) { await load() }
        .onDisappear { stopAI(); player.stop() }
        .sheet(isPresented: $showComparePicker) {
            CompareWordPicker(repository: repository, currentWordID: wordID) { other in
                if let ctx = compareContext { compare(entry: ctx.entry, sense: ctx.sense, with: other) }
            }
        }
        .alert("Could not update your library", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
    }

    private func load() async {
        stopAI()
        illustration = nil
        phase = .loading
        do {
            let entry = try await repository.entry(id: wordID)
            if let profile = try? await settings.profile() {
                preferredVariant = profile.preferredEnglishVariant
                aiEnabled = profile.aiEnabled
            }
            guard !Task.isCancelled else { return }
            if entry != nil {
                try? await library.recordViewed(wordID: wordID)
                isSaved = (try? await library.state(for: wordID)) != nil
            }
            phase = entry.map(Phase.loaded) ?? .missing
            if let entry {
                Task { await ai.prewarm(for: .explain) }
                illustration = try? await illustrations.binding(
                    lemma: entry.lemma, partOfSpeech: entry.partOfSpeech,
                    senseID: entry.senses.first?.id, context: .dictionaryEntry
                )
            }
        } catch {
            guard !Task.isCancelled else { return }
            phase = .failed
        }
    }

    private func entryPage(_ entry: WordEntry) -> some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                    if let illustration {
                        BoundIllustration(binding: illustration)
                            .frame(maxWidth: 342)
                            .frame(maxWidth: .infinity)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.word)
                            .font(WordwellType.headword)
                            .foregroundStyle(WordwellColor.ink)
                            .accessibilityAddTraits(.isHeader)

                        HStack(spacing: 10) {
                            Text(entry.partOfSpeech.rawValue)
                                .italic()
                            if let level = entry.cefrLevel {
                                WordwellCEFRBadge(level: level.rawValue, band: band(for: level))
                            }
                        }
                        .font(WordwellType.meta)
                        .foregroundStyle(WordwellColor.secondaryText)

                        if preferredVariant != .us { pronunciation("UK", ipa: entry.ipaUK, word: entry.word) }
                        if preferredVariant != .uk { pronunciation("US", ipa: entry.ipaUS, word: entry.word) }
                        if voiceUnavailable { WordwellBodyText("An English voice is unavailable on this device.", secondary: true) }
                        Button {
                            Task { await toggleSaved() }
                        } label: {
                            Label(isSaved ? "Saved to My words" : "Save to My words", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                        }
                        .buttonStyle(WordwellButtonStyle(isSaved ? .secondary : .primary))
                        .disabled(isSaving)
                        .padding(.top, 8)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                        sectionTitle("Meanings")
                        ForEach(entry.senses.indices, id: \.self) { index in
                            let sense = entry.senses[index]
                            HStack(alignment: .top, spacing: 14) {
                                Text("\(index + 1).")
                                    .font(WordwellType.cardHeadline)
                                    .foregroundStyle(WordwellColor.secondaryText)
                                    .frame(width: 28, alignment: .leading)
                                VStack(alignment: .leading, spacing: 8) {
                                    WordwellBodyText(sense.definition)
                                    if let register = sense.register {
                                        Text(register)
                                            .font(WordwellType.meta)
                                            .foregroundStyle(WordwellColor.secondaryText)
                                    }
                                    ForEach(sense.examples.indices, id: \.self) { exampleIndex in
                                        Text("“\(sense.examples[exampleIndex])”")
                                            .font(WordwellType.body)
                                            .italic()
                                            .foregroundStyle(WordwellColor.secondaryText)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .accessibilityElement(children: .combine)
                            if index < entry.senses.count - 1 { Divider() }
                        }
                    }

                    if !entry.collocations.isEmpty {
                        wordList("Collocations", words: entry.collocations)
                    }
                    if !entry.synonyms.isEmpty {
                        wordList("Related words across meanings", words: entry.synonyms)
                    }
                    if !entry.antonyms.isEmpty {
                        wordList("Opposites", words: entry.antonyms)
                    }
                    if !entry.usageNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionTitle("Usage notes")
                            ForEach(entry.usageNotes, id: \.self) { WordwellBodyText($0) }
                        }
                    }
                    if !entry.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            sectionTitle("Common mistakes")
                            ForEach(entry.commonMistakes, id: \.self) { mistake in
                                VStack(alignment: .leading, spacing: 4) {
                                    WordwellBodyText("\(mistake.incorrect) → \(mistake.corrected)")
                                    WordwellBodyText(mistake.explanation, secondary: true)
                                }
                            }
                        }
                    }

                    if let sense = entry.senses.first {
                        aiCoach(entry: entry, sense: sense)
                    }

                    Text("Definitions and examples: Open English Wordnet")
                        .font(WordwellType.meta)
                        .foregroundStyle(WordwellColor.secondaryText)
                        .padding(.top, WordwellLayout.sectionGap)
                }
                .padding(.horizontal, WordwellLayout.screenPadding)
                .padding(.vertical, WordwellLayout.screenPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onChange(of: aiPhase) { _, newPhase in
                guard newPhase != .idle else { return }
                withAnimation(.easeInOut(duration: 0.25)) {
                    scrollProxy.scrollTo("ai-answer", anchor: .top)
                }
            }
        }
    }

    private func aiCoach(entry: WordEntry, sense: DefinitionSense) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            sectionTitle("AI Coach")
            VStack(alignment: .leading, spacing: 8) {
                ForEach(AIAction.allCases, id: \.self) { action in
                    let isSelected = aiPhase == .loading && selectedAIAction == action
                    Button {
                        request(action, entry: entry, sense: sense)
                    } label: {
                        HStack(spacing: 8) {
                            if isSelected {
                                ProgressView()
                                    .tint(WordwellColor.paper)
                                    .accessibilityHidden(true)
                            }
                            Text(isSelected ? action.loadingTitle : action.title)
                        }
                    }
                    .buttonStyle(WordwellButtonStyle(isSelected ? .primary : .secondary))
                    .opacity(aiPhase == .loading && !isSelected ? 0.45 : 1)
                    .disabled(aiPhase == .loading || !aiEnabled)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("Write a sentence with “\(entry.word)”", text: $sentenceDraft, axis: .vertical)
                    .font(WordwellType.body)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .frame(minHeight: WordwellLayout.minimumTouchTarget)
                    .overlay { RoundedRectangle(cornerRadius: WordwellLayout.cardRadius).strokeBorder(WordwellColor.border, lineWidth: 1) }
                    .disabled(aiPhase == .loading || !aiEnabled)
                Button("Improve my sentence") { improve(entry: entry, sense: sense) }
                    .buttonStyle(WordwellButtonStyle(.secondary))
                    .disabled(aiPhase == .loading || !aiEnabled || sentenceDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Button("Compare with another word") {
                compareContext = (entry, sense)
                showComparePicker = true
            }
            .buttonStyle(WordwellButtonStyle(.secondary))
            .disabled(aiPhase == .loading || !aiEnabled)

            if !aiEnabled { WordwellBodyText("On-device AI is turned off in Settings.", secondary: true) }

            if aiPhase != .idle {
                WordwellCard {
                    VStack(alignment: .leading, spacing: 8) {
                        switch aiPhase {
                        case .idle: EmptyView()
                        case .loading:
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    sectionTitle(selectedAIAction?.answerTitle ?? "AI Coach answer")
                                    WordwellBodyText("Working on this device…", secondary: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                Button { stopAI() } label: {
                                    Text("Stop")
                                        .font(WordwellType.meta)
                                        .foregroundStyle(WordwellColor.secondaryText)
                                        .frame(minWidth: WordwellLayout.minimumTouchTarget,
                                               minHeight: WordwellLayout.minimumTouchTarget)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        case .explanation(let text):
                            sectionTitle(selectedAIAction?.answerTitle ?? "Explanation")
                            WordwellBodyText(text)
                        case .examples(let examples):
                            sectionTitle("More examples")
                            ForEach(examples.indices, id: \.self) { WordwellBodyText("“\(examples[$0])”") }
                        case .improvement(let result):
                            sectionTitle("Improved sentence")
                            if result.isAlreadyCorrect {
                                WordwellBodyText("Looks good. No changes needed.")
                            } else {
                                WordwellBodyText("“\(result.corrected)”")
                                ForEach(Array(result.issues.enumerated()), id: \.offset) { _, issue in
                                    WordwellBodyText("\(issue.fragment) → \(issue.fix): \(issue.explanation)", secondary: true)
                                }
                            }
                        case .comparison(let result):
                            sectionTitle("\(result.first) vs \(result.second)")
                            WordwellBodyText(result.coreDifference)
                            WordwellBodyText("Use \(result.first) when \(result.useFirstWhen)", secondary: true)
                            WordwellBodyText("Use \(result.second) when \(result.useSecondWhen)", secondary: true)
                            ForEach(Array(result.examples.enumerated()), id: \.offset) { _, example in
                                WordwellBodyText("“\(example.sentence)”")
                            }
                        case .unavailable:
                            WordwellBodyText("AI unavailable on this device. Dictionary content is shown above.", secondary: true)
                            ForEach(Array(sense.examples.prefix(2).enumerated()), id: \.offset) { WordwellBodyText("“\($0.element)”", secondary: true) }
                        case .failed:
                            WordwellBodyText("Could not prepare an AI answer. The dictionary meaning above is still available.", secondary: true)
                        }
                    }
                }
                .id("ai-answer")
            }
        }
    }

    private func improve(entry: WordEntry, sense: DefinitionSense) {
        let sentence = sentenceDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sentence.isEmpty else { return }
        aiTask?.cancel()
        let requestID = UUID()
        activeAIRequest = requestID
        selectedAIAction = nil
        aiPhase = .loading
        aiTask = Task {
            guard let profile = try? await settings.profile(), profile.aiEnabled else {
                if activeAIRequest == requestID { aiPhase = .unavailable }
                return
            }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: (entry.cefrLevel ?? profile.cefrLevel).rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage
            )
            do {
                let result = try await ai.improve(sentence: sentence, target: entry.aiContext(senseID: sense.id), learner: learner)
                try Task.checkCancellation()
                if activeAIRequest == requestID { aiPhase = .improvement(result) }
            } catch is CancellationError {
                if activeAIRequest == requestID { aiPhase = .idle }
            } catch let error as AIError {
                guard activeAIRequest == requestID else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: aiPhase = .unavailable
                case .cancelled: aiPhase = .idle
                default: aiPhase = .failed
                }
            } catch {
                if activeAIRequest == requestID { aiPhase = .failed }
            }
        }
    }

    private func compare(entry: WordEntry, sense: DefinitionSense, with other: WordSummary) {
        aiTask?.cancel()
        let requestID = UUID()
        activeAIRequest = requestID
        selectedAIAction = nil
        aiPhase = .loading
        aiTask = Task {
            guard let profile = try? await settings.profile(), profile.aiEnabled else {
                if activeAIRequest == requestID { aiPhase = .unavailable }
                return
            }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: (entry.cefrLevel ?? profile.cefrLevel).rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage
            )
            do {
                guard let otherEntry = try await repository.entry(id: other.id) else {
                    if activeAIRequest == requestID { aiPhase = .failed }
                    return
                }
                let result = try await ai.compare(entry.aiContext(senseID: sense.id), otherEntry.aiContext(), learner: learner)
                try Task.checkCancellation()
                if activeAIRequest == requestID { aiPhase = .comparison(result) }
            } catch is CancellationError {
                if activeAIRequest == requestID { aiPhase = .idle }
            } catch let error as AIError {
                guard activeAIRequest == requestID else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: aiPhase = .unavailable
                case .cancelled: aiPhase = .idle
                default: aiPhase = .failed
                }
            } catch {
                if activeAIRequest == requestID { aiPhase = .failed }
            }
        }
    }

    private func request(_ action: AIAction, entry: WordEntry, sense: DefinitionSense) {
        aiTask?.cancel()
        let requestID = UUID()
        activeAIRequest = requestID
        selectedAIAction = action
        aiPhase = .loading
        aiTask = Task {
            guard var profile = try? await settings.profile() else {
                if activeAIRequest == requestID { aiPhase = .failed }
                return
            }
            guard profile.aiEnabled else {
                if activeAIRequest == requestID { aiPhase = .unavailable }
                return
            }
            guard activeAIRequest == requestID, !Task.isCancelled else { return }
            if let level = entry.cefrLevel { profile.cefrLevel = level }
            let learner = LearnerProfile(
                level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
                nativeLanguageCode: profile.explanationLanguage
            )
            let word = entry.aiContext(senseID: sense.id)
            let language = action == .explainInUserLanguage ? profile.explanationLanguage : nil
            do {
                switch action {
                case .explainSimply, .explainInUserLanguage:
                    let result = try await ai.explain(word, learner: learner, languageCode: language)
                    try Task.checkCancellation()
                    if activeAIRequest == requestID { aiPhase = .explanation(result.explanation) }
                case .moreExamples:
                    let result = try await ai.examples(for: word, learner: learner, count: 2)
                    try Task.checkCancellation()
                    if activeAIRequest == requestID { aiPhase = .examples(result.map(\.text)) }
                }
            } catch is CancellationError {
                if activeAIRequest == requestID { aiPhase = .idle }
            } catch let error as AIError {
                guard activeAIRequest == requestID else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: aiPhase = .unavailable
                case .cancelled: aiPhase = .idle
                default: aiPhase = .failed
                }
            } catch {
                if activeAIRequest == requestID { aiPhase = .failed }
            }
        }
    }

    private func stopAI() {
        aiTask?.cancel()
        activeAIRequest = nil
        selectedAIAction = nil
        aiPhase = .idle
    }

    private func toggleSaved() async {
        isSaving = true
        defer { isSaving = false }
        do {
            if isSaved {
                try await library.remove(wordID: wordID)
            } else {
                try await library.save(wordID: wordID)
            }
            isSaved.toggle()
        } catch {
            saveFailed = true
        }
    }

    private func pronunciation(_ variant: String, ipa: String?, word: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let ipa { Text("\(variant) /\(ipa)/").font(WordwellType.meta).foregroundStyle(WordwellColor.secondaryText) }
            Button {
                voiceUnavailable = !player.speak(word, variant: variant == "UK" ? .uk : .us)
            } label: {
                Label("Play \(variant) pronunciation", systemImage: "speaker.wave.2")
            }
            .buttonStyle(WordwellButtonStyle(.secondary))
        }
    }

    private func wordList(_ title: String, words: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            sectionTitle(title)
            WordwellBodyText(words.joined(separator: " · "))
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(WordwellType.sectionLabel)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func band(for level: WordwellDomain.CEFRLevel) -> WordwellCEFRBand {
        switch level {
        case .a1, .a2: .beginner
        case .b1, .b2: .intermediate
        case .c1, .c2: .advanced
        }
    }
}
