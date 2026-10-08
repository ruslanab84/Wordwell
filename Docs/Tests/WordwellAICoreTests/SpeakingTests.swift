import XCTest
@testable import WordwellAICore

final class SpeakingTests: XCTestCase {
    private let transcript = "Yesterday I decide to go to the park and I seen a dog."
    private let prompt = SpeakingPrompt(topic: "A day out", guidingQuestions: ["Where did you go?"], targetWords: ["decide"])

    private static func feedback(mistakes: [SentenceIssue], summary: String = "Good effort.") -> SpeakingFeedback {
        SpeakingFeedback(summary: summary, strengths: ["Clear story"], mistakes: mistakes, betterAnswer: "Yesterday I decided to go to the park.",
                         usedTargetWords: ["decide"], missedTargetWords: [])
    }

    private func sut(_ stub: StubLearningAI) -> ResilientLearningAI { ResilientLearningAI(primary: stub) }

    func test_feedbackDropsMistakesNotQuotedFromTranscript() async throws {
        let real = SentenceIssue(kind: .grammar, fragment: "I decide", fix: "I decided", explanation: "Past tense.")
        let invented = SentenceIssue(kind: .grammar, fragment: "she go", fix: "she goes", explanation: "Not said.")
        let noop = SentenceIssue(kind: .other, fragment: "the park", fix: "the park", explanation: "Same.")
        var stub = StubLearningAI(identifier: "p") { .valid }
        stub.feedbackResult = { Self.feedback(mistakes: [real, invented, noop]) }

        let result = try await sut(stub).feedback(transcript: transcript, prompt: prompt, targetWords: [Fixtures.decide], learner: Fixtures.learner)

        XCTAssertEqual(result.mistakes, [real])
    }

    func test_feedbackWithBlankSummaryIsInvalid() async {
        var stub = StubLearningAI(identifier: "p") { .valid }
        stub.feedbackResult = { Self.feedback(mistakes: [], summary: "  ") }

        do {
            _ = try await sut(stub).feedback(transcript: transcript, prompt: prompt, targetWords: [Fixtures.decide], learner: Fixtures.learner)
            XCTFail("Expected invalidResponse")
        } catch {
            guard case .invalidResponse = error as? AIError else { return XCTFail("Got \(error)") }
        }
    }

    func test_speakingPromptWithoutQuestionsIsInvalid() async {
        var stub = StubLearningAI(identifier: "p") { .valid }
        stub.promptResult = { SpeakingPrompt(topic: "Topic", guidingQuestions: [], targetWords: []) }

        do {
            _ = try await sut(stub).speakingPrompt(targetWords: [Fixtures.decide], learner: Fixtures.learner)
            XCTFail("Expected invalidResponse")
        } catch {
            guard case .invalidResponse = error as? AIError else { return XCTFail("Got \(error)") }
        }
    }

    func test_speakingPromptRoundTripsThroughJSON() throws {
        let data = try JSONEncoder().encode(prompt)
        XCTAssertEqual(try JSONDecoder().decode(SpeakingPrompt.self, from: data), prompt)
    }
}
