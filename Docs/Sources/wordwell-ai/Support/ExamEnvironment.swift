import ArgumentParser
import Foundation
import WordwellAICore
#if canImport(FoundationModels)
import WordwellAIFoundationModels
#endif

struct ExamEnvironment {
    let service: any ExamPracticeService
    let raw: any ExamPracticeService
    let policy: RestrictedTermsPolicy
    let learner: LearnerProfile
    let output: Output

    init(_ options: CommonOptions) throws {
        policy = try RestrictedTermsPolicy.bundled()
        raw = Self.primary()
        service = ResilientExamPractice(primary: raw, policy: policy)
        learner = options.learner
        output = Output(json: options.json)
    }

    static func perform(_ options: CommonOptions, _ body: (ExamEnvironment) async throws -> Void) async throws {
        let environment = try ExamEnvironment(options)
        do {
            try await body(environment)
        } catch let error as AIError {
            FileHandle.standardError.write(Data("error: \(error) [\(error.localizationKey)]\n".utf8))
            throw ExitCode(2)
        }
    }

    private static func primary() -> any ExamPracticeService {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return FoundationModelsExamPractice()
        }
        #endif
        return UnavailableExamPractice()
    }
}

struct UnavailableExamPractice: ExamPracticeService {
    let identifier = "unavailable"
    let promptVersion = "none"
    private var error: AIError { .unavailable(.osTooOld) }

    func availability(languageCode: String?) async -> AIAvailability { .unavailable(.osTooOld) }
    func prewarm(for task: AITask) async {}
    func speakingTask(part: SpeakingPart, topicHint: String?, learner: LearnerProfile) async throws -> ExamSpeakingTask { throw error }
    func writingTask(kind: WritingTaskKind, topicHint: String?, learner: LearnerProfile) async throws -> ExamWritingTask { throw error }
    func readingSet(questionCount: Int, topicHint: String?, learner: LearnerProfile) async throws -> ExamReadingSet { throw error }
    func assess(speakingTranscript: String, task: ExamSpeakingTask, learner: LearnerProfile) async throws -> ExamAssessment { throw error }
    func assess(writing: String, task: ExamWritingTask, learner: LearnerProfile) async throws -> ExamAssessment { throw error }
}

/// Answer source shared by speaking/writing commands.
struct AnswerInput: ParsableArguments {
    @Option(help: "Answer text (writing) or speech transcript (speaking).") var answer: String?
    @Option(help: "Read the answer from a text file.") var answerFile: String?
    @Flag(help: "Type or paste the answer; finish with a line containing only '.'.") var interactive = false

    func read() throws -> String? {
        if let answer { return answer }
        if let answerFile {
            return try String(contentsOf: URL(fileURLWithPath: (answerFile as NSString).expandingTildeInPath), encoding: .utf8)
        }
        guard interactive else { return nil }
        print("\nYour answer (finish with a line containing only '.'):")
        var lines: [String] = []
        while let line = readLine(), line != "." { lines.append(line) }
        return lines.joined(separator: "\n")
    }
}

/// Accepts "long-turn", "longTurn", "long", "data", "opinion".
func flexibleCase<E: RawRepresentable & CaseIterable>(_ type: E.Type, _ argument: String) -> E? where E.RawValue == String {
    let key = argument.replacingOccurrences(of: "-", with: "").lowercased()
    return E.allCases.first { $0.rawValue.lowercased() == key }
        ?? E.allCases.first { $0.rawValue.lowercased().hasPrefix(key) }
}

extension SpeakingPart: ExpressibleByArgument {
    public init?(argument: String) {
        guard let value = flexibleCase(Self.self, argument) else { return nil }
        self = value
    }
}

extension WritingTaskKind: ExpressibleByArgument {
    public init?(argument: String) {
        guard let value = flexibleCase(Self.self, argument) else { return nil }
        self = value
    }
}
