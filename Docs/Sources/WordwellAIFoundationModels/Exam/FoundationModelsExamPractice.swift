#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

/// On-device implementation of original exam-style practice.
/// Always wrap in `ResilientExamPractice` (validation + restricted-terms policy + regeneration).
@available(iOS 26.0, macOS 26.0, *)
public final class FoundationModelsExamPractice: ExamPracticeService {
    public let identifier = "apple.on-device.exam"
    public var promptVersion: String { ExamPrompts.version }

    public init() {}

    public func availability(languageCode: String?) async -> AIAvailability {
        FMAvailability.current(languageCode: languageCode)
    }

    /// Exam sessions carry per-request instructions; nothing to prewarm by word task.
    public func prewarm(for task: AITask) async {}

    public func speakingTask(part: SpeakingPart, topicHint: String?, learner: LearnerProfile) async throws -> ExamSpeakingTask {
        let generated = try await generate(.speakingTask, as: GExamSpeakingTask.self,
                                           prompt: ExamPrompts.speakingTask(part: part, topicHint: topicHint, learner: learner))
        return ExamSpeakingTask(part: part, topic: generated.topic, prompts: generated.prompts)
    }

    public func writingTask(kind: WritingTaskKind, topicHint: String?, learner: LearnerProfile) async throws -> ExamWritingTask {
        let generated = try await generate(.writingTask, as: GExamWritingTask.self,
                                           prompt: ExamPrompts.writingTask(kind: kind, topicHint: topicHint, learner: learner))
        return ExamWritingTask(kind: kind, prompt: generated.prompt,
                               data: kind == .dataDescription ? generated.data?.domain : nil)
    }

    public func readingSet(questionCount: Int, topicHint: String?, learner: LearnerProfile) async throws -> ExamReadingSet {
        let generated = try await generate(.readingSet, as: GExamReadingSet.self,
                                           prompt: ExamPrompts.readingSet(questionCount: questionCount, topicHint: topicHint, learner: learner))
        let questions = generated.questions.enumerated().map { index, question in
            ReadingQuestion(id: index + 1, statement: question.statement, answer: question.answer.domain,
                            evidence: question.evidence.isBlank ? nil : question.evidence)
        }
        return ExamReadingSet(title: generated.title, passage: generated.passage, questions: questions)
    }

    public func assess(speakingTranscript: String, task: ExamSpeakingTask, learner: LearnerProfile) async throws -> ExamAssessment {
        try await generate(.assessment, as: GExamAssessment.self,
                           prompt: ExamPrompts.speakingAssessment(transcript: speakingTranscript, task: task, learner: learner))
            .domain
    }

    public func assess(writing: String, task: ExamWritingTask, learner: LearnerProfile) async throws -> ExamAssessment {
        try await generate(.assessment, as: GExamAssessment.self,
                           prompt: ExamPrompts.writingAssessment(answer: writing, task: task, learner: learner))
            .domain
    }

    // MARK: - Engine

    private func generate<T: Generable>(_ kind: ExamPrompts.Kind, as type: T.Type, prompt: String) async throws -> T {
        do {
            try FMAvailability.require(languageCode: nil)
            let session = LanguageModelSession(instructions: ExamPrompts.instructions(for: kind))
            return try await session.respond(to: prompt, generating: T.self, options: ExamPrompts.options(for: kind)).content
        } catch {
            throw FMErrorMapper.map(error)
        }
    }
}
#endif
