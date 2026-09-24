import ArgumentParser
import Foundation
import WordwellAICore
#if canImport(FoundationModels)
import WordwellAIFoundationModels
#endif

struct CommonOptions: ParsableArguments {
    @Option(help: "Dictionary JSON file. Defaults to the bundled seed dictionary.")
    var dictionary: String?

    @Option(help: "Learner CEFR level (A1…C2).")
    var level: CEFRLevel = .b1

    @Option(help: "Explanation language as BCP-47 code, e.g. ru.")
    var language: String?

    @Option(parsing: .upToNextOption, help: "Learner interests used to personalise examples.")
    var interests: [String] = []

    @Flag(help: "Print machine-readable JSON.")
    var json = false

    var learner: LearnerProfile {
        LearnerProfile(level: level, nativeLanguageCode: language, interests: interests)
    }
}

extension CEFRLevel: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }
}

extension AITask: ExpressibleByArgument {}

struct CLIEnvironment {
    let dictionary: JSONDictionaryLookup
    let ai: any LearningAI
    let learner: LearnerProfile
    let output: Output

    init(_ options: CommonOptions) throws {
        dictionary = try JSONDictionaryLookup.load(path: options.dictionary)
        ai = AIFactory.make(dictionary: dictionary)
        learner = options.learner
        output = Output(json: options.json)
    }

    func word(_ lemma: String) async throws -> AIWordContext {
        guard let word = try await dictionary.wordContext(for: lemma) else {
            throw ValidationError("'\(lemma)' is not in the dictionary. Pass --dictionary <file> to use another one.")
        }
        return word
    }

    /// Runs a command body and turns AIError into a readable message + exit code 2.
    static func perform(_ options: CommonOptions, _ body: (CLIEnvironment) async throws -> Void) async throws {
        let environment = try CLIEnvironment(options)
        do {
            try await body(environment)
        } catch let error as AIError {
            FileHandle.standardError.write(Data("error: \(error) [\(error.localizationKey)]\n".utf8))
            throw ExitCode(2)
        }
    }
}

enum AIFactory {
    static func make(dictionary: any AIDictionaryLookup) -> any LearningAI {
        ResilientLearningAI(primary: primary(dictionary: dictionary))
    }

    private static func primary(dictionary: any AIDictionaryLookup) -> any LearningAI {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return FoundationModelsLearningAI(dictionary: dictionary)
        }
        #endif
        return UnavailableLearningAI(reason: .osTooOld)
    }
}

struct Output {
    let json: Bool

    func emit<T: Encodable>(_ value: T, elapsed: Duration? = nil, text: () -> String) {
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            let data = (try? encoder.encode(value)) ?? Data("{}".utf8)
            print(String(decoding: data, as: UTF8.self))
            return
        }
        print(text())
        if let elapsed {
            print("\n⏱ \(elapsed.milliseconds) ms")
        }
    }

    func write(_ text: String) {
        FileHandle.standardOutput.write(Data(text.utf8))
    }
}

func timed<T>(_ body: () async throws -> T) async rethrows -> (T, Duration) {
    let clock = ContinuousClock()
    let start = clock.now
    let value = try await body()
    return (value, clock.now - start)
}

extension Duration {
    var milliseconds: Int {
        Int(components.seconds * 1_000 + components.attoseconds / 1_000_000_000_000_000)
    }
}
