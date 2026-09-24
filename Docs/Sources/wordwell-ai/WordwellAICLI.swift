import ArgumentParser

@main
struct WordwellAICLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "wordwell-ai",
        abstract: "Developer CLI for Wordwell AI features on Apple Foundation Models.",
        discussion: """
        Runs the same LearningAI pipeline the app uses (prompts → model → validation) on macOS 26+.
        Use it to iterate on prompts, inspect token usage and run regression eval suites in CI.
        """,
        version: "0.1.0",
        subcommands: [
            Availability.self,
            Explain.self, Examples.self, Compare.self, Mistakes.self, Quiz.self, Improve.self,
            Speak.self, Insight.self,
            Exam.self,
            Inspect.self, Eval.self,
        ]
    )
}
