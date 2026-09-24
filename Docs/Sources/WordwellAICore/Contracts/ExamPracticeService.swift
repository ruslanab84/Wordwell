import Foundation

/// Original exam-style practice: speaking, writing and reading.
/// Implementations must never name real exams/brands or reproduce published material;
/// `ResilientExamPractice` enforces this with `RestrictedTermsPolicy`.
public protocol ExamPracticeService: AIProvider {
    func speakingTask(part: SpeakingPart, topicHint: String?, learner: LearnerProfile) async throws -> ExamSpeakingTask
    func writingTask(kind: WritingTaskKind, topicHint: String?, learner: LearnerProfile) async throws -> ExamWritingTask
    func readingSet(questionCount: Int, topicHint: String?, learner: LearnerProfile) async throws -> ExamReadingSet
    func assess(speakingTranscript: String, task: ExamSpeakingTask, learner: LearnerProfile) async throws -> ExamAssessment
    func assess(writing: String, task: ExamWritingTask, learner: LearnerProfile) async throws -> ExamAssessment
}
