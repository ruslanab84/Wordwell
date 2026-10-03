import XCTest
@testable import WordwellAICore

final class InMemoryNotebookTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    func test_addReplacesSameIDAndFiltersBySince() async throws {
        let first = MistakeRecord(wrong: "I have a apple", right: "I have an apple", date: now.addingTimeInterval(-86_400))
        let old = MistakeRecord(wrong: "She go", right: "She goes", date: now.addingTimeInterval(-90 * 86_400))
        let notebook = InMemoryMistakeNotebook([first])
        await notebook.add([MistakeRecord(id: first.id, wrong: first.wrong, right: first.right,
                                          explanation: "updated", date: first.date), old])

        let all = await notebook.records(since: nil)
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all.first?.explanation, "updated")

        let recent = await notebook.records(since: now.addingTimeInterval(-28 * 86_400))
        XCTAssertEqual(recent.map(\.id), [first.id])
    }

    func test_coachExtensionOnlyReadsTheAnalysisWindow() async throws {
        let recent = [("I have a apple", "I have an apple"), ("She is teacher", "She is a teacher"),
                      ("He wants to buy car", "He wants to buy a car")]
            .map { MistakeRecord(wrong: $0.0, right: $0.1, date: now.addingTimeInterval(-86_400)) }
        let stale = MistakeRecord(wrong: "She go home", right: "She goes home", date: now.addingTimeInterval(-90 * 86_400))
        let notebook = InMemoryMistakeNotebook(recent + [stale])
        let coach = MistakeCoach(service: UnavailableStudyTools(reason: .osTooOld))

        let stats = try await coach.report(from: notebook, now: now)
        XCTAssertEqual(stats.map(\.pattern), [.articles])
    }

    func test_searchWordsAreLettersOnlyDeduplicatedAndUnstemmed() {
        XCTAssertEqual(QueryTerms.searchWords("Fear of heights, fear! 42 \"NEAR(a b)\" col:x"),
                       ["fear", "heights", "near", "col"])
        XCTAssertTrue(QueryTerms.searchWords("of the and").isEmpty)
    }
}
