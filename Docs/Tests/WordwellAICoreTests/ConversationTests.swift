import XCTest
@testable import WordwellAICore

final class ConversationScenarioTests: XCTestCase {
    func test_catalogIdsAreUniqueAndTargetsPresent() {
        let ids = ConversationScenario.catalog.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
        for scenario in ConversationScenario.catalog {
            XCTAssertFalse(scenario.targetLemmas.isEmpty, scenario.id)
            XCTAssertFalse(scenario.openingLine.isEmpty, scenario.id)
            XCTAssertFalse(scenario.objective.isEmpty, scenario.id)
        }
    }
}

final class ConversationValidatorTests: XCTestCase {
    private let sut = ConversationValidator()
    private let turns = [
        ConversationTurn(speaker: .partner, text: "Where are you flying today?"),
        ConversationTurn(speaker: .learner, text: "I go to Paris yesterday, and I have two luggage."),
    ]

    func test_summary_dropsMistakesNotQuotedFromLearner() throws {
        let raw = ConversationSummary(
            mistakes: [
                .init(original: "I go to Paris yesterday", better: "I went to Paris yesterday", why: "Past tense."),
                .init(original: "she don't know", better: "she doesn't know", why: "Never said by the learner."),
            ],
            expressions: ["Could I have a window seat?", " ", "Could I have a window seat?"],
            wordsToSave: ["Luggage", "luggage", "boarding pass", "a very long phrase indeed"],
            objectiveMet: false)

        let result = try sut.validate(raw, turns: turns)

        XCTAssertEqual(result.mistakes.map(\.original), ["I go to Paris yesterday"])
        XCTAssertEqual(result.expressions, ["Could I have a window seat?"])
        XCTAssertEqual(result.wordsToSave, ["luggage", "boarding pass"])
    }

    func test_summary_dropsNoOpCorrections() throws {
        let raw = ConversationSummary(
            mistakes: [.init(original: "two luggage", better: "Two luggage!", why: "Same text.")],
            expressions: [], wordsToSave: [], objectiveMet: true)
        XCTAssertTrue(try sut.validate(raw, turns: turns).mistakes.isEmpty)
    }

    func test_summary_requiresLearnerTurns() {
        let raw = ConversationSummary(mistakes: [], expressions: [], wordsToSave: [], objectiveMet: false)
        XCTAssertThrowsError(try sut.validate(raw, turns: [turns[0]]))
    }

    func test_reply_rejectsEmptyAndTooLong() {
        XCTAssertThrowsError(try sut.validate(ConversationReply(text: "  ", objectiveMet: false)))
        XCTAssertThrowsError(try sut.validate(ConversationReply(text: String(repeating: "a", count: 401), objectiveMet: false)))
    }
}

final class ResilientConversationTests: XCTestCase {
    private let scenario = ConversationScenario.catalog[0]
    private let learner = LearnerProfile(level: .a2)
    private let turns = [
        ConversationTurn(speaker: .partner, text: "Hello!"),
        ConversationTurn(speaker: .learner, text: "Hi, I need check in."),
    ]

    func test_regeneratesInvalidReplyOnce() async throws {
        let stub = StubConversation(replies: [.success(ConversationReply(text: "", objectiveMet: false)),
                                              .success(ConversationReply(text: "Sure, passport please.", objectiveMet: false))])
        let sut = ResilientConversation(primary: stub)

        let reply = try await sut.reply(scenario: scenario, targetWords: [], turns: turns, learner: learner)

        XCTAssertEqual(reply.text, "Sure, passport please.")
        XCTAssertEqual(stub.replyCalls, 2)
    }

    func test_unavailableErrorPropagatesWithoutRetry() async {
        let stub = StubConversation(replies: [.failure(AIError.unavailable(.deviceNotEligible))])
        let sut = ResilientConversation(primary: stub)

        do {
            _ = try await sut.reply(scenario: scenario, targetWords: [], turns: turns, learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .unavailable(.deviceNotEligible))
        }
        XCTAssertEqual(stub.replyCalls, 1)
    }

    func test_rejectsTooLongLearnerTurnBeforeCallingModel() async {
        let long = turns + [ConversationTurn(speaker: .learner, text: String(repeating: "a", count: 501))]
        let stub = StubConversation(replies: [])
        let sut = ResilientConversation(primary: stub)

        do {
            _ = try await sut.reply(scenario: scenario, targetWords: [], turns: long, learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .inputTooLong(limit: 500))
        }
        XCTAssertEqual(stub.replyCalls, 0)
    }

    func test_unavailableServiceNeverFabricates() async {
        let sut = UnavailableConversationService(reason: .osTooOld)
        let availability = await sut.availability(languageCode: nil)
        XCTAssertEqual(availability, .unavailable(.osTooOld))
        do {
            _ = try await sut.summary(scenario: scenario, targetWords: [], turns: turns, learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .unavailable(.osTooOld))
        }
    }
}

private final class StubConversation: ConversationService, @unchecked Sendable {
    let identifier = "stub"
    let promptVersion = "test"
    private var replies: [Result<ConversationReply, AIError>]
    private(set) var replyCalls = 0

    init(replies: [Result<ConversationReply, AIError>]) { self.replies = replies }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}

    func reply(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationReply {
        replyCalls += 1
        return try replies.removeFirst().get()
    }

    func summary(scenario: ConversationScenario, targetWords: [String], turns: [ConversationTurn], learner: LearnerProfile) async throws -> ConversationSummary {
        ConversationSummary(mistakes: [], expressions: [], wordsToSave: [], objectiveMet: false)
    }
}
