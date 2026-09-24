import Foundation
import WordwellAICore

enum ExamRenderer {
    static let disclaimer = "Unofficial practice estimate (CEFR). It does not predict the result of any exam."

    static func speaking(_ task: ExamSpeakingTask) -> String {
        var lines = ["SPEAKING · \(title(task.part))", task.topic]
        lines += task.prompts.map { "  – \($0)" }
        if task.part.preparationSeconds > 0 {
            lines.append("Preparation: \(task.part.preparationSeconds) s · Speak: up to \(task.part.speakingSeconds) s")
        } else {
            lines.append("Speak: about \(task.part.speakingSeconds) s per question")
        }
        return lines.joined(separator: "\n")
    }

    static func writing(_ task: ExamWritingTask) -> String {
        var lines = ["WRITING · \(task.kind == .dataDescription ? "Data description" : "Opinion essay")", task.prompt]
        if let data = task.data { lines.append(table(data)) }
        lines.append("At least \(task.minimumWords) words · about \(task.suggestedMinutes) minutes")
        return lines.joined(separator: "\n\n")
    }

    static func reading(_ set: ExamReadingSet, showAnswers: Bool) -> String {
        var lines = ["READING · \(set.title)", set.passage, "Do the statements agree with the passage? (T) True · (F) False · (N) Not stated"]
        for question in set.questions {
            var line = "\(question.id). \(question.statement)"
            if showAnswers {
                line += "  → \(label(question.answer))"
                if let evidence = question.evidence { line += "  «\(evidence)»" }
            }
            lines.append(line)
        }
        return lines.joined(separator: "\n\n")
    }

    static func assessment(_ value: ExamAssessment) -> String {
        var lines = ["Estimated level: \(value.overallLevel.rawValue)  ·  \(value.wordCount) words\(value.isUnderLength ? " (below minimum)" : "")"]
        lines += value.criteria.map { "  \(criterionTitle($0.criterion).padding(toLength: 16, withPad: " ", startingAt: 0)) \($0.level.rawValue)  \($0.comment)" }
        lines += value.strengths.map { "  + \($0)" }
        lines += value.improvements.map { "  • \"\($0.fragment)\" → \"\($0.fix)\": \($0.explanation)" }
        lines.append("\n\(disclaimer)")
        return lines.joined(separator: "\n")
    }

    static func label(_ answer: ReadingAnswer) -> String {
        switch answer {
        case .agrees: "True"
        case .contradicts: "False"
        case .notStated: "Not stated"
        }
    }

    // MARK: - Helpers

    private static func title(_ part: SpeakingPart) -> String {
        switch part {
        case .interview: "Interview"
        case .longTurn: "Long turn"
        case .discussion: "Discussion"
        }
    }

    private static func criterionTitle(_ criterion: AssessmentCriterion) -> String {
        switch criterion {
        case .taskFulfilment: "Task"
        case .organisation: "Organisation"
        case .vocabulary: "Vocabulary"
        case .grammar: "Grammar"
        }
    }

    private static func table(_ data: DataTable) -> String {
        let width = max(12, data.rows.map(\.label.count).max() ?? 0) + 2
        let header = "".padding(toLength: width, withPad: " ", startingAt: 0)
            + data.columns.map { $0.padding(toLength: 10, withPad: " ", startingAt: 0) }.joined()
        let rows = data.rows.map { row in
            row.label.padding(toLength: width, withPad: " ", startingAt: 0)
                + row.values.map { $0.formatted(.number.precision(.fractionLength(0...1))).padding(toLength: 10, withPad: " ", startingAt: 0) }.joined()
        }
        return (["\(data.title) (\(data.unit))", header] + rows).joined(separator: "\n")
    }
}
