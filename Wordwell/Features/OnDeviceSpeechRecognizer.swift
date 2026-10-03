import AVFoundation
import Observation
import Speech

enum SpeakingCaptureError: LocalizedError {
    case permissionDenied
    case unavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "Allow microphone and speech recognition in Settings to practice speaking."
        case .unavailable:
            "On-device English transcription is unavailable on this device."
        }
    }
}

@MainActor
@Observable
final class OnDeviceSpeechRecognizer {
    private var recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var captureID = UUID()

    private(set) var transcript = ""
    private(set) var isRecording = false
    private(set) var errorMessage: String?

    func start(locale: Locale = Locale(identifier: "en-US")) async throws {
        stop()
        if recognizer?.locale != locale {
            let candidate = SFSpeechRecognizer(locale: locale)
            // Not every locale ships an on-device model; keep the en-US default rather than fail.
            if candidate?.supportsOnDeviceRecognition == true { recognizer = candidate }
        }
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard speechStatus == .authorized,
              await AVAudioApplication.requestRecordPermission() else {
            throw SpeakingCaptureError.permissionDenied
        }
        guard let recognizer, recognizer.isAvailable, recognizer.supportsOnDeviceRecognition else {
            throw SpeakingCaptureError.unavailable
        }

        transcript = ""
        errorMessage = nil
        let id = UUID()
        captureID = id
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.request = request

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                let text = result?.bestTranscription.formattedString
                let failed = error != nil
                Task { @MainActor [weak self] in
                    guard let self, self.captureID == id else { return }
                    if let text { self.transcript = text }
                    if failed {
                        self.errorMessage = "Transcription stopped. You can try again."
                        self.stop()
                    }
                }
            }
            engine.prepare()
            try engine.start()
            isRecording = true
        } catch {
            stop()
            throw error
        }
    }

    func stop() {
        captureID = UUID()
        if engine.isRunning { engine.stop() }
        if request != nil { engine.inputNode.removeTap(onBus: 0) }
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func discard() {
        stop()
        transcript = ""
        errorMessage = nil
    }
}
