import ArgumentParser
import Foundation
import WordwellAICore

struct Explain: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Explain a word simply, optionally in the learner's language.")

    @Argument(help: "Headword.") var lemma: String
    @Flag(help: "Stream the explanation as it is generated.") var stream = false
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let word = try await env.word(lemma)
            guard stream, !options.json else {
                let (result, elapsed) = try await timed {
                    try await env.ai.explain(word, learner: env.learner, languageCode: options.language)
                }
                env.output.emit(result, elapsed: elapsed) { TextRenderer.explanation(result) }
                return
            }

            var shown = ""
            var final: ExplanationDraft?
            for try await draft in env.ai.explanationStream(word, learner: env.learner, languageCode: options.language) {
                if let text = draft.explanation, text.hasPrefix(shown), text.count > shown.count {
                    env.output.write(String(text.dropFirst(shown.count)))
                    shown = text
                }
                if draft.isComplete { final = draft }
            }
            print()
            final?.examples.forEach { print("  • \($0)") }
        }
    }
}

struct Examples: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Generate validated example sentences.")

    @Argument(help: "Headword.") var lemma: String
    @Option(help: "Number of sentences (1–5).") var count = 3
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let word = try await env.word(lemma)
            let (result, elapsed) = try await timed {
                try await env.ai.examples(for: word, learner: env.learner, count: count)
            }
            env.output.emit(result, elapsed: elapsed) { TextRenderer.examples(result) }
        }
    }
}

struct Compare: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Compare two similar words.")

    @Argument(help: "First word.") var first: String
    @Argument(help: "Second word.") var second: String
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let (a, b) = (try await env.word(first), try await env.word(second))
            let (result, elapsed) = try await timed {
                try await env.ai.compare(a, b, learner: env.learner)
            }
            env.output.emit(result, elapsed: elapsed) { TextRenderer.comparison(result) }
        }
    }
}

struct Mistakes: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Show typical learner mistakes with a word.")

    @Argument(help: "Headword.") var lemma: String
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let word = try await env.word(lemma)
            let (result, elapsed) = try await timed {
                try await env.ai.commonMistakes(for: word, learner: env.learner)
            }
            env.output.emit(result, elapsed: elapsed) { TextRenderer.mistakes(result) }
        }
    }
}

struct Quiz: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Build a gap-fill quiz (distractors come from the dictionary).")

    @Argument(help: "Headword.") var lemma: String
    @Option(help: "Number of questions (1–5).") var questions = 3
    @Flag(help: "Answer the questions in the terminal.") var interactive = false
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let word = try await env.word(lemma)
            let distractors = try await env.dictionary.distractors(for: lemma, level: word.cefrLevel, limit: 6)
            let (quiz, elapsed) = try await timed {
                try await env.ai.quiz(for: word, distractors: distractors, learner: env.learner, questionCount: questions)
            }

            guard interactive, !options.json else {
                env.output.emit(quiz, elapsed: elapsed) { TextRenderer.quiz(quiz, showAnswers: true) }
                return
            }

            var score = 0
            for (index, question) in quiz.questions.enumerated() {
                print(TextRenderer.quiz(WordQuiz(lemma: quiz.lemma, questions: [question]), showAnswers: false)
                    .replacingOccurrences(of: "1. ", with: "\(index + 1). ", options: .anchored))
                print("> ", terminator: "")
                let answer = readLine().flatMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                if answer == question.correctIndex + 1 {
                    score += 1
                    print("✓\n")
                } else {
                    print("✗ \(question.options[question.correctIndex]) (\(question.answerForm))\n")
                }
            }
            print("Score: \(score)/\(quiz.questions.count)")
        }
    }
}

struct Improve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Correct a learner sentence and explain each fix.")

    @Argument(help: "Learner sentence (quote it).") var sentence: String
    @Option(help: "Target word the learner was practising.") var target: String?
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await CLIEnvironment.perform(options) { env in
            let targetWord = try await target.asyncMap { try await env.word($0) }
            let (result, elapsed) = try await timed {
                try await env.ai.improve(sentence: sentence, target: targetWord, learner: env.learner)
            }
            env.output.emit(result, elapsed: elapsed) { TextRenderer.improvement(result) }
        }
    }
}

extension Optional {
    func asyncMap<U>(_ transform: (Wrapped) async throws -> U) async rethrows -> U? {
        guard let self else { return nil }
        return try await transform(self)
    }
}
