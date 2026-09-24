import ArgumentParser
import Foundation
import WordwellAICore

struct Speak: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create a speaking task; with --transcript also return feedback.",
        discussion: "Transcript simulates speech-to-text output, so the feedback pipeline can be tested without audio."
    )

    @Option(parsing: .upToNextOption, help: "Target words.") var words: [String]
    @Option(help: "Learner answer as a speech-recognition transcript.") var transcript: String?
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            var targets: [AIWordContext] = []
            for lemma in words { targets.append(try await env.word(lemma)) }

            let (prompt, promptElapsed) = try await timed {
                try await env.ai.speakingPrompt(targetWords: targets, learner: env.learner)
            }
            guard let transcript else {
                env.output.emit(prompt, elapsed: promptElapsed) { TextRenderer.speakingPrompt(prompt) }
                return
            }

            let (feedback, elapsed) = try await timed {
                try await env.ai.feedback(transcript: transcript, prompt: prompt, targetWords: targets, learner: env.learner)
            }
            if !options.json { print(TextRenderer.speakingPrompt(prompt) + "\n") }
            env.output.emit(feedback, elapsed: elapsed) { TextRenderer.feedback(feedback) }
        }
    }
}

struct Insight: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate a weekly progress insight from stats.")

    @Option(help: "Words learned.") var learned = 24
    @Option(help: "Words reviewed.") var reviewed = 140
    @Option(help: "Speaking sessions.") var speaking = 3
    @Option(help: "Listening minutes.") var listening = 45
    @Option(help: "Quiz accuracy 0…1.") var accuracy = 0.78
    @Option(help: "Streak days.") var streak = 5
    @Option(parsing: .upToNextOption, help: "Weak words.") var weak: [String] = []
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let stats = WeeklyStats(wordsLearned: learned, wordsReviewed: reviewed, speakingSessions: speaking,
                                    listeningMinutes: listening, quizAccuracy: accuracy, streakDays: streak, weakWords: weak)
            let (result, elapsed) = try await timed {
                try await env.ai.weeklyInsight(stats, learner: env.learner)
            }
            env.output.emit(result, elapsed: elapsed) { TextRenderer.insight(result) }
        }
    }
}
