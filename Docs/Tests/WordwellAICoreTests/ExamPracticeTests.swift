import XCTest
@testable import WordwellAICore

// Uses a fictional brand ("Acme Exam") so the test suite contains no real exam names.
final class RestrictedTermsPolicyTests: XCTestCase {
    private let policy = RestrictedTermsPolicy(plainTerms: ["Acme Exam", "zorb score"])

    func test_fingerprintIsStableAcrossPlatforms() {
        XCTAssertEqual(RestrictedTermsPolicy.fingerprint(of: "  ACME   exam! "), 0x409a_dea3_c461_0f4a)
    }

    func test_detectsMultiWordTermsCaseInsensitively() {
        XCTAssertEqual(policy.violations(in: "Prepare for the ACME exam today.").count, 1)
        XCTAssertEqual(policy.violations(in: ["Your Zorb-Score is 7.", "Nice work."]).count, 1)
    }

    func test_ignoresPartialWords() {
        XCTAssertTrue(policy.violations(in: "The acmeexam format and examples.").isEmpty)
    }
}

final class ExamValidatorTests: XCTestCase {
    private let sut = ExamValidator(policy: RestrictedTermsPolicy(plainTerms: ["Acme Exam"]))

    func test_speakingTask_rejectsRestrictedTerm() {
        let task = ExamSpeakingTask(part: .interview, topic: "Hobbies",
                                    prompts: ["Is this like the Acme Exam?", "What do you do?", "Why?"])
        XCTAssertThrowsError(try sut.validate(task))
    }

    func test_writingTask_rejectsInconsistentTable() {
        let table = DataTable(title: "Visitors", unit: "thousands", columns: ["2020", "2021"],
                              rows: [.init(label: "Park", values: [1, 2]), .init(label: "Museum", values: [3])])
        XCTAssertThrowsError(try sut.validate(ExamWritingTask(kind: .dataDescription, prompt: "Summarise.", data: table)))
    }

    func test_reading_dropsQuestionsWithUngroundedEvidence() throws {
        let passage = Array(repeating: "Bees visit many flowers every day in warm weather.", count: 20).joined(separator: " ")
        let set = ExamReadingSet(title: "Bees", passage: passage, questions: [
            ReadingQuestion(id: 1, statement: "Bees visit flowers.", answer: .agrees, evidence: "Bees visit many flowers"),
            ReadingQuestion(id: 2, statement: "Bees sleep all winter.", answer: .contradicts, evidence: "invented quote"),
            ReadingQuestion(id: 3, statement: "Bees like music.", answer: .notStated, evidence: "anything"),
            ReadingQuestion(id: 4, statement: "Weather matters.", answer: .agrees, evidence: "in warm weather"),
        ])

        let result = try sut.validate(set, questionCount: 5)

        XCTAssertEqual(result.questions.map(\.statement), ["Bees visit flowers.", "Bees like music.", "Weather matters."])
        XCTAssertEqual(result.questions.map(\.id), [1, 2, 3])
        XCTAssertNil(result.questions[1].evidence)
    }

    func test_assessment_requiresEveryCriterionOnce() {
        let partial = assessment([.taskFulfilment: .b2, .grammar: .b1])
        XCTAssertThrowsError(try sut.validate(partial, response: "text", minimumWords: nil))
    }

    func test_assessment_underLengthLowersTaskAndOverallIsConservative() throws {
        let raw = assessment([.taskFulfilment: .b2, .organisation: .b2, .vocabulary: .c1, .grammar: .b1])

        let result = try sut.validate(raw, response: "Too short answer.", minimumWords: 250)

        XCTAssertTrue(result.isUnderLength)
        XCTAssertEqual(result.wordCount, 3)
        XCTAssertEqual(result.criteria.first { $0.criterion == .taskFulfilment }?.level, .b1)
        XCTAssertEqual(result.overallLevel, .b1) // levels B1, B1, B2, C1 → lower median B1
    }

    private func assessment(_ levels: [AssessmentCriterion: CEFRLevel]) -> ExamAssessment {
        ExamAssessment(criteria: levels.map { CriterionResult(criterion: $0.key, level: $0.value, comment: "ok") },
                       overallLevel: .c2, strengths: [], improvements: [], wordCount: 0, isUnderLength: false)
    }
}

final class ResilientExamPracticeTests: XCTestCase {
    func test_regeneratesWhenFirstOutputBreaksPolicy() async throws {
        let stub = SequenceExamStub(topics: ["Acme Exam practice", "Weekend plans"])
        let sut = ResilientExamPractice(primary: stub, policy: RestrictedTermsPolicy(plainTerms: ["Acme Exam"]))

        let task = try await sut.speakingTask(part: .interview, topicHint: nil, learner: Fixtures.learner)

        XCTAssertEqual(task.topic, "Weekend plans")
        let calls = await stub.counter.count
        XCTAssertEqual(calls, 2)
    }
}

final class SkillsCheckTests: XCTestCase {
    func test_originalPackPassesPolicyAndScoresOmissions() throws {
        let pack = SkillsCheckPack.standard
        try pack.validate(policy: RestrictedTermsPolicy.bundled())
        let reading = pack.reading.questions.map(\.answer)
        XCTAssertEqual(pack.score(reading.map(Optional.some), for: pack.reading), 5)
        XCTAssertEqual(pack.score([nil, .agrees, nil, nil, nil], for: pack.reading), 0)
    }

    func test_draftRestoresAndRejectsInvalidState() throws {
        let suite = "wordwell.skillsCheck.tests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = SkillsCheckDraftStore(defaults: defaults)
        var draft = SkillsCheckDraft()
        draft.readingAnswers[0] = .agrees
        draft.writingText = "My unfinished answer"
        draft.section = 2
        store.save(draft)
        XCTAssertEqual(store.load(), draft)
        draft.section = 4
        store.save(draft)
        XCTAssertNil(store.load())
        // Invalid draft is dropped, not left in defaults.
        XCTAssertNil(defaults.data(forKey: "wordwell.skillsCheck.draft"))
        store.clear()
        XCTAssertNil(store.load())
    }

    func test_draftPlayCounterDefaultsForOldDraftsAndIsBounded() throws {
        var draft = SkillsCheckDraft()
        draft.listeningPlays = 2
        let decoded = try JSONDecoder().decode(SkillsCheckDraft.self, from: JSONEncoder().encode(draft))
        XCTAssertEqual(decoded.listeningPlays, 2)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(draft)) as? [String: Any])
        json.removeValue(forKey: "listeningPlays")
        let old = try JSONDecoder().decode(SkillsCheckDraft.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(old.listeningPlays, 0)
        draft.listeningPlays = SkillsCheckDraft.maxListeningPlays + 1
        XCTAssertFalse(draft.isValid(for: .standard))
    }

    func test_suggestedMinutesFollowWritingTask() {
        let pack = SkillsCheckPack.standard
        XCTAssertEqual(pack.suggestedMinutes.count, 4)
        XCTAssertEqual(pack.suggestedMinutes[2], pack.writing.suggestedMinutes)
    }
}

private struct SequenceExamStub: ExamPracticeService {
    let identifier = "stub"
    let promptVersion = "test"
    let topics: [String]
    let counter = CallCounter()

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}

    func speakingTask(part: SpeakingPart, topicHint: String?, learner: LearnerProfile) async throws -> ExamSpeakingTask {
        let index = await counter.count
        await counter.increment()
        return ExamSpeakingTask(part: part, topic: topics[min(index, topics.count - 1)],
                                prompts: ["What do you do?", "Where do you go?", "Who with?"])
    }

    func writingTask(kind: WritingTaskKind, topicHint: String?, learner: LearnerProfile) async throws -> ExamWritingTask { throw AIError.cancelled }
    func readingSet(questionCount: Int, topicHint: String?, learner: LearnerProfile) async throws -> ExamReadingSet { throw AIError.cancelled }
    func assess(speakingTranscript: String, task: ExamSpeakingTask, learner: LearnerProfile) async throws -> ExamAssessment { throw AIError.cancelled }
    func assess(writing: String, task: ExamWritingTask, learner: LearnerProfile) async throws -> ExamAssessment { throw AIError.cancelled }
}
