import XCTest
@testable import WordwellAICore

final class SemanticSearchTests: XCTestCase {
    private let learner = LearnerProfile(level: .b1)

    func test_dropsUnresolvableDedupesAndCaps() async throws {
        let provider = StubCandidates(batches: [["Exhausted", "exhausted", "blorptastic", " ", "tired"]])
        let sut = ResilientSemanticSearch(primary: provider, dictionary: StubLookup(known: ["exhausted", "tired"]))
        let result = try await sut.find(meaning: "extremely tired", learner: learner)
        XCTAssertEqual(result.map(\.lemma), ["exhausted", "tired"])
    }

    func test_regeneratesOnceWhenNothingResolves() async throws {
        let provider = StubCandidates(batches: [["fake"], ["tired"]])
        let sut = ResilientSemanticSearch(primary: provider, dictionary: StubLookup(known: ["tired"]))
        let result = try await sut.find(meaning: "x", learner: learner)
        XCTAssertEqual(result.map(\.lemma), ["tired"])
        XCTAssertEqual(provider.calls, 2)
    }

    func test_emptyWhenNeverResolves() async throws {
        let provider = StubCandidates(batches: [["fake"], ["fake2"]])
        let sut = ResilientSemanticSearch(primary: provider, dictionary: StubLookup(known: []))
        let result = try await sut.find(meaning: "x", learner: learner)
        XCTAssertTrue(result.isEmpty)
    }

    func test_badQueryRejectedBeforeModel() async {
        let provider = StubCandidates(batches: [["tired"]])
        let sut = ResilientSemanticSearch(primary: provider, dictionary: StubLookup(known: ["tired"]))
        for query in [" ", String(repeating: "a", count: 201)] {
            do {
                _ = try await sut.find(meaning: query, learner: learner)
                XCTFail("expected throw")
            } catch {}
        }
        XCTAssertEqual(provider.calls, 0)
    }

    func test_unavailableNeverFabricates() async {
        do {
            _ = try await UnavailableSemanticSearch(reason: .osTooOld).find(meaning: "x", learner: learner)
            XCTFail("expected throw")
        } catch {
            XCTAssertEqual(error as? AIError, .unavailable(.osTooOld))
        }
    }
}

private final class StubCandidates: SemanticCandidateProvider, @unchecked Sendable {
    let identifier = "stub"
    let promptVersion = "test"
    private var batches: [[String]]
    private(set) var calls = 0

    init(batches: [[String]]) { self.batches = batches }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}

    func candidates(for query: String, learner: LearnerProfile) async throws -> [String] {
        calls += 1
        return batches.isEmpty ? [] : batches.removeFirst()
    }
}

private struct StubLookup: AIDictionaryLookup {
    let known: Set<String>

    func wordContext(for lemma: String) async throws -> AIWordContext? {
        known.contains(lemma.lowercased())
            ? AIWordContext(lemma: lemma.lowercased(), partOfSpeech: "adjective", cefrLevel: nil, senses: [])
            : nil
    }

    func distractors(for lemma: String, level: CEFRLevel?, limit: Int) async throws -> [String] { [] }
}
