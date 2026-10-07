import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

/// AI role-play: pick a scene, talk it through, review mistakes and save useful words.
struct ConversationScreen: View {
    let service: (any ConversationService)?
    let settings: any LearningSettingsRepository
    let progress: any ProgressRepository
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository

    @State private var session: ConversationSession?
    @State private var isStarting = false
    @State private var unavailable = false

    var body: some View {
        Group {
            if let session {
                ConversationSessionView(session: session, dictionary: dictionary, library: library) {
                    session.cancel()
                    self.session = nil
                }
            } else {
                picker
            }
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .task { await checkAvailability() }
        .onDisappear { session?.cancel() }
    }

    private var picker: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Conversation", subtitle: "One short scene at a time")
                WordwellPrivacyCue()

                if unavailable {
                    WordwellBodyText("AI unavailable on this device. Turn on Apple Intelligence in Settings, or try the other practice modes.", secondary: true)
                }

                ForEach(ConversationScenario.catalog) { scenario in
                    Button { Task { await start(scenario) } } label: {
                        WordwellListRow(title: scenario.title, detail: scenario.objective) {
                            Image(systemName: "bubble.left.and.bubble.right")
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(unavailable || isStarting)
                    .opacity(unavailable ? 0.5 : 1)
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func checkAvailability() async {
        guard let service else { unavailable = true; return }
        let profile = try? await settings.profile()
        let available = await service.availability(languageCode: "en") == .available
        unavailable = !available || profile?.aiEnabled == false
    }

    private func start(_ scenario: ConversationScenario) async {
        guard let service, !isStarting else { return }
        isStarting = true
        defer { isStarting = false }
        guard let profile = try? await settings.profile(), profile.aiEnabled else { unavailable = true; return }
        let learner = LearnerProfile(
            level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? scenario.level,
            nativeLanguageCode: profile.explanationLanguage)
        session = ConversationSession(scenario: scenario, targetWords: await targetWords(for: scenario),
                                      service: service, learner: learner)
    }

    /// Scenario words first, then up to two of the learner's weak words.
    private func targetWords(for scenario: ConversationScenario) async -> [String] {
        let weakIDs = (try? await progress.weakQuizWordIDs(limit: 2)) ?? []
        var weak: [String] = []
        for id in weakIDs {
            if let entry = try? await dictionary.entry(id: id) { weak.append(entry.lemma) }
        }
        return Array((scenario.targetLemmas + weak).reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } })
    }
}

// MARK: - Session view

private struct ConversationSessionView: View {
    let session: ConversationSession
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository
    let onClose: () -> Void

    @State private var draft = ""
    @FocusState private var focused: Bool

    var body: some View {
        if case .summary(let summary) = session.phase {
            ConversationSummaryView(session: session, summary: summary, dictionary: dictionary,
                                    library: library, onClose: onClose)
        } else {
            chat
        }
    }

    private var chat: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        objectiveCard
                        ForEach(session.turns) { turn in
                            bubble(turn).id(turn.id)
                        }
                        status
                    }
                    .padding(WordwellLayout.screenPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: session.turns.count) {
                    if let last = session.turns.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                }
            }
            composer
        }
    }

    private var objectiveCard: some View {
        WordwellCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.scenario.title)
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText(session.scenario.objective)
                Label(session.objectiveMet ? "Objective complete" : "Try to use: \(session.targetWords.prefix(4).joined(separator: ", "))",
                      systemImage: session.objectiveMet ? "checkmark.circle" : "text.quote")
                    .font(WordwellType.meta)
                    .foregroundStyle(WordwellColor.secondaryText)
                WordwellPrivacyCue()
            }
        }
    }

    private func bubble(_ turn: ConversationTurn) -> some View {
        let mine = turn.speaker == .learner
        return HStack {
            if mine { Spacer(minLength: 40) }
            Text(turn.text)
                .font(WordwellType.body)
                .foregroundStyle(mine ? WordwellColor.paper : WordwellColor.ink)
                .padding(12)
                .background(mine ? WordwellColor.ink : WordwellColor.surface,
                            in: RoundedRectangle(cornerRadius: WordwellLayout.cardRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: WordwellLayout.cardRadius)
                        .strokeBorder(mine ? .clear : WordwellColor.border, lineWidth: 1)
                }
                .accessibilityLabel("\(mine ? "You" : session.scenario.title): \(turn.text)")
            if !mine { Spacer(minLength: 40) }
        }
    }

    @ViewBuilder
    private var status: some View {
        switch session.phase {
        case .replying:
            HStack(spacing: 8) { ProgressView(); Text("Thinking…").font(WordwellType.meta).foregroundStyle(WordwellColor.secondaryText) }
        case .summarizing:
            HStack(spacing: 8) { ProgressView(); Text("Preparing your review…").font(WordwellType.meta).foregroundStyle(WordwellColor.secondaryText) }
        case .failed:
            VStack(alignment: .leading, spacing: 8) {
                WordwellBodyText("That did not work. Your messages are kept.", secondary: true)
                Button("Try again") { session.retry() }.buttonStyle(WordwellButtonStyle(.secondary))
            }
        case .unavailable:
            WordwellBodyText("AI unavailable on this device right now.", secondary: true)
        case .chatting where !session.canSend:
            WordwellBodyText("That was the last turn. Finish to see your review.", secondary: true)
        default:
            EmptyView()
        }
    }

    private var composer: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                TextField("Write in English", text: $draft, axis: .vertical)
                    .font(WordwellType.body)
                    .lineLimit(1...4)
                    .focused($focused)
                    .padding(.horizontal, 14)
                    .frame(minHeight: WordwellLayout.minimumTouchTarget)
                    .overlay { Capsule().strokeBorder(WordwellColor.ink, lineWidth: 1) }
                    .disabled(!session.canSend)
                    .submitLabel(.send)
                    .onSubmit(send)
                Button(action: send) {
                    Image(systemName: "arrow.up").frame(width: 20, height: 20)
                }
                .buttonStyle(WordwellButtonStyle(.primary))
                .disabled(!session.canSend || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send")
            }
            HStack {
                Text("\(session.learnerTurnCount)/\(ConversationScenario.maxLearnerTurns) turns")
                    .font(WordwellType.meta).foregroundStyle(WordwellColor.secondaryText)
                Spacer()
                Button("Finish and review") { focused = false; session.finish() }
                    .buttonStyle(WordwellButtonStyle(.secondary))
                    .disabled(!session.canFinish)
            }
        }
        .padding(.horizontal, WordwellLayout.screenPadding)
        .padding(.vertical, 12)
        .background(WordwellColor.paper)
    }

    private func send() {
        let text = draft
        draft = ""
        session.send(text)
    }
}

// MARK: - Summary

private struct ConversationSummaryView: View {
    let session: ConversationSession
    let summary: ConversationSummary
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository
    let onClose: () -> Void

    private struct SaveCandidate: Identifiable {
        let id: String
        let lemma: String
        var saved: Bool
    }

    @State private var candidates: [SaveCandidate] = []
    @State private var saveFailed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Your review", subtitle: session.scenario.title)
                WordwellPrivacyCue()

                Label(summary.objectiveMet || session.objectiveMet ? "You reached the objective" : "Objective not fully reached yet",
                      systemImage: summary.objectiveMet || session.objectiveMet ? "checkmark.circle" : "circle.dashed")
                    .font(WordwellType.body)
                    .foregroundStyle(WordwellColor.ink)

                section("Mistakes to fix") {
                    if summary.mistakes.isEmpty {
                        WordwellBodyText("No clear mistakes found. Nice work.", secondary: true)
                    }
                    ForEach(Array(summary.mistakes.enumerated()), id: \.offset) { _, mistake in
                        WordwellCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(mistake.original).font(WordwellType.body).strikethrough().foregroundStyle(WordwellColor.secondaryText)
                                Text(mistake.better).font(WordwellType.body).foregroundStyle(WordwellColor.ink)
                                WordwellBodyText(mistake.why, secondary: true)
                            }
                        }
                    }
                }

                if !summary.expressions.isEmpty {
                    section("Useful expressions") {
                        ForEach(summary.expressions, id: \.self) { WordwellBodyText($0) }
                    }
                }

                if !candidates.isEmpty {
                    section("Words to save") {
                        ForEach($candidates) { $candidate in
                            HStack {
                                Text(candidate.lemma).font(WordwellType.body).foregroundStyle(WordwellColor.ink)
                                Spacer()
                                Button(candidate.saved ? "Saved" : "Save") { Task { await save(candidate.id) } }
                                    .buttonStyle(WordwellButtonStyle(.secondary))
                                    .disabled(candidate.saved)
                            }
                        }
                        if saveFailed { WordwellBodyText("Could not save this word. Please try again.", secondary: true) }
                    }
                }

                Button("Back to scenes", action: onClose)
                    .buttonStyle(WordwellButtonStyle(.primary))
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .task { await resolveCandidates() }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(WordwellType.sectionLabel).foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    /// Only words that exist in the dictionary are offered; anything else the model said is dropped.
    private func resolveCandidates() async {
        var result: [SaveCandidate] = []
        for lemma in summary.wordsToSave {
            guard let entry = try? await dictionary.entry(lemma: lemma),
                  !result.contains(where: { $0.id == entry.id }) else { continue }
            let saved = (try? await library.state(for: entry.id)) != nil
            result.append(SaveCandidate(id: entry.id, lemma: entry.lemma, saved: saved))
        }
        candidates = result
    }

    private func save(_ wordID: String) async {
        do {
            try await library.save(wordID: wordID)
            if let index = candidates.firstIndex(where: { $0.id == wordID }) { candidates[index].saved = true }
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
