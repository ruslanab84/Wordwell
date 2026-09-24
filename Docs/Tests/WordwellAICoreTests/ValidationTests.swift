import XCTest
@testable import WordwellAICore

final class FormMatcherTests: XCTestCase {
    func test_matchesInflectedFormCaseInsensitively() {
        let match = FormMatcher.firstMatch(of: Fixtures.decide.allForms, in: "Finally, they Decided to go.")
        XCTAssertEqual(match?.text, "Decided")
    }

    func test_ignoresSubstrings() {
        XCTAssertFalse(FormMatcher.contains(["lend"], in: "Put it in the blender."))
    }
}

final class AIResponseValidatorTests: XCTestCase {
    private let sut = AIResponseValidator()

    func test_examples_dropSentencesWithoutHeadword() throws {
        let input = [ExampleSentence(text: "We decided to walk.", senseID: "s1"),
                     ExampleSentence(text: "We chose to walk.", senseID: "s1"),
                     ExampleSentence(text: "It decides the game.", senseID: "s9")]
        let result = try sut.validate(input, for: Fixtures.decide)
        XCTAssertEqual(result.map(\.text), ["We decided to walk.", "It decides the game."])
        XCTAssertNil(result[1].senseID, "Unknown sense IDs must be dropped")
    }

    func test_examples_throwWhenNothingValid() {
        XCTAssertThrowsError(try sut.validate([ExampleSentence(text: "No headword.", senseID: nil)], for: Fixtures.decide))
    }

    func test_explanation_unknownSenseFallsBackToFirst() throws {
        let raw = SimpleExplanation(senseID: "s42", explanation: "Choose.", analogy: " ", examples: ["I decide now."], languageCode: nil)
        let result = try sut.validate(raw, for: Fixtures.decide)
        XCTAssertEqual(result.senseID, "s1")
        XCTAssertNil(result.analogy)
    }

    func test_improvement_dropsIssuesNotQuotedFromOriginal() {
        let raw = SentenceImprovement(
            original: "Can you borrow me your pen?",
            corrected: "Can you lend me your pen?",
            issues: [SentenceIssue(kind: .wordChoice, fragment: "borrow", fix: "lend", explanation: "Direction."),
                     SentenceIssue(kind: .grammar, fragment: "invented text", fix: "x", explanation: "Hallucinated.")]
        )
        let result = sut.validate(raw)
        XCTAssertEqual(result.issues.map(\.fragment), ["borrow"])
    }

    func test_improvement_unchangedSentenceIsCorrect() {
        let raw = SentenceImprovement(original: "I decided to stay.", corrected: "I decided to stay",
                                      issues: [SentenceIssue(kind: .grammar, fragment: "stay", fix: "stay.", explanation: "")])
        XCTAssertTrue(sut.validate(raw).isAlreadyCorrect)
    }
}

final class QuizAssemblerTests: XCTestCase {
    func test_buildsGapWithLemmaAsAnswer() {
        var rng = SplitMix64(state: 42)
        let quiz = QuizAssembler().assemble(
            word: Fixtures.decide,
            sentences: ["They decided to leave.", "No headword here.", "She decides quickly."],
            distractors: ["choose", "suggest", "decide", "borrow"],
            questionCount: 5,
            using: &rng
        )

        XCTAssertEqual(quiz.questions.count, 2)
        for question in quiz.questions {
            XCTAssertTrue(question.prompt.contains(QuizAssembler.gap))
            XCTAssertFalse(question.prompt.lowercased().contains("decid"))
            XCTAssertEqual(question.options[question.correctIndex], "decide")
            XCTAssertEqual(Set(question.options).count, question.options.count)
        }
        XCTAssertEqual(quiz.questions.first?.answerForm, "decided")
    }

    func test_noDistractorsProducesEmptyQuiz() {
        let quiz = QuizAssembler().assemble(word: Fixtures.decide, sentences: ["We decided."],
                                            distractors: ["decide"], questionCount: 1)
        XCTAssertTrue(quiz.questions.isEmpty)
    }
}
