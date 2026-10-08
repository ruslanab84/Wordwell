import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

/// AI writes the gap sentences for the learner's weak words; `QuizAssembler` builds the options
/// and `correctIndex` in code, and answers are scored here against that index, never by the model.
struct QuizMeScreen: View {
    let ai: any LearningAI
    let dictionary: any DictionaryRepository
    let progress: any ProgressRepository
    let settings: any LearningSettingsRepository

    private struct Item: Identifiable {
        let wordID: String
        let lemma: String
        let question: WordwellAICore.QuizQuestion
        var id: String { question.id }
    }

    private enum Phase { case loading, empty, quiz, done, unavailable, failed }

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .loading
    @State private var items: [Item] = []
    @State private var index = 0
    @State private var selected: Int?
    @State private var correct = 0
    @State private var missed: [String] = []
    @State private var startedAt = Date.now
    @State private var saving = false
    @State private var saveFailed = false
    @State private var task: Task<Void, Never>?

    var body: some View {
        Group {
            switch phase {
            case .loading:
                ProgressView("Writing questions on this device…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .empty:
                ContentUnavailableView("No weak words yet", systemImage: "checkmark.circle",
                                       description: Text("Words you miss in Quick quiz show up here."))
            case .unavailable:
                ContentUnavailableView("On-device AI unavailable", systemImage: "sparkles",
                                       description: Text("Apple Intelligence is unavailable or turned off in Settings."))
            case .failed:
                ContentUnavailableView {
                    Label("Could not build the quiz", systemImage: "book.closed")
                } actions: {
                    Button("Try again") { start() }
                }
            case .quiz:
                if items.indices.contains(index) { question(items[index]) }
            case .done:
                completion
            }
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Quiz Me")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if items.isEmpty { start() } }
        .onDisappear { task?.cancel() }
        .alert("Could not save your answer", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again. This answer was not counted.")
        }
    }

    private func question(_ item: Item) -> some View {
        let q = item.question
        return ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                WordwellPrivacyCue()
                Text("Question \(index + 1) of \(items.count)")
                    .font(WordwellType.sectionLabel)
                    .foregroundStyle(WordwellColor.secondaryText)
                Text(q.prompt)
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)

                ForEach(q.options.indices, id: \.self) { choice in
                    Button {
                        Task { await submit(choice, item: item) }
                    } label: {
                        HStack(alignment: .top) {
                            Text(q.options[choice])
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            if selected != nil && choice == q.correctIndex {
                                Image(systemName: "checkmark.circle.fill").accessibilityHidden(true)
                            } else if choice == selected {
                                Image(systemName: "xmark.circle.fill").accessibilityHidden(true)
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
                    .disabled(selected != nil || saving)
                    .accessibilityLabel(q.options[choice])
                }

                if let selected {
                    Text(selected == q.correctIndex ? "Correct" : "The correct answer is \(q.options[q.correctIndex]).")
                        .font(WordwellType.body)
                        .foregroundStyle(WordwellColor.ink)
                        .accessibilityAddTraits(.updatesFrequently)
                    if !q.answerForm.isEmpty, q.answerForm.caseInsensitiveCompare(item.lemma) != .orderedSame {
                        WordwellBodyText("In the sentence: \(q.answerForm)", secondary: true)
                    }
                    Button(index + 1 == items.count ? "See results" : "Next question") {
                        index += 1
                        self.selected = nil
                        startedAt = .now
                        if index == items.count { phase = .done }
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
            Text("Quiz Me complete")
                .font(WordwellType.screenTitle)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("\(correct) of \(items.count) correct")
            if !missed.isEmpty {
                Text("To review")
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                ForEach(missed, id: \.self) { WordwellBodyText($0, secondary: true) }
            }
            Button("Done") { dismiss() }
                .buttonStyle(WordwellButtonStyle(.primary))
        }
        .padding(WordwellLayout.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func start() {
        task?.cancel()
        phase = .loading
        items = []
        index = 0
        selected = nil
        correct = 0
        missed = []
        task = Task { await load() }
    }

    private func load() async {
        guard let profile = try? await settings.profile(), profile.aiEnabled else {
            if !Task.isCancelled { phase = .unavailable }
            return
        }
        let learner = LearnerProfile(
            level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
            nativeLanguageCode: profile.explanationLanguage
        )
        let ids = (try? await progress.weakQuizWordIDs(limit: 5)) ?? []
        guard !ids.isEmpty else {
            if !Task.isCancelled { phase = .empty }
            return
        }
        let lookup = DictionaryAILookupAdapter(repository: dictionary)
        var built: [Item] = []
        var unavailable = false
        for id in ids {
            do {
                guard let entry = try await dictionary.entry(id: id) else { continue }
                let context = entry.aiContext()
                let distractors = try await lookup.distractors(for: entry.lemma, level: context.cefrLevel, limit: 3)
                // ponytail: one question per word; raise questionCount for longer sessions.
                let quiz = try await ai.quiz(for: context, distractors: distractors, learner: learner, questionCount: 1)
                if let q = quiz.questions.first {
                    built.append(Item(wordID: entry.id, lemma: entry.lemma, question: q))
                }
            } catch is CancellationError {
                return
            } catch let error as AIError {
                switch error {
                case .cancelled: return
                case .unavailable, .unsupportedLanguage: unavailable = true
                default: continue // invalidResponse etc: skip this word
                }
                break
            } catch {
                continue
            }
            if unavailable { break }
        }
        guard !Task.isCancelled else { return }
        if unavailable && built.isEmpty { phase = .unavailable; return }
        items = built
        startedAt = .now
        phase = built.isEmpty ? .failed : .quiz
    }

    private func submit(_ choice: Int, item: Item) async {
        guard !saving, selected == nil else { return }
        saving = true
        defer { saving = false }
        let seconds = min(max(Int(Date.now.timeIntervalSince(startedAt)), 1), 120)
        let isCorrect = choice == item.question.correctIndex
        do {
            try await progress.recordQuizAnswer(QuizAnswerEvent(
                wordID: item.wordID, isCorrect: isCorrect, durationSeconds: seconds
            ))
            selected = choice
            if isCorrect { correct += 1 } else { missed.append(item.lemma) }
        } catch {
            saveFailed = true
        }
    }
}
