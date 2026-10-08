import XCTest
@testable import WordwellAICore

final class MistakeExplainerTests: XCTestCase {
    private let learner = LearnerProfile(level: .a2)
    private let mistake = MistakeContext(
        kind: .grammar, topic: "Present simple", prompt: "She ___ tea every day.",
        chosen: "drink", correct: "drinks", fact: "With he/she/it add -s in the present simple.")
    private let good = MistakeExplanation(whyWrong: " 'She' needs -s. ", whyRight: "'Drinks' has the -s.")

    func test_validator_rejectsEmptyAndTooLong() {
        let sut = MistakeValidator()
        XCTAssertThrowsError(try sut.validate(.init(whyWrong: " ", whyRight: "ok")))
        XCTAssertThrowsError(try sut.validate(.init(whyWrong: "ok", whyRight: String(repeating: "a", count: 301))))
        XCTAssertEqual(try sut.validate(good).whyWrong, "'She' needs -s.")
    }

    func test_regeneratesOnceOnInvalidOutput() async throws {
        let stub = StubMistake(results: [.success(.init(whyWrong: "", whyRight: "")), .success(good)])
        let result = try await ResilientMistakeExplainer(primary: stub).explain(mistake, learner: learner)
        XCTAssertEqual(result.whyRight, "'Drinks' has the -s.")
        XCTAssertEqual(stub.calls, 2)
    }

    func test_unavailableIsNotRetried() async {
        let stub = StubMistake(results: [.failure(.unavailable(.osTooOld)), .success(good)])
        do {
            _ = try await ResilientMistakeExplainer(primary: stub).explain(mistake, learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .unavailable(.osTooOld))
        }
        XCTAssertEqual(stub.calls, 1)
    }

    func test_badInputRejectedBeforeModelCall() async {
        let stub = StubMistake(results: [.success(good)])
        let sut = ResilientMistakeExplainer(primary: stub)
        let same = MistakeContext(kind: .grammar, topic: "t", prompt: "p", chosen: "Drinks", correct: "drinks.", fact: "f")
        let long = MistakeContext(kind: .grammar, topic: "t", prompt: "p", chosen: "a", correct: "b", fact: String(repeating: "x", count: 601))
        for input in [same, long] {
            do {
                _ = try await sut.explain(input, learner: learner)
                XCTFail("expected throw")
            } catch {}
        }
        XCTAssertEqual(stub.calls, 0)
    }

    func test_unavailableServiceNeverFabricates() async {
        let sut = UnavailableMistakeExplainer(reason: .osTooOld)
        let availability = await sut.availability(languageCode: nil)
        XCTAssertEqual(availability, .unavailable(.osTooOld))
        do {
            _ = try await sut.explain(mistake, learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .unavailable(.osTooOld))
        }
    }
}

private final class StubMistake: MistakeExplainerService, @unchecked Sendable {
    let identifier = "stub"
    let promptVersion = "test"
    private var results: [Result<MistakeExplanation, AIError>]
    private(set) var calls = 0

    init(results: [Result<MistakeExplanation, AIError>]) { self.results = results }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}

    func explain(_ mistake: MistakeContext, learner: LearnerProfile) async throws -> MistakeExplanation {
        calls += 1
        return try results.removeFirst().get()
    }
}
