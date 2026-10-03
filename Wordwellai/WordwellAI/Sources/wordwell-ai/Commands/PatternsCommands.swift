import ArgumentParser
import Foundation
import WordwellAICore

struct NotebookOptions: ParsableArguments {
    @Option(help: "Notebook JSON file. Defaults to ~/.wordwell-ai/mistakes.json.") var notebook: String?

    var store: MistakeNotebookStore { MistakeNotebookStore(path: notebook) }
}

struct Patterns: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Mistake patterns: notebook → ranked patterns → weekly mini-lesson.",
        discussion: """
        Mistakes are grouped by a rule-based classifier (articles, prepositions, verb forms, agreement, plurals,
        word order; word-level types use the category hint). Only the mini-lesson uses the model, and its practice
        pairs must be classified as the same pattern by the same rules.
        """,
        subcommands: [PatternsAdd.self, PatternsCapture.self, PatternsList.self,
                      PatternsReport.self, PatternsLesson.self, PatternsSeed.self]
    )
}

struct PatternsAdd: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "add", abstract: "Add a mistake to the notebook.")

    @Argument(help: "Sentence with the mistake.") var wrong: String
    @Argument(help: "The corrected sentence.") var right: String
    @Option(help: "Hint for word-level mistakes: grammar, wordChoice, collocation, spelling, register, other.") var kind: SentenceIssue.Kind?
    @Option(help: "Short explanation.") var explanation: String?
    @Option(help: "Backdate the entry by N days (for testing).") var daysAgo = 0
    @OptionGroup var notebook: NotebookOptions

    func run() throws {
        let record = MistakeRecord(wrong: wrong, right: right, hint: kind, explanation: explanation,
                                   date: Date().addingTimeInterval(-Double(daysAgo) * 86_400))
        try notebook.store.append([record])
        print("Saved · \(StudyRenderer.title(record.pattern))")
    }
}

struct PatternsCapture: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "capture",
        abstract: "Correct a sentence with AI and save each fix to the notebook."
    )

    @Argument(help: "Learner sentence (quote it).") var sentence: String
    @OptionGroup var notebook: NotebookOptions
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await StudyEnvironment.perform(options) { env in
            let improvement = try await env.learning.improve(sentence: sentence, target: nil, learner: env.learner)
            guard !improvement.isAlreadyCorrect else {
                print("✓ The sentence is correct. Nothing to save.")
                return
            }

            // One record per issue: the original sentence with only that fix applied, so each is classified on its own.
            var records: [MistakeRecord] = []
            for issue in improvement.issues {
                guard let range = improvement.original.range(of: issue.fragment, options: .caseInsensitive) else { continue }
                var fixed = improvement.original
                fixed.replaceSubrange(range, with: issue.fix)
                guard fixed.normalizedForComparison != improvement.original.normalizedForComparison else { continue }
                records.append(MistakeRecord(wrong: improvement.original, right: fixed, hint: issue.kind,
                                             explanation: issue.explanation, source: .improveSentence))
            }
            try notebook.store.append(records)
            print(TextRenderer.improvement(improvement))
            for record in records { print("Saved · \(StudyRenderer.title(record.pattern))") }
        }
    }
}

struct PatternsList: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "list", abstract: "List notebook entries with their pattern.")

    @Option(help: "Show at most N entries.") var limit = 20
    @OptionGroup var notebook: NotebookOptions

    func run() throws {
        let records = try notebook.store.load().sorted { $0.date > $1.date }.prefix(max(1, limit))
        print(StudyRenderer.records(Array(records)))
    }
}

struct PatternsReport: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "report",
        abstract: "Rank patterns by recency-weighted frequency (offline, no AI)."
    )

    @Option(help: "Window in days.") var days = 28
    @Option(help: "Mistakes needed before a pattern gets a lesson.") var min = 3
    @Flag(help: "Print machine-readable JSON.") var json = false
    @OptionGroup var notebook: NotebookOptions

    func run() throws {
        let analyzer = MistakePatternAnalyzer(windowDays: days, minOccurrences: min)
        let stats = analyzer.analyze(try notebook.store.load())
        Output(json: json).emit(stats) { StudyRenderer.report(stats, analyzer: analyzer) }
    }
}

struct PatternsLesson: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lesson",
        abstract: "Generate the weekly mini-lesson for the most costly pattern."
    )

    @Option(help: "Teach this pattern instead of the top one: articles, prepositions, verbForms, agreement, plurals, wordOrder, spelling, wordChoice, collocation, register.") var pattern: MistakePattern?
    @Option(help: "Window in days.") var days = 28
    @Option(help: "Mistakes needed before a pattern gets a lesson.") var min = 3
    @Flag(help: "Do the exercises in the terminal.") var interactive = false
    @OptionGroup var notebook: NotebookOptions
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await StudyEnvironment.perform(options) { env in
            let analyzer = MistakePatternAnalyzer(windowDays: days, minOccurrences: min)
            let coach = MistakeCoach(service: env.tools, analyzer: analyzer)

            let (lesson, elapsed) = try await timed {
                try await coach.weeklyLesson(from: try notebook.store.load(), learner: env.learner, pattern: pattern)
            }
            guard let lesson else {
                print("Nothing to teach yet: no pattern has \(min)+ mistakes in the last \(days) days. Run: wordwell-ai patterns report")
                return
            }

            guard interactive, !options.json else {
                env.output.emit(lesson, elapsed: elapsed) { StudyRenderer.lesson(lesson, showAnswers: true) }
                return
            }

            print(StudyRenderer.lesson(lesson, showAnswers: false))
            var score = 0
            for (index, exercise) in lesson.content.exercises.enumerated() {
                print("\n\(index + 1). \(exercise.incorrect)\n> ", terminator: "")
                let answer = readLine() ?? ""
                if answer.normalizedForComparison == exercise.correct.normalizedForComparison {
                    score += 1
                    print("✓")
                } else {
                    print("✗ \(exercise.correct)")
                }
            }
            print("\nScore: \(score)/\(lesson.content.exercises.count)")
        }
    }
}

struct PatternsSeed: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "seed",
        abstract: "Fill the notebook with sample mistakes to try report and lesson."
    )

    @Flag(help: "Replace existing entries.") var force = false
    @OptionGroup var notebook: NotebookOptions

    func run() throws {
        let store = notebook.store
        let existing = try store.load()
        guard force || existing.isEmpty else {
            print("The notebook already has entries. Use --force to replace them.")
            return
        }

        let samples: [(wrong: String, right: String, hint: SentenceIssue.Kind?, daysAgo: Double)] = [
            ("I have a apple", "I have an apple", nil, 1),
            ("She is teacher", "She is a teacher", nil, 2),
            ("He wants to buy car", "He wants to buy a car", nil, 5),
            ("I need a information", "I need information", nil, 9),
            ("She depends of her parents", "She depends on her parents", nil, 1),
            ("We discussed about the plan", "We discussed the plan", nil, 3),
            ("I am in the school", "I am at school", nil, 8),
            ("He go to school every day", "He goes to school every day", nil, 2),
            ("She have a car", "She has a car", nil, 4),
            ("The information are useful", "The information is useful", nil, 12),
            ("Yesterday I go to the cinema", "Yesterday I went to the cinema", nil, 3),
            ("I am agree with you", "I agree with you", nil, 6),
            ("Two book are on the table", "Two books are on the table", nil, 7),
            ("Can you borrow me your pen?", "Can you lend me your pen?", .wordChoice, 5),
            ("I like very much music", "I like music very much", nil, 10),
            ("I recieve a letter", "I receive a letter", .spelling, 14),
        ]
        let now = Date()
        try store.save(samples.map {
            MistakeRecord(wrong: $0.wrong, right: $0.right, hint: $0.hint,
                          date: now.addingTimeInterval(-$0.daysAgo * 86_400))
        })
        print("Saved \(samples.count) sample mistakes to \(store.url.path)")
    }
}
