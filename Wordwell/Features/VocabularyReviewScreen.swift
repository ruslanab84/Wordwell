import SwiftUI
import WordwellDesign
import WordwellDomain

struct VocabularyReviewScreen: View {
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository
    let progress: any ProgressRepository
    let illustrations: any IllustrationBindingRepository

    @Environment(\.dismiss) private var dismiss
    @State private var words: [WordEntry] = []
    @State private var wordIllustrations: [String: IllustrationBinding] = [:]
    @State private var index = 0
    @State private var revealed = false
    @State private var startedAt = Date.now
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var saveFailed = false
    @State private var isSaving = false
    @State private var hasSavedWords = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Preparing review")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if loadFailed {
                ContentUnavailableView {
                    Label("Review unavailable", systemImage: "book.closed")
                } description: {
                    Text("Your saved words could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await load() } }
                }
            } else if words.isEmpty {
                ContentUnavailableView(
                    hasSavedWords ? "All caught up" : "No saved words yet",
                    systemImage: "book.closed",
                    description: Text(hasSavedWords
                        ? "Your saved words are not due for review yet."
                        : "Find a word in Search and save it to start practicing.")
                )
            } else if index == words.count {
                completion
            } else {
                review(words[index])
            }
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Vocabulary review")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .alert("Could not save review", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again. Your answer was not counted.")
        }
    }

    private func review(_ entry: WordEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                Text("Word \(index + 1) of \(words.count)")
                    .font(WordwellType.sectionLabel)
                    .foregroundStyle(WordwellColor.secondaryText)
                Text("Recall the meaning")
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)

                WordwellCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            Text(entry.word)
                                .font(WordwellType.headword)
                                .foregroundStyle(WordwellColor.ink)
                            Spacer(minLength: 8)
                            if let illustration = wordIllustrations[entry.id] {
                                BoundIllustration(binding: illustration)
                                    .frame(width: 80, height: 62)
                            }
                        }
                        Text(entry.partOfSpeech.rawValue)
                            .font(WordwellType.meta)
                            .italic()
                            .foregroundStyle(WordwellColor.secondaryText)

                        if revealed {
                            Divider()
                            ForEach(entry.senses.prefix(2)) { sense in
                                WordwellBodyText(sense.definition)
                                if let example = sense.examples.first {
                                    WordwellBodyText("“\(example)”", secondary: true)
                                }
                            }
                        } else {
                            WordwellBodyText("Think of a definition before revealing the answer.", secondary: true)
                        }
                    }
                }

                if revealed {
                    Text("How well did you remember it?")
                        .font(WordwellType.sectionLabel)
                        .foregroundStyle(WordwellColor.ink)
                    HStack(spacing: 10) {
                        Button("Again") { Task { await submit(1) } }
                            .buttonStyle(WordwellButtonStyle(.secondary))
                        Button("Got it") { Task { await submit(4) } }
                            .buttonStyle(WordwellButtonStyle(.primary))
                    }
                    .disabled(isSaving)
                } else {
                    Button("Show meaning") { revealed = true }
                        .buttonStyle(WordwellButtonStyle(.primary))
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var completion: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text("Review complete")
                .font(WordwellType.screenTitle)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("You reviewed \(words.count) \(words.count == 1 ? "word" : "words") today.")
            Button("Done") { dismiss() }
                .buttonStyle(WordwellButtonStyle(.primary))
        }
        .padding(WordwellLayout.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func load() async {
        isLoading = true
        loadFailed = false
        do {
            let saved = try await library.allSavedWords()
            hasSavedWords = !saved.isEmpty
            var due: [WordEntry] = []
            for state in saved {
                let mastery = try await progress.mastery(for: state.wordID)
                guard (mastery?.nextReviewAt ?? .distantPast) <= .now else { continue }
                if let entry = try await dictionary.entry(id: state.wordID), !entry.senses.isEmpty {
                    due.append(entry)
                }
                if due.count == 10 { break }
            }
            var bindings: [String: IllustrationBinding] = [:]
            for entry in due {
                bindings[entry.id] = try? await illustrations.binding(
                    lemma: entry.lemma, partOfSpeech: entry.partOfSpeech,
                    senseID: entry.senses.first?.id, context: .review
                )
            }
            guard !Task.isCancelled else { return }
            words = due
            wordIllustrations = bindings
            index = 0
            revealed = false
            startedAt = .now
        } catch {
            guard !Task.isCancelled else { return }
            loadFailed = true
        }
        isLoading = false
    }

    private func submit(_ quality: Int) async {
        guard !isSaving, index < words.count else { return }
        isSaving = true
        defer { isSaving = false }
        // ponytail: cap time per card so leaving the app open cannot inflate today's practice by hours.
        let seconds = min(max(Int(Date.now.timeIntervalSince(startedAt)), 1), 300)
        let event = ReviewEvent(id: UUID(), wordID: words[index].id, reviewedAt: .now,
                                answerQuality: quality, durationSeconds: seconds)
        do {
            try await progress.recordReview(event)
            index += 1
            revealed = false
            startedAt = .now
        } catch {
            saveFailed = true
        }
    }
}
