import ArgumentParser
import Foundation
import WordwellAICore
import WordwellAIStorage
#if canImport(FoundationModels)
import WordwellAIFoundationModels
#endif

/// Shared setup for `find`, `story`, `placement` and `patterns`.
struct StudyEnvironment {
    let dictionary: any SearchableDictionary
    let tools: any StudyToolsAI
    /// Word-level AI used by `patterns capture` (improve sentence).
    let learning: any LearningAI
    let policy: RestrictedTermsPolicy
    let learner: LearnerProfile
    let output: Output

    init(_ options: CommonOptions, database: String? = nil) throws {
        if let database {
            let url = URL(fileURLWithPath: (database as NSString).expandingTildeInPath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw ValidationError("\(url.path) not found. Build it with: wordwell-ai db build")
            }
            dictionary = try SQLiteDictionary(url: url)
        } else {
            dictionary = try JSONDictionaryLookup.load(path: options.dictionary)
        }
        tools = Self.primary()
        learning = AIFactory.make(dictionary: dictionary)
        guard let url = Bundle.module.url(forResource: "restricted-terms", withExtension: "json") else {
            throw ValidationError("Bundled restricted-terms.json not found.")
        }
        policy = try RestrictedTermsPolicy.load(from: url)
        learner = options.learner
        output = Output(json: options.json)
    }

    var finder: ReverseDictionary { ReverseDictionary(service: tools, dictionary: dictionary) }
    var stories: StoryPipeline { StoryPipeline(service: tools) }
    var placement: PlacementPipeline { PlacementPipeline(service: tools, policy: policy) }

    func word(_ lemma: String) async throws -> AIWordContext {
        guard let word = try await dictionary.wordContext(for: lemma) else {
            throw ValidationError("'\(lemma)' is not in the dictionary. Pass --dictionary <file> to use another one.")
        }
        return word
    }

    static func perform(_ options: CommonOptions, database: String? = nil,
                        _ body: (StudyEnvironment) async throws -> Void) async throws {
        let environment = try StudyEnvironment(options, database: database)
        do {
            try await body(environment)
        } catch let error as AIError {
            FileHandle.standardError.write(Data("error: \(error) [\(error.localizationKey)]\n".utf8))
            throw ExitCode(2)
        }
    }

    private static func primary() -> any StudyToolsAI {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, *) {
            return FoundationModelsStudyTools()
        }
        #endif
        return UnavailableStudyTools(reason: .osTooOld)
    }
}

extension SentenceIssue.Kind: @retroactive ExpressibleByArgument {}
extension MistakePattern: @retroactive ExpressibleByArgument {}
