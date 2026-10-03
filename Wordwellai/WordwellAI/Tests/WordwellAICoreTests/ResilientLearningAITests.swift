import XCTest
@testable import WordwellAICore

final class ResilientLearningAITests: XCTestCase {
    func test_fallsBackWhenPrimaryUnavailable() async throws {
        let primary = StubLearningAI(identifier: "primary") { throw AIError.unavailable(.deviceNotEligible) }
        let fallback = StubLearningAI(identifier: "fallback") { .valid }
        let sut = ResilientLearningAI(primary: primary, fallback: fallback, policy: .whenPrimaryFails)

        let result = try await sut.explain(Fixtures.decide, learner: Fixtures.learner, languageCode: nil)

        XCTAssertEqual(result.explanation, SimpleExplanation.valid.explanation)
        let fallbackCalls = await fallback.counter.count
        XCTAssertEqual(fallbackCalls, 1)
    }

    func test_guardrailNeverFallsBack() async {
        let primary = StubLearningAI(identifier: "primary") { throw AIError.guardrailViolation }
        let fallback = StubLearningAI(identifier: "fallback") { .valid }
        let sut = ResilientLearningAI(primary: primary, fallback: fallback, policy: .whenPrimaryFails)

        do {
            _ = try await sut.explain(Fixtures.decide, learner: Fixtures.learner, languageCode: nil)
            XCTFail("Expected guardrail error")
        } catch {
            XCTAssertEqual(error as? AIError, .guardrailViolation)
        }
        let fallbackCalls = await fallback.counter.count
        XCTAssertEqual(fallbackCalls, 0)
    }

    func test_cacheHitSkipsModel() async throws {
        let primary = StubLearningAI(identifier: "primary") { .valid }
        let sut = ResilientLearningAI(primary: primary, cache: AIResponseCache(storage: InMemoryAICacheStorage()))

        _ = try await sut.explain(Fixtures.decide, learner: Fixtures.learner, languageCode: "ru")
        _ = try await sut.explain(Fixtures.decide, learner: Fixtures.learner, languageCode: "ru")

        let calls = await primary.counter.count
        XCTAssertEqual(calls, 1)
    }

    func test_invalidOutputIsNotCached() async throws {
        let primary = StubLearningAI(identifier: "primary") {
            SimpleExplanation(senseID: "s1", explanation: "  ", analogy: nil, examples: [], languageCode: nil)
        }
        let sut = ResilientLearningAI(primary: primary, cache: AIResponseCache(storage: InMemoryAICacheStorage()))

        for _ in 0..<2 {
            _ = try? await sut.explain(Fixtures.decide, learner: Fixtures.learner, languageCode: nil)
        }
        let calls = await primary.counter.count
        XCTAssertEqual(calls, 2)
    }
}
