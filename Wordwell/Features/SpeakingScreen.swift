import SwiftUI
import WordwellAICore
import WordwellDesign
import WordwellDomain

struct SpeakingScreen: View {
    let progress: any ProgressRepository
    let ai: any LearningAI

    @State private var recorder: OnDeviceSpeechRecognizer
    @State private var startedAt: Date?
    @State private var durationSeconds = 0
    @State private var isStarting = false
    @State private var isSaving = false
    @State private var completed = false
    @State private var message: String?
    @State private var aiAvailable = false
    @State private var timeoutTask: Task<Void, Never>?

    private let topicID = "memorable-day"

    init(progress: any ProgressRepository, ai: any LearningAI, recorder: OnDeviceSpeechRecognizer) {
        self.progress = progress
        self.ai = ai
        _recorder = State(initialValue: recorder)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: "Speaking", subtitle: "Take a moment to find your words")

                Text("A memorable day")
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                WordwellBodyText("Describe a day you remember well. Speak in English for up to 50 seconds.")

                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Questions to guide you")
                    WordwellBodyText("Where were you, and who was with you?")
                    WordwellBodyText("What happened that made the day special?")
                    WordwellBodyText("How did you feel afterward?")
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
        .task {
            aiAvailable = await ai.availability(languageCode: "en") == .available
        }
        .onDisappear {
            timeoutTask?.cancel()
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

            sectionTitle("Get feedback")
            WordwellBodyText("You spoke for \(durationSeconds) seconds. Read your transcript and notice one idea you could add next time.")

            sectionTitle("Common mistakes")
            WordwellBodyText(aiAvailable
                ? "Language feedback is coming in a later update."
                : "AI language feedback is unavailable on this device right now. Your speaking session was saved.", secondary: true)

            sectionTitle("A better answer")
            WordwellBodyText("Try answering one of the guiding questions with an extra detail. A rewritten answer is unavailable right now.", secondary: true)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(WordwellType.sectionLabel)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

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
        } catch {
            message = "Could not save this session. Please try again."
        }
    }
}
