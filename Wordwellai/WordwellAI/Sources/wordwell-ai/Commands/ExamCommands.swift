import ArgumentParser
import Foundation
import WordwellAICore

struct Exam: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Original exam-style practice: speaking, writing, reading.",
        discussion: "All material is newly generated, brand-neutral and checked by the restricted-terms policy. Levels are unofficial CEFR estimates.",
        subcommands: [ExamSpeaking.self, ExamWriting.self, ExamReading.self, ExamAudit.self, ExamFingerprint.self]
    )
}

struct ExamSpeaking: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "speaking", abstract: "Speaking task; add an answer to get an assessment.")

    @Option(help: "interview | long-turn | discussion") var part: SpeakingPart = .interview
    @Option(help: "Optional topic area, e.g. travel.") var topic: String?
    @OptionGroup var input: AnswerInput
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await ExamEnvironment.perform(options) { env in
            let (task, elapsed) = try await timed {
                try await env.service.speakingTask(part: part, topicHint: topic, learner: env.learner)
            }
            if input.interactive && !options.json { print(ExamRenderer.speaking(task)) }
            guard let answer = try input.read() else {
                env.output.emit(task, elapsed: elapsed) { ExamRenderer.speaking(task) }
                return
            }
            let assessment = try await env.service.assess(speakingTranscript: answer, task: task, learner: env.learner)
            env.output.emit(assessment) { ExamRenderer.assessment(assessment) }
        }
    }
}

struct ExamWriting: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "writing", abstract: "Writing task; add an answer to get an assessment.")

    @Option(help: "data-description | opinion-essay") var kind: WritingTaskKind = .opinionEssay
    @Option(help: "Optional topic area, e.g. technology.") var topic: String?
    @OptionGroup var input: AnswerInput
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await ExamEnvironment.perform(options) { env in
            let (task, elapsed) = try await timed {
                try await env.service.writingTask(kind: kind, topicHint: topic, learner: env.learner)
            }
            if input.interactive && !options.json { print(ExamRenderer.writing(task)) }
            guard let answer = try input.read() else {
                env.output.emit(task, elapsed: elapsed) { ExamRenderer.writing(task) }
                return
            }
            let assessment = try await env.service.assess(writing: answer, task: task, learner: env.learner)
            env.output.emit(assessment) { ExamRenderer.assessment(assessment) }
        }
    }
}

struct ExamReading: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "reading", abstract: "Reading passage with True / False / Not stated statements.")

    @Option(help: "Number of statements (3–6).") var questions = 5
    @Option(help: "Optional topic area.") var topic: String?
    @Flag(help: "Answer in the terminal (t / f / n).") var interactive = false
    @OptionGroup var options: CommonOptions

    func run() async throws {
        try await ExamEnvironment.perform(options) { env in
            let (set, elapsed) = try await timed {
                try await env.service.readingSet(questionCount: questions, topicHint: topic, learner: env.learner)
            }
            guard interactive, !options.json else {
                env.output.emit(set, elapsed: elapsed) { ExamRenderer.reading(set, showAnswers: true) }
                return
            }

            print(ExamRenderer.reading(ExamReadingSet(id: set.id, title: set.title, passage: set.passage, questions: []), showAnswers: false))
            var score = 0
            for question in set.questions {
                print("\n\(question.id). \(question.statement)\n(t/f/n) > ", terminator: "")
                let key: Character = readLine()?.lowercased().first ?? " "
                let answer: ReadingAnswer? = switch key {
                case "t": .agrees
                case "f": .contradicts
                case "n": .notStated
                default: nil
                }
                if answer == question.answer {
                    score += 1
                    print("✓")
                } else {
                    print("✗ \(ExamRenderer.label(question.answer))\(question.evidence.map { " «\($0)»" } ?? "")")
                }
            }
            print("\nScore: \(score)/\(set.questions.count)")
        }
    }
}

/// Measures how often the raw model output violates the brand policy or structure rules.
/// Run after every prompt change; fails when the raw violation rate exceeds the threshold.
struct ExamAudit: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "audit", abstract: "Generate material and report policy/validation failures.")

    @Option(help: "Rounds per task type.") var runs = 3
    @Option(help: "Maximum allowed raw restricted-term rate 0…1.") var maxViolationRate = 0.0
    @OptionGroup var options: CommonOptions

    struct Report: Codable {
        var generated = 0
        var restrictedTermHits = 0
        var structuralFailures = 0
        var errors = 0
    }

    func run() async throws {
        let env = try ExamEnvironment(options)
        let validator = ExamValidator(policy: env.policy)
        var report = Report()

        for round in 1...max(1, runs) {
            for part in SpeakingPart.allCases {
                await check("speaking.\(part.rawValue) #\(round)", policy: env.policy, &report) {
                    let task = try await env.raw.speakingTask(part: part, topicHint: nil, learner: env.learner)
                    return ([task.topic] + task.prompts, { _ = try validator.validate(task) })
                }
            }
            for kind in WritingTaskKind.allCases {
                await check("writing.\(kind.rawValue) #\(round)", policy: env.policy, &report) {
                    let task = try await env.raw.writingTask(kind: kind, topicHint: nil, learner: env.learner)
                    let texts = [task.prompt] + (task.data.map { [$0.title, $0.unit] + $0.columns + $0.rows.map(\.label) } ?? [])
                    return (texts, { _ = try validator.validate(task) })
                }
            }
            await check("reading #\(round)", policy: env.policy, &report) {
                let set = try await env.raw.readingSet(questionCount: 5, topicHint: nil, learner: env.learner)
                return ([set.title, set.passage] + set.questions.map(\.statement), { _ = try validator.validate(set, questionCount: 5) })
            }
        }

        let rate = report.generated == 0 ? 0 : Double(report.restrictedTermHits) / Double(report.generated)
        env.output.emit(report) {
            """

            Generated: \(report.generated) · restricted-term hits: \(report.restrictedTermHits) (\(Int(rate * 100))%) · structural failures: \(report.structuralFailures) · errors: \(report.errors)
            Items with hits or structural failures are regenerated by ResilientExamPractice and never shown to users.
            """
        }
        if rate > maxViolationRate { throw ExitCode.failure }
    }

    private func check(_ label: String, policy: RestrictedTermsPolicy, _ report: inout Report,
                       _ produce: () async throws -> ([String], () throws -> Void)) async {
        do {
            let (texts, validate) = try await produce()
            report.generated += 1
            // Only fingerprints are reported, so logs never contain brand names.
            let hits = policy.violations(in: texts)
            report.restrictedTermHits += hits.isEmpty ? 0 : 1
            var status = hits.isEmpty ? "ok" : "restricted term (fp \(hits.map { String($0, radix: 16) }.joined(separator: ",")))"
            do { try validate() } catch {
                report.structuralFailures += 1
                if hits.isEmpty { status = "structure: \(error)" }
            }
            if !options.json { print("\(status == "ok" ? "PASS" : "FAIL")  \(label)  \(status)") }
        } catch {
            report.errors += 1
            if !options.json { print("ERR   \(label)  \(error)") }
        }
    }
}

/// Prints the fingerprint for a new restricted term. The term itself is never stored.
struct ExamFingerprint: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "fingerprint", abstract: "Hash a term for restricted-terms.json.")

    @Argument(help: "Term to block (quoted).") var term: String

    func run() throws {
        let hex = String(RestrictedTermsPolicy.fingerprint(of: term), radix: 16)
        print(String(repeating: "0", count: 16 - hex.count) + hex)
    }
}
