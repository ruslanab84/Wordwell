import ArgumentParser
import Foundation
import WordwellAICore
#if canImport(FoundationModels)
import WordwellAIFoundationModels
#endif

struct Availability: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Check on-device model availability, context size and language support.")

    @OptionGroup var options: CommonOptions

    func run() async throws {
        let env = try CLIEnvironment(options)
        let availability = await env.ai.availability(languageCode: options.language)
        print("Provider:       \(env.ai.identifier)")
        print("Prompt version: \(env.ai.promptVersion)")
        print("Availability:   \(availability)")
        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            print("Context size:   \(TokenBudget().contextSize) tokens")
        }
        #endif
        if let language = options.language {
            print("Language '\(language)': \(availability.isAvailable ? "supported" : "not supported")")
        }
    }
}

/// Prints the exact instructions + prompt sent to the model with token counts.
/// Primary tool for token optimisation: every prompt change should be checked here.
struct Inspect: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Show rendered instructions, prompt and token usage for a task.")

    @Argument(help: "Task: \(AITask.allCases.map(\.rawValue).joined(separator: ", ")).") var task: AITask
    @Argument(help: "Headword.") var lemma: String
    @Option(help: "Second word for compare.") var second: String?
    @Option(help: "Sentence or transcript for improveSentence / speakingFeedback.") var text: String?
    @OptionGroup var options: CommonOptions

    func run() async throws {
        #if canImport(FoundationModels)
        guard #available(macOS 26.0, *) else { throw ValidationError("Requires macOS 26 or later.") }
        let env = try CLIEnvironment(options)
        let word = try await env.word(lemma)
        let builder = PromptBuilder()
        let learner = env.learner

        let prompt: String
        switch task {
        case .explain: prompt = await builder.explain(word, learner: learner, languageCode: options.language)
        case .examples: prompt = await builder.examples(word, learner: learner, count: 3)
        case .compare:
            guard let second else { throw ValidationError("--second is required for compare.") }
            prompt = await builder.compare(word, try await env.word(second), learner: learner)
        case .commonMistakes: prompt = await builder.commonMistakes(word, learner: learner)
        case .quiz: prompt = await builder.gapSentences(word, learner: learner, count: 4)
        case .improveSentence: prompt = await builder.improve(text ?? "I decided go home.", target: word, learner: learner)
        case .speakingPrompt: prompt = await builder.speakingPrompt([word], learner: learner)
        case .speakingFeedback:
            let speaking = SpeakingPrompt(topic: "Weekend plans", guidingQuestions: ["What will you do?"], targetWords: [word.lemma])
            prompt = await builder.speakingFeedback(transcript: text ?? "i decide to visit my friend", prompt: speaking, words: [word], learner: learner)
        case .weeklyInsight:
            prompt = await builder.weeklyInsight(
                WeeklyStats(wordsLearned: 20, wordsReviewed: 120, speakingSessions: 2, listeningMinutes: 30, quizAccuracy: 0.8, streakDays: 4),
                learner: learner)
        }

        let instructions = AIPrompts.instructions(for: task)
        let budget = builder.budget
        let instructionTokens = await budget.tokenCount(instructions)
        let promptTokens = await budget.tokenCount(prompt)

        print("── INSTRUCTIONS (\(instructionTokens) tokens) ──\n\(instructions)\n")
        print("── PROMPT (\(promptTokens) tokens) ──\n\(prompt)\n")
        print("── BUDGET ──")
        print("input \(instructionTokens + promptTokens) + reserved output \(budget.reservedOutputTokens) / context \(budget.contextSize)")
        print("note: guided generation also adds the schema to the prompt; measure real usage with `eval --json`.")
        #else
        throw ValidationError("FoundationModels is not available on this platform.")
        #endif
    }
}

struct Eval: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run a regression suite of AI cases and fail below a pass-rate threshold.",
        discussion: "Run after every prompt or schema change and bump AIPrompts.version when behaviour changes."
    )

    struct EvalCase: Codable {
        let id: String
        let task: AITask
        let lemma: String
        var second: String?
        var sentence: String?
        var language: String?
        var expectIssues: Bool?
        var maxLatencyMs: Int?
    }

    struct EvalSuite: Codable {
        let cases: [EvalCase]
    }

    struct EvalResult: Codable {
        let id: String
        let passed: Bool
        let latencyMs: Int
        let note: String
    }

    struct EvalReport: Codable {
        let promptVersion: String
        let passRate: Double
        let results: [EvalResult]
    }

    @Option(help: "Suite JSON file. Defaults to the bundled eval-suite.json.") var suite: String?
    @Option(help: "Minimum pass rate 0…1.") var minPassRate = 0.8
    @OptionGroup var options: CommonOptions

    func run() async throws {
        let env = try CLIEnvironment(options)
        let cases = try loadSuite().cases
        var results: [EvalResult] = []

        for evalCase in cases {
            let (outcome, elapsed) = await timed { await execute(evalCase, env: env) }
            var passed = outcome.passed
            var note = outcome.note
            if let limit = evalCase.maxLatencyMs, elapsed.milliseconds > limit {
                passed = false
                note += " | slow: \(elapsed.milliseconds) ms > \(limit) ms"
            }
            results.append(EvalResult(id: evalCase.id, passed: passed, latencyMs: elapsed.milliseconds, note: note))
            if !options.json {
                print("\(passed ? "PASS" : "FAIL")  \(evalCase.id)  \(elapsed.milliseconds) ms  \(note)")
            }
        }

        let passRate = results.isEmpty ? 0 : Double(results.filter(\.passed).count) / Double(results.count)
        let report = EvalReport(promptVersion: env.ai.promptVersion, passRate: passRate, results: results)
        env.output.emit(report) {
            "\nPass rate: \(Int(passRate * 100))% (min \(Int(minPassRate * 100))%) · prompts \(report.promptVersion)"
        }
        if passRate < minPassRate { throw ExitCode.failure }
    }

    private func loadSuite() throws -> EvalSuite {
        let url: URL
        if let suite {
            url = URL(fileURLWithPath: (suite as NSString).expandingTildeInPath)
        } else if let bundled = Bundle.module.url(forResource: "eval-suite", withExtension: "json") {
            url = bundled
        } else {
            throw ValidationError("Bundled eval suite not found.")
        }
        return try JSONDecoder().decode(EvalSuite.self, from: Data(contentsOf: url))
    }

    /// The resilient pipeline already validates headword usage, sense IDs and quoted fragments;
    /// here we add case-level expectations.
    private func execute(_ evalCase: EvalCase, env: CLIEnvironment) async -> (passed: Bool, note: String) {
        do {
            let word = try await env.word(evalCase.lemma)
            let learner = env.learner
            switch evalCase.task {
            case .explain:
                let result = try await env.ai.explain(word, learner: learner, languageCode: evalCase.language)
                return (!result.examples.isEmpty, "\(result.examples.count) valid examples")
            case .examples:
                let result = try await env.ai.examples(for: word, learner: learner, count: 3)
                return (result.count >= 2, "\(result.count)/3 valid")
            case .compare:
                guard let second = evalCase.second else { return (false, "missing 'second'") }
                let result = try await env.ai.compare(word, try await env.word(second), learner: learner)
                return (result.examples.count == 2, "\(result.examples.count)/2 valid examples")
            case .commonMistakes:
                let result = try await env.ai.commonMistakes(for: word, learner: learner)
                return (true, "\(result.count) mistakes")
            case .quiz:
                let distractors = try await env.dictionary.distractors(for: word.lemma, level: word.cefrLevel, limit: 6)
                let result = try await env.ai.quiz(for: word, distractors: distractors, learner: learner, questionCount: 3)
                return (result.questions.count == 3, "\(result.questions.count)/3 questions")
            case .improveSentence:
                guard let sentence = evalCase.sentence else { return (false, "missing 'sentence'") }
                let result = try await env.ai.improve(sentence: sentence, target: word, learner: learner)
                let expected = evalCase.expectIssues ?? true
                return (result.isAlreadyCorrect != expected, "issues: \(result.issues.count), expected \(expected ? "some" : "none")")
            case .speakingPrompt:
                let result = try await env.ai.speakingPrompt(targetWords: [word], learner: learner)
                return (result.guidingQuestions.count == 3, result.topic)
            case .speakingFeedback, .weeklyInsight:
                return (false, "not covered by this suite runner")
            }
        } catch {
            return (false, "error: \(error)")
        }
    }
}
