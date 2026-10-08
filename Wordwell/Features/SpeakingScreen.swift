import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct SpeakingScreen: View {
    let progress: any ProgressRepository
    let ai: any LearningAI
    let settings: any LearningSettingsRepository
    let dictionary: any DictionaryRepository
    let library: any WordLibraryRepository

    private enum FeedbackPhase {
        case idle, loading, result(SpeakingFeedback), unavailable, failed
    }

    /// The day's topic, cached so it stays the same until midnight.
    private struct DailyTopic: Codable {
        let dayKey: String
        let prompt: SpeakingPrompt
    }

    private static let cacheKey = "wordwell.speaking.dailyTopic"
    private static let fallbackPrompt = SpeakingPrompt(
        topic: "A memorable day",
        guidingQuestions: [
            "Where were you, and who was with you?",
            "What happened that made the day special?",
            "How did you feel afterward?",
        ],
        targetWords: []
    )

    @State private var recorder: OnDeviceSpeechRecognizer
    @State private var startedAt: Date?
    @State private var durationSeconds = 0
    @State private var isStarting = false
    @State private var isSaving = false
    @State private var completed = false
    @State private var message: String?
    @State private var timeoutTask: Task<Void, Never>?

    @State private var prompt = SpeakingScreen.fallbackPrompt
    @State private var topicID = "memorable-day"
    @State private var targets: [AIWordContext] = []
    @State private var phase: FeedbackPhase = .idle
    @State private var feedbackTask: Task<Void, Never>?
    @State private var activeRequest: UUID?

    init(progress: any ProgressRepository, ai: any LearningAI, settings: any LearningSettingsRepository,
         dictionary: any DictionaryRepository, library: any WordLibraryRepository,
         recorder: OnDeviceSpeechRecognizer) {
        self.progress = progress
        self.ai = ai
        self.settings = settings
        self.dictionary = dictionary
        self.library = library
        _recorder = State(initialValue: recorder)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Speaking", subtitle: "Take a moment to find your words")
                WordwellPrivacyCue()

                Text(prompt.topic)
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText("Speak in English for up to 50 seconds.")
                if !prompt.targetWords.isEmpty {
                    WordwellBodyText("Try to use: \(prompt.targetWords.joined(separator: ", "))")
                }

                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Questions to guide you")
                    ForEach(prompt.guidingQuestions, id: \.self) { WordwellBodyText($0) }
                }

                if completed {
                    feedback
                } else {
                    capture
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .navigationTitle("Speaking")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadTopic() }
        .onDisappear {
            timeoutTask?.cancel()
            feedbackTask?.cancel()
            recorder.discard()
        }
    }

    private var capture: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            if recorder.isRecording {
                Label("Recording on this device", systemImage: "waveform")
                    .font(WordwellType.meta)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.updatesFrequently)
                Button("Stop speaking") { stop() }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else if startedAt == nil {
                Button("Start speaking") { Task { await start() } }
                    .buttonStyle(WordwellButtonStyle(.primary))
                    .disabled(isStarting)
            } else {
                Button("Finish session") { Task { await finish() } }
                    .buttonStyle(WordwellButtonStyle(.primary))
                    .disabled(recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                Button("Try again") { Task { await start() } }
                    .buttonStyle(WordwellButtonStyle(.secondary))
                    .disabled(isSaving)
            }

            if !recorder.transcript.isEmpty {
                sectionTitle("Your words")
                WordwellBodyText(recorder.transcript)
            }
            if let message { WordwellBodyText(message, secondary: true) }
            if let error = recorder.errorMessage { WordwellBodyText(error, secondary: true) }
            WordwellBodyText("Audio stays on this device and is not saved. Your transcript is shown only during this session.", secondary: true)
        }
    }

    private var feedback: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            sectionTitle("Your words")
            WordwellBodyText(recorder.transcript)
            WordwellBodyText("You spoke for \(durationSeconds) seconds. Your session was saved.", secondary: true)

            switch phase {
            case .idle:
                EmptyView()
            case .loading:
                WordwellBodyText("Working on this device…", secondary: true)
            case .unavailable:
                WordwellBodyText("On-device AI is unavailable or turned off in Settings. Read your transcript and notice one idea you could add next time.", secondary: true)
            case .failed:
                WordwellBodyText("Could not review this answer.", secondary: true)
                Button("Try again") { requestFeedback() }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            case .result(let result):
                feedbackCards(result)
            }
        }
    }

    @ViewBuilder
    private func feedbackCards(_ result: SpeakingFeedback) -> some View {
        WordwellCard {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("Feedback")
                WordwellBodyText(result.summary)
                ForEach(result.strengths, id: \.self) { WordwellBodyText("Good: \($0)", secondary: true) }
            }
        }
        if !result.mistakes.isEmpty {
            WordwellCard {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Common mistakes")
                    ForEach(Array(result.mistakes.enumerated()), id: \.offset) { _, issue in
                        WordwellBodyText("\(issue.fragment) → \(issue.fix): \(issue.explanation)", secondary: true)
                    }
                }
            }
        }
        if !result.usedTargetWords.isEmpty || !result.missedTargetWords.isEmpty {
            WordwellCard {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Your words of the day")
                    if !result.usedTargetWords.isEmpty {
                        WordwellBodyText("Used: \(result.usedTargetWords.joined(separator: ", "))")
                    }
                    if !result.missedTargetWords.isEmpty {
                        WordwellBodyText("Try next time: \(result.missedTargetWords.joined(separator: ", "))", secondary: true)
                    }
                }
            }
        }
        if !result.betterAnswer.isEmpty {
            WordwellCard {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("A better answer")
                    WordwellBodyText(result.betterAnswer)
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(WordwellType.sectionLabel)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Topic of the day

    private var dayKey: String { Date.now.formatted(.iso8601.year().month().day()) }

    private func learner(_ profile: LearningProfile) -> LearnerProfile {
        LearnerProfile(level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
                       nativeLanguageCode: profile.explanationLanguage)
    }

    /// Builds today's topic from the learner's own words. Any failure keeps the fixed topic,
    /// so recording never depends on AI.
    private func loadTopic() async {
        guard let profile = try? await settings.profile(), profile.aiEnabled,
              await ai.availability(languageCode: "en") == .available else { return }

        let today = dayKey
        if let data = UserDefaults.standard.data(forKey: Self.cacheKey),
           let cached = try? JSONDecoder().decode(DailyTopic.self, from: data), cached.dayKey == today {
            targets = await contexts(for: cached.prompt.targetWords)
            prompt = cached.prompt
            topicID = "daily-\(today)"
            return
        }

        let words = await pickWords()
        guard !words.isEmpty,
              let generated = try? await ai.speakingPrompt(targetWords: words, learner: learner(profile)) else { return }
        guard !Task.isCancelled else { return }
        if let data = try? JSONEncoder().encode(DailyTopic(dayKey: today, prompt: generated)) {
            UserDefaults.standard.set(data, forKey: Self.cacheKey)
        }
        targets = words
        prompt = generated
        topicID = "daily-\(today)"
    }

    /// Recent quiz misses first, then saved words still being learned; up to three.
    private func pickWords() async -> [AIWordContext] {
        var ids = (try? await progress.weakQuizWordIDs(limit: 4)) ?? []
        let saved = (try? await library.allSavedWords()) ?? []
        ids += saved.filter { $0.status != .mastered }.map(\.wordID)

        var picked: [AIWordContext] = []
        var seen = Set<String>()
        for id in ids where seen.insert(id).inserted {
            if let entry = try? await dictionary.entry(id: id) { picked.append(entry.aiContext()) }
            if picked.count == 3 { break }
        }
        return picked
    }

    private func contexts(for lemmas: [String]) async -> [AIWordContext] {
        var result: [AIWordContext] = []
        for lemma in lemmas {
            if let entry = try? await dictionary.entry(lemma: lemma) { result.append(entry.aiContext()) }
        }
        return result
    }

    // MARK: - Recording

    private func start() async {
        guard !isStarting else { return }
        isStarting = true
        defer { isStarting = false }
        message = nil
        timeoutTask?.cancel()
        do {
            try await recorder.start()
            startedAt = .now
            timeoutTask = Task {
                try? await Task.sleep(for: .seconds(50))
                if !Task.isCancelled, recorder.isRecording { stop() }
            }
        } catch {
            message = (error as? LocalizedError)?.errorDescription ?? "Could not start recording. Please try again."
        }
    }

    private func stop() {
        timeoutTask?.cancel()
        if let startedAt {
            durationSeconds = min(max(Int(Date.now.timeIntervalSince(startedAt)), 1), 50)
        }
        recorder.stop()
        if recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            message = "No speech was transcribed. Try again when you are ready."
        }
    }

    private func finish() async {
        guard !isSaving, !recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            if durationSeconds == 0, let startedAt {
                durationSeconds = min(max(Int(Date.now.timeIntervalSince(startedAt)), 1), 50)
            }
            try await progress.recordSpeaking(SpeakingEvent(
                id: UUID(), topicID: topicID, completedAt: .now, durationSeconds: durationSeconds
            ))
            completed = true
            message = nil
            requestFeedback()
        } catch {
            message = "Could not save this session. Please try again."
        }
    }

    // MARK: - Feedback

    private func requestFeedback() {
        let transcript = recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else { return }
        feedbackTask?.cancel()
        let id = UUID()
        activeRequest = id
        phase = .loading
        feedbackTask = Task {
            guard let profile = try? await settings.profile(), profile.aiEnabled else {
                if activeRequest == id { phase = .unavailable }
                return
            }
            do {
                let result = try await ai.feedback(transcript: transcript, prompt: prompt,
                                                   targetWords: targets, learner: learner(profile))
                try Task.checkCancellation()
                if activeRequest == id { phase = .result(result) }
            } catch is CancellationError {
                if activeRequest == id { phase = .idle }
            } catch let error as AIError {
                guard activeRequest == id else { return }
                switch error {
                case .unavailable, .unsupportedLanguage: phase = .unavailable
                case .cancelled: phase = .idle
                default: phase = .failed
                }
            } catch {
                if activeRequest == id { phase = .failed }
            }
        }
    }
}
