import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct SkillsCheckScreen: View {
    let progress: any ProgressRepository
    let settings: any LearningSettingsRepository
    let exam: (any ExamPracticeService)?
    let player: PronunciationPlayer

    @State private var recorder: OnDeviceSpeechRecognizer
    @State private var draft = SkillsCheckDraft()
    @State private var result: SkillsCheckResult?
    @State private var writingAssessment: ExamAssessment?
    @State private var speakingAssessment: ExamAssessment?
    @State private var profile: LearningProfile?
    @State private var aiAvailable = false
    @State private var materialUnavailable = false
    @State private var activeSince: Date?
    @State private var recordingStartedAt: Date?
    @State private var recordingTimeout: Task<Void, Never>?
    @State private var playedListening = false
    @State private var voiceUnavailable = false
    @State private var message: String?
    @State private var saving = false
    @State private var assessing = false
    @FocusState private var writingFocused: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    private let pack = SkillsCheckPack.standard
    private let store = SkillsCheckDraftStore()
    private let sectionNames = ["Reading", "Listening", "Writing", "Speaking"]
    private let suggestedMinutes = [6, 5, 12, 3]

    init(progress: any ProgressRepository, settings: any LearningSettingsRepository,
         exam: (any ExamPracticeService)?, recorder: OnDeviceSpeechRecognizer,
         player: PronunciationPlayer) {
        self.progress = progress
        self.settings = settings
        self.exam = exam
        self.player = player
        _recorder = State(initialValue: recorder)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                if materialUnavailable {
                    ContentUnavailableView("Skills check unavailable", systemImage: "exclamationmark.triangle",
                                           description: Text("The practice material could not be verified."))
                } else if let result {
                    results(result)
                } else {
                    sectionHeader
                    switch draft.section {
                    case 0: reading
                    case 1: listening
                    case 2: writing
                    default: speaking
                    }
                    if let message { WordwellBodyText(message, secondary: true) }
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("English Skills Check")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { writingFocused = false }
            }
        }
        .task { await prepare() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active, result == nil, !materialUnavailable {
                activeSince = .now
            } else {
                pauseClock()
                if phase != .active {
                    player.stop()
                    recordingTimeout?.cancel()
                    recorder.discard()
                    recordingStartedAt = nil
                }
            }
        }
        .onDisappear {
            pauseClock()
            player.stop()
            recordingTimeout?.cancel()
            recorder.discard()
        }
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Part \(draft.section + 1) of 4 · \(sectionNames[draft.section])")
                .font(WordwellType.screenTitle)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let active = activeSince.map { max(0, Int(context.date.timeIntervalSince($0))) } ?? 0
                WordwellBodyText("Suggested: \(suggestedMinutes[draft.section]) min · Elapsed: \((draft.elapsedSeconds[draft.section] + active) / 60) min",
                                 secondary: true)
            }
            WordwellBodyText("You can take more time and continue this session later.", secondary: true)
        }
    }

    private var reading: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text(pack.reading.title)
                .font(WordwellType.cardHeadline)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText(pack.reading.passage)
            questions(pack.reading, answers: draft.readingAnswers) { index, answer in
                draft.readingAnswers[index] = answer
                store.save(draft)
            }
            Button("Continue to listening") { advance() }
                .buttonStyle(WordwellButtonStyle(.primary))
        }
    }

    private var listening: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text(pack.listening.title)
                .font(WordwellType.cardHeadline)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("Listen to the announcement, then answer five questions. The transcript appears after you finish.", secondary: true)
            Button(playedListening ? "Play again" : "Play announcement") {
                let variant = profile?.preferredEnglishVariant == .uk ? EnglishVariant.uk : .us
                if player.speak(pack.listening.passage, variant: variant) {
                    playedListening = true
                    voiceUnavailable = false
                    draft.listeningUnavailable = false
                    store.save(draft)
                } else {
                    voiceUnavailable = true
                    if !playedListening {
                        draft.listeningUnavailable = true
                        store.save(draft)
                    }
                }
            }
            .buttonStyle(WordwellButtonStyle(.primary))

            if voiceUnavailable {
                WordwellBodyText("An English voice is unavailable on this device. You can skip listening and complete the other parts.", secondary: true)
            }
            if playedListening {
                questions(pack.listening, answers: draft.listeningAnswers) { index, answer in
                    draft.listeningAnswers[index] = answer
                    store.save(draft)
                }
            }
            Button(voiceUnavailable && !playedListening ? "Skip listening" : "Continue to writing") {
                if !playedListening { draft.listeningUnavailable = true }
                player.stop()
                advance()
            }
            .buttonStyle(WordwellButtonStyle(.secondary))
            .disabled(!playedListening && !voiceUnavailable)
        }
    }

    private var writing: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text("Describe the data")
                .font(WordwellType.cardHeadline)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText(pack.writing.prompt)
            if let data = pack.writing.data {
                Text(data.title)
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText("Unit: \(data.unit)", secondary: true)
                ForEach(data.rows, id: \.label) { row in
                    WordwellBodyText("\(row.label): " + zip(data.columns, row.values)
                        .map { "\($0.0) \(Int($0.1))" }.joined(separator: " · "))
                }
            }
            WordwellBodyText("Aim for at least \(pack.writing.minimumWords) words. This is a suggested target, not a requirement.", secondary: true)
            TextEditor(text: $draft.writingText)
                .focused($writingFocused)
                .frame(minHeight: 230)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(WordwellColor.surface, in: RoundedRectangle(cornerRadius: WordwellLayout.cardRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: WordwellLayout.cardRadius)
                        .strokeBorder(WordwellColor.border)
                }
                .accessibilityLabel("Your written answer")
                .onChange(of: draft.writingText) { _, text in
                    if text.count > 4_000 { draft.writingText = String(text.prefix(4_000)) }
                    store.save(draft)
                }
            WordwellBodyText("\(WordCounter.count(draft.writingText)) words", secondary: true)
            Button("Continue to speaking") { advance() }
                .buttonStyle(WordwellButtonStyle(.primary))
        }
    }

    private var speaking: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text(pack.speaking.topic)
                .font(WordwellType.cardHeadline)
                .accessibilityAddTraits(.isHeader)
            ForEach(pack.speaking.prompts, id: \.self) { prompt in
                WordwellBodyText("• \(prompt)")
            }
            WordwellBodyText("Take about one minute to prepare, then speak for up to two minutes. Audio stays on this device and is not saved.", secondary: true)

            if recorder.isRecording {
                Label("Recording on this device", systemImage: "waveform")
                    .font(WordwellType.meta)
                Button("Stop speaking") { stopRecording() }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else {
                Button(recordingStartedAt == nil ? "Start speaking" : "Try again") {
                    Task { await startRecording() }
                }
                .buttonStyle(WordwellButtonStyle(.secondary))
            }
            if !recorder.transcript.isEmpty {
                Text("Your words")
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText(recorder.transcript)
            }
            if let error = recorder.errorMessage { WordwellBodyText(error, secondary: true) }
            Button(recorder.transcript.isEmpty ? "Finish without speaking" : "See results") {
                Task { await finish() }
            }
            .buttonStyle(WordwellButtonStyle(.primary))
            .disabled(saving || recorder.isRecording)
        }
    }

    private func questions(_ set: ExamReadingSet, answers: [ReadingAnswer?],
                           choose: @escaping (Int, ReadingAnswer) -> Void) -> some View {
        ForEach(set.questions.indices, id: \.self) { index in
            VStack(alignment: .leading, spacing: 8) {
                Text("\(index + 1). \(set.questions[index].statement)")
                    .font(WordwellType.body)
                    .foregroundStyle(WordwellColor.ink)
                HStack(spacing: 8) {
                    ForEach(ReadingAnswer.allCases, id: \.self) { answer in
                        Button(answer.label) { choose(index, answer) }
                            .buttonStyle(WordwellButtonStyle(answers[index] == answer ? .primary : .secondary))
                            .accessibilityAddTraits(answers[index] == answer ? .isSelected : [])
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func results(_ result: SkillsCheckResult) -> some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            Text("Your skills check")
                .font(WordwellType.screenTitle)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("Reading: \(result.readingCorrect)/5")
            WordwellBodyText(result.listeningCorrect.map { "Listening: \($0)/5" } ?? "Listening: unavailable")
            let total = result.readingCorrect + (result.listeningCorrect ?? 0)
            WordwellBodyText("Objective questions: \(total)/\(result.listeningCorrect == nil ? 5 : 10)")
            WordwellBodyText("CEFR feedback is an unofficial practice estimate and does not predict a test result.", secondary: true)
            if assessing { ProgressView("Checking your writing and speaking") }
            if !draft.writingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Your writing")
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText(draft.writingText)
            }
            assessment("Writing", value: writingAssessment, level: result.writingLevel)
            if !recorder.transcript.isEmpty {
                Text("Your words")
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText(recorder.transcript)
            }
            assessment("Speaking", value: speakingAssessment, level: result.speakingLevel)
            answerReview("Reading", set: pack.reading, answers: draft.readingAnswers)
            if result.listeningCorrect != nil {
                answerReview("Listening", set: pack.listening, answers: draft.listeningAnswers)
                Text("Listening transcript")
                    .font(WordwellType.sectionLabel)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText(pack.listening.passage)
            }
            if let message { WordwellBodyText(message, secondary: true) }
            Button("Done") { dismiss() }
                .buttonStyle(WordwellButtonStyle(.primary))
            Button("Start again") { restart() }
                .buttonStyle(WordwellButtonStyle(.secondary))
                .disabled(assessing)
        }
    }

    @ViewBuilder
    private func assessment(_ title: String, value: ExamAssessment?, level: String?) -> some View {
        Text(title)
            .font(WordwellType.cardHeadline)
            .accessibilityAddTraits(.isHeader)
        if let level {
            WordwellBodyText("Estimated CEFR: \(level)")
        } else if !assessing {
            WordwellBodyText("Automatic assessment unavailable.", secondary: true)
        }
        if let value {
            ForEach(value.criteria, id: \.criterion) { criterion in
                WordwellBodyText("\(criterion.criterion.label): \(criterion.comment)")
            }
            if value.isUnderLength {
                WordwellBodyText("This answer is below the suggested word count.", secondary: true)
            }
        }
    }

    private func answerReview(_ title: String, set: ExamReadingSet, answers: [ReadingAnswer?]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(title) answers")
                .font(WordwellType.cardHeadline)
                .accessibilityAddTraits(.isHeader)
            ForEach(set.questions.indices, id: \.self) { index in
                let question = set.questions[index]
                WordwellBodyText("\(index + 1). \(question.statement)")
                WordwellBodyText("Your answer: \(answers[index]?.label ?? "No answer") · Correct: \(question.answer.label)",
                                 secondary: true)
                if let evidence = question.evidence {
                    WordwellBodyText("From the text: “\(evidence)”", secondary: true)
                }
            }
        }
    }

    private func prepare() async {
        do {
            try pack.validate(policy: RestrictedTermsPolicy.bundled())
        } catch {
            materialUnavailable = true
            return
        }
        if let saved = store.load(pack: pack) { draft = saved }
        profile = try? await settings.profile()
        if profile?.aiEnabled == true, let exam {
            aiAvailable = await exam.availability(languageCode: "en") == .available
        }
        activeSince = .now
    }

    private func pauseClock() {
        guard let activeSince, result == nil else { return }
        draft.elapsedSeconds[draft.section] += max(0, Int(Date.now.timeIntervalSince(activeSince)))
        self.activeSince = nil
        store.save(draft)
    }

    private func advance() {
        pauseClock()
        draft.section += 1
        store.save(draft)
        activeSince = .now
        message = nil
    }

    private func startRecording() async {
        message = nil
        recordingTimeout?.cancel()
        do {
            try await recorder.start()
            recordingStartedAt = .now
            recordingTimeout = Task {
                try? await Task.sleep(for: .seconds(120))
                if !Task.isCancelled && recorder.isRecording { stopRecording() }
            }
        } catch {
            message = (error as? LocalizedError)?.errorDescription ?? "Recording is unavailable. You can finish without speaking."
        }
    }

    private func stopRecording() {
        recordingTimeout?.cancel()
        recorder.stop()
    }

    private func finish() async {
        guard !saving else { return }
        saving = true
        defer { saving = false }
        pauseClock()
        let transcript = recorder.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let readingScore = pack.score(draft.readingAnswers, for: pack.reading)
        let listeningScore = draft.listeningUnavailable ? nil : pack.score(draft.listeningAnswers, for: pack.listening)
        let initial = SkillsCheckResult(id: draft.id, completedAt: .now,
                                        durationSeconds: max(1, draft.elapsedSeconds.reduce(0, +)),
                                        readingCorrect: readingScore, listeningCorrect: listeningScore,
                                        writingLevel: nil, speakingLevel: nil)
        do {
            try await progress.recordSkillsCheck(initial)
        } catch {
            message = "Could not save your result. Please try again."
            activeSince = .now
            return
        }
        result = initial
        store.clear()
        recorder.stop()
        guard aiAvailable, let exam, let profile else { return }
        assessing = true
        defer { assessing = false }
        let learner = LearnerProfile(
            level: WordwellAICore.CEFRLevel(rawValue: profile.cefrLevel.rawValue) ?? .b1,
            nativeLanguageCode: profile.explanationLanguage)
        if !draft.writingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            writingAssessment = try? await exam.assess(writing: draft.writingText, task: pack.writing, learner: learner)
        }
        if !transcript.isEmpty {
            speakingAssessment = try? await exam.assess(speakingTranscript: transcript, task: pack.speaking, learner: learner)
        }
        let updated = SkillsCheckResult(id: initial.id, completedAt: initial.completedAt,
                                        durationSeconds: initial.durationSeconds,
                                        readingCorrect: initial.readingCorrect,
                                        listeningCorrect: initial.listeningCorrect,
                                        writingLevel: writingAssessment?.overallLevel.rawValue,
                                        speakingLevel: speakingAssessment?.overallLevel.rawValue)
        result = updated
        do {
            try await progress.recordSkillsCheck(updated)
        } catch {
            message = "Your answer feedback is visible now, but its level could not be saved."
        }
    }

    private func restart() {
        player.stop()
        recorder.discard()
        draft = SkillsCheckDraft(pack: pack)
        store.save(draft)
        result = nil
        writingAssessment = nil
        speakingAssessment = nil
        playedListening = false
        voiceUnavailable = false
        recordingStartedAt = nil
        message = nil
        activeSince = .now
    }
}

private extension ReadingAnswer {
    var label: String {
        switch self {
        case .agrees: "True"
        case .contradicts: "False"
        case .notStated: "Not stated"
        }
    }
}

private extension AssessmentCriterion {
    var label: String {
        switch self {
        case .taskFulfilment: "Task"
        case .organisation: "Organisation"
        case .vocabulary: "Vocabulary"
        case .grammar: "Grammar"
        }
    }
}
