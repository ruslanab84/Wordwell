import Foundation

extension MistakeCoach {
    /// Loads only the analysis window from the notebook, then ranks patterns. No model involved.
    public func report(from notebook: any MistakeNotebook, now: Date = Date()) async throws -> [PatternStat] {
        report(try await notebook.records(since: windowStart(now: now)), now: now)
    }

    public func weeklyLesson(from notebook: any MistakeNotebook, now: Date = Date(), learner: LearnerProfile,
                             pattern: MistakePattern? = nil) async throws -> WeeklyMistakeLesson? {
        try await weeklyLesson(from: try await notebook.records(since: windowStart(now: now)),
                               now: now, learner: learner, pattern: pattern)
    }

    private func windowStart(now: Date) -> Date {
        now.addingTimeInterval(-Double(analyzer.windowDays) * 86_400)
    }
}
