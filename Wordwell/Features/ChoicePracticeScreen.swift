import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct ChoicePracticeScreen: View {
    let mode: ChoicePracticeMode
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository
    let progress: any ProgressRepository
    let settings: any LearningSettingsRepository
    let player: PronunciationPlayer

    @Environment(\.dismiss) private var dismiss
    @State private var questions: [WordwellDomain.QuizQuestion] = []
    @State private var words: [String: WordEntry] = [:]
    @State private var index = 0
    @State private var selected: Int?
    @State private var played = false
    @State private var correct = 0
    @State private var missed: [WordwellDomain.QuizQuestion] = []
    @State private var startedAt = Date.now
    @State private var variant: EnglishVariant = .us
    @State private var loading = true
    @State private var failed = false
    @State private var saveFailed = false
    @State private var voiceUnavailable = false
    @State private var saving = false

    private var title: String { mode == .quiz ? "Quick quiz" : "Listening" }

    var body: some View {
        Group {
            if loading {
                ProgressView("Preparing \(title.lowercased())")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if failed {
                ContentUnavailableView {
                    Label("Practice unavailable", systemImage: "book.closed")
                } description: {
                    Text("Local words could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            } else if questions.isEmpty {
                ContentUnavailableView("Not enough words", systemImage: "book.closed",
                                       description: Text(mode == .quiz
                                           ? "Save at least one word from the dictionary to start a quiz."
                                           : "Four distinct dictionary words are needed for this activity."))
            } else if index == questions.count {
                completion
            } else {
                question(questions[index])
            }
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .onDisappear { player.stop() }
        .alert("Could not save your answer", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again. This answer was not counted.")
        }
    }

    private func question(_ item: WordwellDomain.QuizQuestion) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                Text("Question \(index + 1) of \(questions.count)")
                    .font(WordwellType.sectionLabel)
                    .foregroundStyle(WordwellColor.secondaryText)
                Text(item.prompt)
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)

                if mode == .listening {
                    Button(played ? "Play again" : "Play audio") {
                        let english = variant == .both ? .us : variant
                        voiceUnavailable = !player.speak(words[item.wordID]?.word ?? "", variant: english)
                        played = !voiceUnavailable
                    }
                    .buttonStyle(WordwellButtonStyle(.primary))
                    .accessibilityHint("Hear the word spoken on this device")
                    if voiceUnavailable {
                        WordwellBodyText("An English voice is unavailable on this device.", secondary: true)
                    }
                    WordwellBodyText("Listen, then choose the word you heard.", secondary: true)
                }

                ForEach(item.choices.indices, id: \.self) { choice in
                    Button {
                        Task { await submit(choice, item: item) }
                    } label: {
                        HStack(alignment: .top) {
                            Text(item.choices[choice])
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            if selected != nil && choice == item.correctChoiceIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .accessibilityHidden(true)
                            } else if choice == selected {
                                Image(systemName: "xmark.circle.fill")
                                    .accessibilityHidden(true)
                            }
                        }
                        .font(WordwellType.body)
                        .foregroundStyle(WordwellColor.ink)
                        .padding(WordwellLayout.cardPadding)
                        .frame(maxWidth: .infinity, minHeight: WordwellLayout.minimumTouchTarget)
                        .background(WordwellColor.surface, in: RoundedRectangle(cornerRadius: WordwellLayout.cardRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: WordwellLayout.cardRadius)
                                .strokeBorder(WordwellColor.border, lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(selected != nil || saving || (mode == .listening && !played))
                    .accessibilityLabel(item.choices[choice])
                }

                if let selected {
                    Text(selected == item.correctChoiceIndex ? "Correct" : "The correct answer is \(item.choices[item.correctChoiceIndex]).")
                        .font(WordwellType.body)
                        .foregroundStyle(WordwellColor.ink)
                        .accessibilityAddTraits(.updatesFrequently)
                    if let definition = words[item.wordID]?.senses.first?.definition, mode == .listening {
                        WordwellBodyText(definition, secondary: true)
                    }
                    if mode == .quiz, selected != item.correctChoiceIndex,
                       let word = words[item.wordID], let definition = word.senses.first?.definition {
                        ExplainMistakeCard(
                            mistake: MistakeContext(
                                kind: .vocabulary, topic: word.lemma, prompt: item.prompt,
                                chosen: item.choices[selected], correct: item.choices[item.correctChoiceIndex],
                                fact: "\(word.lemma): \(definition)"),
                            settings: settings)
                            .id(item.id)
                    }
                    Button(index + 1 == questions.count ? "See results" : "Next question") {
                        index += 1
                        self.selected = nil
                        played = false
                        voiceUnavailable = false
                        startedAt = .now
                    }
                    .buttonStyle(WordwellButtonStyle(.primary))
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text("\(title) complete")
                .font(WordwellType.screenTitle)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("\(correct) of \(questions.count) correct")
            if !missed.isEmpty {
                Text("To review")
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                ForEach(missed) { item in
                    WordwellBodyText(words[item.wordID]?.word ?? item.wordID, secondary: true)
                }
                if mode == .quiz {
                    Button("Practice mistakes") { retryMissed() }
                        .buttonStyle(WordwellButtonStyle(.primary))
                }
            }
            Button("Done") { dismiss() }
                .buttonStyle(WordwellButtonStyle(mode == .quiz && !missed.isEmpty ? .secondary : .primary))
        }
        .padding(WordwellLayout.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func retryMissed() {
        questions = missed
        missed = []
        index = 0
        correct = 0
        selected = nil
        startedAt = .now
    }

    private func load() async {
        loading = true
        failed = false
        do {
            variant = (try? await settings.profile().preferredEnglishVariant) ?? .us
            let savedIDs = try await library.allSavedWords().map(\.wordID)
            let weak = Set((try? await progress.weakQuizWordIDs(limit: 5)) ?? [])
            // Weakest saved words first, then a random sample of the rest.
            // ponytail: no recency weighting; add last-asked date to rank stale words higher.
            let targetIDs = (savedIDs.filter(weak.contains) + savedIDs.filter { !weak.contains($0) }.shuffled())
                .prefix(5).map { $0 }
            var entries: [WordEntry] = []
            func add(_ entry: WordEntry?) {
                if let entry, !entries.contains(where: { $0.id == entry.id }) { entries.append(entry) }
            }
            for id in targetIDs { add(try await dictionary.entry(id: id)) }
            // Distractor pool: other saved words, then fixed lemmas only while the pool is small.
            for id in savedIDs.filter({ !targetIDs.contains($0) }).shuffled().prefix(10) {
                add(try await dictionary.entry(id: id))
            }
            if entries.count < 14 {
                for lemma in ["family", "happy", "garden", "journey", "book", "learn", "listen", "speak", "river", "music"] {
                    add(try await dictionary.entry(lemma: lemma))
                }
            }
            guard !Task.isCancelled else { return }
            words = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
            questions = mode == .quiz && targetIDs.isEmpty
                ? [] : DeterministicPractice.questions(from: entries, targetIDs: targetIDs, mode: mode)
            missed = []
            index = 0
            selected = nil
            correct = 0
            played = false
            startedAt = .now
        } catch {
            guard !Task.isCancelled else { return }
            failed = true
        }
        loading = false
    }

    private func submit(_ choice: Int, item: WordwellDomain.QuizQuestion) async {
        guard !saving, selected == nil, (mode == .quiz || played) else { return }
        saving = true
        defer { saving = false }
        let seconds = min(max(Int(Date.now.timeIntervalSince(startedAt)), 1), 120)
        do {
            if mode == .quiz {
                try await progress.recordQuizAnswer(QuizAnswerEvent(
                    wordID: item.wordID, isCorrect: choice == item.correctChoiceIndex, durationSeconds: seconds
                ))
            } else {
                try await progress.recordListening(ListeningEvent(durationSeconds: seconds))
            }
            player.stop()
            selected = choice
            if choice == item.correctChoiceIndex { correct += 1 } else { missed.append(item) }
        } catch {
            saveFailed = true
        }
    }
}
