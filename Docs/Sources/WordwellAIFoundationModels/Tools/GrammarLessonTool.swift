#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// The model receives grammar facts only by asking for the lesson currently open in the app.
@available(iOS 26.0, macOS 26.0, *)
public struct GrammarLessonContext: Sendable {
    public let id: String
    public let title: String
    public let level: String
    public let use: String
    public let form: String
    public let examples: [String]
    public let commonMistake: String

    public init(id: String, title: String, level: String, use: String, form: String,
                examples: [String], commonMistake: String) {
        self.id = id
        self.title = title
        self.level = level
        self.use = use
        self.form = form
        self.examples = examples
        self.commonMistake = commonMistake
    }

    func text(for requestedID: String) -> String? {
        guard requestedID == id else { return nil }
        return """
        Lesson: \(title) (\(level))
        When to use: \(use)
        Form: \(form)
        Examples: \(examples.joined(separator: " | "))
        Common mistake: \(commonMistake)
        """
    }
}

@available(iOS 26.0, macOS 26.0, *)
actor GrammarToolUse {
    private(set) var didFetchLesson = false

    func markFetched() { didFetchLesson = true }
}

@available(iOS 26.0, macOS 26.0, *)
struct GrammarLessonTool: Tool {
    let name = "getGrammarLesson"
    let description = "Retrieve the verified rule, form, examples, and common mistake for the open grammar lesson."

    let lesson: GrammarLessonContext
    let use: GrammarToolUse

    @Generable
    struct Arguments {
        @Guide(description: "ID of the grammar lesson currently open")
        var lessonID: String
    }

    func call(arguments: Arguments) async throws -> String {
        guard let text = lesson.text(for: arguments.lessonID) else { return "LESSON_NOT_FOUND" }
        await use.markFetched()
        return text
    }
}

@available(iOS 26.0, macOS 26.0, *)
public enum GrammarAI {
    public static func availability() -> AIAvailability {
        FMAvailability.current(languageCode: "en")
    }

    /// `languageCode` is the learner's explanation language; English (or nil) keeps the explanation in English.
    public static func explain(_ lesson: GrammarLessonContext, languageCode: String? = nil) async throws -> String {
        do {
            try FMAvailability.require(languageCode: "en")
            let language = AIPrompts.languageName(languageCode)
            let use = GrammarToolUse()
            let session = LanguageModelSession(
                tools: [GrammarLessonTool(lesson: lesson, use: use)],
                instructions: """
                You are an English grammar tutor. Before answering, call getGrammarLesson for the requested ID.
                Use only the rule and examples returned by that tool. \(language.map { "Explain in clear \($0); keep the supplied examples in English." } ?? "Explain in clear English.")
                Write two or three short sentences that clarify the rule, illustrate it with one supplied example,
                then give one practical tip. Do not copy the tool's field labels or dump its contents.
                Do not invent extra rules.
                """
            )
            let response = try await session.respond(
                to: "Explain grammar lesson ID \(lesson.id) for a learner.",
                options: GenerationOptions(samplingMode: .greedy, maximumResponseTokens: 280)
            )
            guard await use.didFetchLesson else {
                throw AIError.invalidResponse("grammar lesson tool was not called")
            }
            let answer = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !answer.isEmpty else { throw AIError.invalidResponse("empty grammar answer") }
            return answer
        } catch {
            throw FMErrorMapper.map(error)
        }
    }
}
#endif
