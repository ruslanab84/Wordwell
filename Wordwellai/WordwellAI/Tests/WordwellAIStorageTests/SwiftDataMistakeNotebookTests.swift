#if canImport(SwiftData)
import XCTest
import WordwellAICore
@testable import WordwellAIStorage

@available(iOS 17.0, macOS 14.0, *)
final class SwiftDataMistakeNotebookTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func makeNotebook() throws -> SwiftDataMistakeNotebook {
        SwiftDataMistakeNotebook(modelContainer: try SwiftDataMistakeNotebook.makeContainer(inMemory: true))
    }

    private func record(_ wrong: String, _ right: String, daysAgo: Double, hint: SentenceIssue.Kind? = nil,
                        source: MistakeRecord.Source = .manual) -> MistakeRecord {
        MistakeRecord(wrong: wrong, right: right, hint: hint, explanation: "because",
                      date: now.addingTimeInterval(-daysAgo * 86_400), source: source)
    }

    func test_roundTripKeepsEveryFieldAndSortsNewestFirst() async throws {
        let notebook = try makeNotebook()
        let older = record("She go home", "She goes home", daysAgo: 5)
        let newer = record("Can you borrow me a pen?", "Can you lend me a pen?", daysAgo: 1, hint: .wordChoice, source: .improveSentence)
        try await notebook.add([older, newer])

        let loaded = try await notebook.records(since: nil)

        XCTAssertEqual(loaded.map(\.id), [newer.id, older.id])
        XCTAssertEqual(loaded.first, newer)
        XCTAssertEqual(loaded.first?.hint, .wordChoice)
        XCTAssertEqual(loaded.first?.source, .improveSentence)
        XCTAssertEqual(loaded.last?.pattern, .agreement)
    }

    func test_sinceFilterAndPrune() async throws {
        let notebook = try makeNotebook()
        try await notebook.add([record("old", "older", daysAgo: 60), record("new", "newer", daysAgo: 2)])

        let recent = try await notebook.records(since: now.addingTimeInterval(-28 * 86_400))
        XCTAssertEqual(recent.count, 1)

        try await notebook.prune(olderThan: now.addingTimeInterval(-30 * 86_400))
        let remaining = try await notebook.count()
        XCTAssertEqual(remaining, 1)
    }

    func test_addingSameIDUpdatesInsteadOfDuplicating() async throws {
        let notebook = try makeNotebook()
        let original = record("I have a apple", "I have an apple", daysAgo: 1)
        try await notebook.add([original])
        try await notebook.add([MistakeRecord(id: original.id, wrong: original.wrong, right: original.right,
                                              explanation: "updated", date: original.date)])

        let count = try await notebook.count()
        XCTAssertEqual(count, 1)
        let explanation = try await notebook.records(since: nil).first?.explanation
        XCTAssertEqual(explanation, "updated")
    }

    func test_removeAll() async throws {
        let notebook = try makeNotebook()
        try await notebook.add([record("a", "b", daysAgo: 1)])
        try await notebook.removeAll()
        let count = try await notebook.count()
        XCTAssertEqual(count, 0)
    }

    func test_coachReportsFromNotebookWindowOnly() async throws {
        let notebook = try makeNotebook()
        let articles = [("I have a apple", "I have an apple"), ("She is teacher", "She is a teacher"),
                        ("He wants to buy car", "He wants to buy a car")]
        try await notebook.add(articles.map { record($0.0, $0.1, daysAgo: 2) })
        try await notebook.add([record("She go home", "She goes home", daysAgo: 90)])

        let coach = MistakeCoach(service: UnavailableStudyTools(reason: .osTooOld))
        let stats = try await coach.report(from: notebook, now: now)

        XCTAssertEqual(stats.map(\.pattern), [.articles], "the 90-day-old mistake is outside the window")
        XCTAssertEqual(stats.first?.total, 3)
    }
}
#endif
