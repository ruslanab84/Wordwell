import ArgumentParser
import Foundation
import WordwellAICore

struct Find: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Reverse dictionary: find a word from a description.",
        discussion: """
        Dictionary retrieval finds candidates offline; the model (if available) proposes more and can read
        descriptions in other languages. Every word shown exists in the dictionary and its definition comes from it.
        """
    )

    @Argument(help: "Description, e.g. \"fear of heights\" (English or your language).") var query: String
    @Option(help: "Maximum results.") var limit = 5
    @Flag(help: "Skip the model and use dictionary retrieval only.") var offline = false
    @Option(help: "SQLite dictionary built with `db build` (FTS5 retrieval, as in the app).") var db: String?
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await StudyEnvironment.perform(options, database: db) { env in
            let (result, elapsed) = try await timed {
                try await env.finder.find(query, learner: env.learner, limit: limit, useAI: !offline)
            }
            env.output.emit(result, elapsed: elapsed) { StudyRenderer.finder(result) }
        }
    }
}

struct Story: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Write a short story that uses your words.",
        discussion: "Target words are highlighted (tap-to-define data is in --json). Stories are regenerated until every word appears."
    )

    @Option(parsing: .upToNextOption, help: "Target words (2–8).") var words: [String]
    @Option(help: "Optional topic, e.g. weekend.") var topic: String?
    @Option(help: "SQLite dictionary built with `db build`.") var db: String?
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await StudyEnvironment.perform(options, database: db) { env in
            var contexts: [AIWordContext] = []
            for lemma in words { contexts.append(try await env.word(lemma)) }

            let (story, elapsed) = try await timed {
                try await env.stories.story(words: contexts, topicHint: topic, learner: env.learner)
            }
            let bold = isatty(STDOUT_FILENO) != 0
            env.output.emit(story, elapsed: elapsed) {
                StudyRenderer.story(story, glossary: contexts, bold: bold)
            }
        }
    }
}

struct Placement: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Estimate a starting level from a short written sample.",
        discussion: """
        Three fixed questions, then a model assessment. The level and confidence are computed in code:
        a short sample is capped at B1. The result is an unofficial CEFR estimate.
        """
    )

    @Option(name: .customLong("answer"), help: "Answer to the next question (repeat for each question).") var answers: [String] = []
    @Option(help: "Text file with answers separated by a line containing only ---.") var answersFile: String?
    @Flag(help: "Show the questions and type the answers (finish each with a line containing only '.').") var interactive = false
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await StudyEnvironment.perform(options) { env in
            var texts = answers
            if let answersFile {
                let content = try String(contentsOf: URL(fileURLWithPath: (answersFile as NSString).expandingTildeInPath), encoding: .utf8)
                texts += content.components(separatedBy: "\n---\n")
            }
            if interactive {
                texts = []
                for prompt in PlacementPrompts.standard {
                    print("\n\(prompt.id). \(prompt.text)\n(finish with a line containing only '.')")
                    texts.append(StudyRenderer.readMultiline())
                }
            }
            guard !texts.isEmpty else {
                print(StudyRenderer.placementPrompts())
                return
            }

            let items = zip(PlacementPrompts.standard, texts).map { PlacementAnswer(promptID: $0.id, text: $1) }
            let (result, elapsed) = try await timed { try await env.placement.assess(items) }
            env.output.emit(result, elapsed: elapsed) { StudyRenderer.placement(result) }
        }
    }
}
