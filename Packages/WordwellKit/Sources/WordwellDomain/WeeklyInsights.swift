import Foundation

/// Aggregates for the last seven days (including today) and the seven days before.
public struct WeeklyReport: Equatable, Sendable {
    public var minutes = 0
    public var previousMinutes = 0
    public var activeDays = 0
    public var quizAnswered = 0
    public var quizCorrect = 0
    public var previousQuizAnswered = 0
    public var previousQuizCorrect = 0
    public var wordsReviewed = 0
    public var speakingSessions = 0
    public var listeningSessions = 0

    public init() {}
}

public enum WeeklyInsights {
    static let minimumQuizAnswers = 5

    /// Up to three observations, each stated only when the report actually contains the data for it.
    public static func make(from report: WeeklyReport) -> [String] {
        guard report.activeDays > 0 else { return [] }
        var lines: [String] = []

        if report.previousMinutes > 0 {
            let delta = report.minutes - report.previousMinutes
            if abs(delta) * 5 >= report.previousMinutes {
                lines.append("You practised \(abs(delta)) min \(delta > 0 ? "more" : "less") than the week before.")
            }
        }

        lines.append("You practised on \(report.activeDays) of the last 7 days.")

        if report.quizAnswered >= minimumQuizAnswers {
            let accuracy = percent(report.quizCorrect, of: report.quizAnswered)
            if report.previousQuizAnswered >= minimumQuizAnswers {
                let change = accuracy - percent(report.previousQuizCorrect, of: report.previousQuizAnswered)
                if change != 0 {
                    lines.append("Quiz accuracy is \(accuracy)%, \(abs(change)) points \(change > 0 ? "up" : "down") on last week.")
                } else {
                    lines.append("Quiz accuracy is \(accuracy)%, the same as last week.")
                }
            } else {
                lines.append("Quiz accuracy this week: \(accuracy)%.")
            }
        }

        if report.speakingSessions == 0, report.wordsReviewed + report.quizAnswered > 0 {
            lines.append("No speaking practice this week.")
        }

        return Array(lines.prefix(3))
    }

    private static func percent(_ part: Int, of total: Int) -> Int {
        Int((Double(part) / Double(total) * 100).rounded())
    }
}
