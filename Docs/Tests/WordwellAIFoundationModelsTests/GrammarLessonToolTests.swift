#if canImport(FoundationModels)
import Testing
@testable import WordwellAIFoundationModels

@available(macOS 26.0, *)
@Test func grammarToolOnlyReturnsTheOpenLesson() async throws {
    let lesson = GrammarLessonContext(
        id: "present-simple", title: "Present Simple", level: "A1–A2",
        use: "Use it for habits.", form: "subject + base verb",
        examples: ["I walk every day."], commonMistake: "Use does with he/she/it."
    )
    let use = GrammarToolUse()
    let tool = GrammarLessonTool(lesson: lesson, use: use)

    #expect(try await tool.call(arguments: .init(lessonID: "past-simple")) == "LESSON_NOT_FOUND")
    #expect(await !use.didFetchLesson)

    let content = try await tool.call(arguments: .init(lessonID: "present-simple"))
    #expect(content.contains("Use it for habits."))
    #expect(content.contains("I walk every day."))
    #expect(await use.didFetchLesson)
}
#endif
