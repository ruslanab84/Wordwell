#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// On-device implementation of reverse lookup, stories, placement and mistake lessons.
/// Use through `ReverseDictionary`, `StoryPipeline`, `PlacementPipeline` and `MistakeCoach`,
/// which add retrieval, validation, regeneration and graceful degradation.
@available(iOS 26.0, macOS 26.0, *)
public final class FoundationModelsStudyTools: AIProvider {
    public let identifier = "apple.on-device.study"
    public var promptVersion: String { StudyPrompts.version }

    public init() {}

    public func availability(languageCode: String?) async -> AIAvailability {
        FMAvailability.current(languageCode: languageCode)
    }

    public func prewarm(for task: AITask) async {}

    /// One fresh session per request: no shared transcript, no context growth.
    func generate<T: Generable>(instructions: String, options: GenerationOptions, prompt: String,
                                as type: T.Type) async throws -> T {
        do {
            try FMAvailability.require(languageCode: nil)
            let session = LanguageModelSession(instructions: instructions)
            return try await session.respond(to: prompt, generating: T.self, options: options).content
        } catch {
            throw FMErrorMapper.map(error)
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension FoundationModelsStudyTools: WordFinderService {
    public func proposeWords(for description: String, shortlist: [AIWordContext], learner: LearnerProfile) async throws -> [String] {
        try await generate(
            instructions: StudyPrompts.instructions(for: .wordFinder),
            options: StudyPrompts.options(for: .wordFinder),
            prompt: StudyPrompts.wordFinder(description: description, shortlist: shortlist, learner: learner),
            as: GWordGuesses.self
        ).words
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension FoundationModelsStudyTools: StoryService {
    public func story(using words: [AIWordContext], topicHint: String?, learner: LearnerProfile) async throws -> WordStory {
        let generated = try await generate(
            instructions: StudyPrompts.instructions(for: .story),
            options: StudyPrompts.options(for: .story),
            prompt: StudyPrompts.story(words: words, topicHint: topicHint, learner: learner),
            as: GStory.self
        )
        return WordStory(title: generated.title, paragraphs: generated.paragraphs)
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension FoundationModelsStudyTools: PlacementService {
    public func assess(answers: [PlacementAnswer]) async throws -> ExamAssessment {
        try await generate(
            instructions: ExamPrompts.instructions(for: .assessment),
            options: ExamPrompts.options(for: .assessment),
            prompt: StudyPrompts.placement(answers: answers),
            as: GExamAssessment.self
        ).domain
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension FoundationModelsStudyTools: MistakeLessonService {
    public func lesson(for pattern: MistakePattern, examples: [MistakeRecord], learner: LearnerProfile) async throws -> MiniLessonContent {
        let generated = try await generate(
            instructions: StudyPrompts.instructions(for: .mistakeLesson),
            options: StudyPrompts.options(for: .mistakeLesson),
            prompt: StudyPrompts.mistakeLesson(pattern: pattern, examples: examples, learner: learner),
            as: GMiniLesson.self
        )
        return MiniLessonContent(
            title: generated.title,
            rule: generated.rule,
            tip: generated.tip,
            exercises: generated.exercises.map { MistakeExercise(incorrect: $0.incorrect, correct: $0.correct) }
        )
    }
}
#endif
