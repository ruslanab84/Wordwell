import AVFoundation
import Observation
import WordwellDomain

@MainActor
@Observable
final class PronunciationPlayer: NSObject, AVSpeechSynthesizerDelegate {
    enum State { case idle, playing, paused, finished }

    private(set) var state: State = .idle
    /// Fraction of the current utterance already spoken, 0...1.
    private(set) var progress = 0.0

    @ObservationIgnored private let synthesizer = AVSpeechSynthesizer()
    @ObservationIgnored private var current: ObjectIdentifier?
    @ObservationIgnored private var interruptionObserver: NSObjectProtocol?

    override init() {
        super.init()
        synthesizer.delegate = self
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
        ) { [weak self] note in
            let began = (note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt)
                .flatMap(AVAudioSession.InterruptionType.init) == .began
            MainActor.assumeIsolated { if began { self?.pause() } }
        }
    }

    @discardableResult
    func speak(_ text: String, variant: EnglishVariant) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let language = variant == .uk ? "en-GB" : "en-US"
        guard let voice = Self.bestVoice(language: language) else { return false }
        synthesizer.stopSpeaking(at: .immediate)
        // Recorder leaves the shared session in .record; default ambient also obeys the silent switch.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = 0.45
        current = ObjectIdentifier(utterance)
        progress = 0
        state = .playing
        synthesizer.speak(utterance)
        return true
    }

    func pause() {
        guard state == .playing, synthesizer.pauseSpeaking(at: .word) else { return }
        state = .paused
    }

    func resume() {
        guard state == .paused, synthesizer.continueSpeaking() else { return }
        state = .playing
    }

    func stop() {
        current = nil
        synthesizer.stopSpeaking(at: .immediate)
        state = .idle
        progress = 0
        releaseSession()
    }

    private func releaseSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Installed premium/enhanced voices sound far better than the default compact one.
    private static func bestVoice(language: String) -> AVSpeechSynthesisVoice? {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == language }
            .max { $0.quality.rawValue < $1.quality.rawValue }
            ?? AVSpeechSynthesisVoice(language: language)
    }

    // MARK: AVSpeechSynthesizerDelegate

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                       willSpeakRangeOfSpeechString range: NSRange,
                                       utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        let total = max(1, utterance.speechString.utf16.count)
        let fraction = Double(range.location + range.length) / Double(total)
        Task { @MainActor in
            if current == id { progress = min(1, fraction) }
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            guard current == id else { return }
            progress = 1
            state = .finished
            releaseSession()
        }
    }

    // Keep state truthful when the system pauses/cancels speech (interruptions) without our call.
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in if current == id, state == .playing { state = .paused } }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in if current == id, state == .paused { state = .playing } }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let id = ObjectIdentifier(utterance)
        Task { @MainActor in
            guard current == id else { return }
            current = nil
            state = .idle
            progress = 0
        }
    }
}
