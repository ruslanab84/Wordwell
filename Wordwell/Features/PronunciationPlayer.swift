import AVFoundation
import WordwellDomain

@MainActor
final class PronunciationPlayer {
    private let synthesizer = AVSpeechSynthesizer()

    @discardableResult
    func speak(_ text: String, variant: EnglishVariant) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        let language = variant == .uk ? "en-GB" : "en-US"
        guard let voice = AVSpeechSynthesisVoice(language: language) else { return false }
        synthesizer.stopSpeaking(at: .immediate)
        // Recorder leaves the shared session in .record; default ambient also obeys the silent switch.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio)
        try? session.setActive(true)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = 0.45
        synthesizer.speak(utterance)
        return true
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
