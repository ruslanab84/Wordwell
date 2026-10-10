#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExamSpeakingTask {
    @Guide(description: "Short topic title")
    var topic: String
    @Guide(description: "Questions or prompts", .count(4))
    var prompts: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GDataRow {
    var label: String
    @Guide(description: "One non-negative number per column", .count(3))
    var values: [Double]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GDataTable {
    @Guide(description: "Table title describing fictional data")
    var title: String
    @Guide(description: "Unit of the values, e.g. percent, thousands of visitors")
    var unit: String
    @Guide(description: "Column headers such as years", .count(3))
    var columns: [String]
    @Guide(.count(4))
    var rows: [GDataRow]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExamWritingTask {
    @Guide(description: "Task statement and instruction for the learner")
    var prompt: String
    @Guide(description: "Fictional data table; required for data tasks")
    var data: GDataTable?
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
enum GReadingAnswer {
    /// The passage says the statement is true.
    case agrees
    /// The passage says the opposite.
    case contradicts
    /// The passage does not contain this information.
    case notStated
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GReadingQuestion {
    @Guide(description: "Statement about the passage")
    var statement: String
    var answer: GReadingAnswer
    @Guide(description: "Exact short quote copied from the passage; empty for notStated")
    var evidence: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExamReadingSet {
    @Guide(description: "Passage title")
    var title: String
    @Guide(description: "Original informative passage, 200 to 300 words")
    var passage: String
    @Guide(.maximumCount(6))
    var questions: [GReadingQuestion]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
enum GCriterion {
    case taskFulfilment, organisation, vocabulary, grammar
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
enum GLevel {
    case a1, a2, b1, b2, c1, c2
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GCriterionResult {
    var criterion: GCriterion
    var level: GLevel
    @Guide(description: "One-sentence comment, in the EXPLANATION LANGUAGE if given")
    var comment: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExamAssessment {
    @Guide(description: "Exactly one result per criterion", .count(4))
    var criteria: [GCriterionResult]
    @Guide(.maximumCount(2))
    var strengths: [String]
    @Guide(.maximumCount(4))
    var improvements: [GIssue]
}

// MARK: - Mapping

@available(iOS 26.0, macOS 26.0, *)
extension GDataTable {
    var domain: DataTable {
        DataTable(title: title, unit: unit, columns: columns,
                  rows: rows.map { DataTable.Row(label: $0.label, values: $0.values) })
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension GReadingAnswer {
    var domain: ReadingAnswer {
        switch self {
        case .agrees: .agrees
        case .contradicts: .contradicts
        case .notStated: .notStated
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension GExamAssessment {
    var domain: ExamAssessment {
        let results = criteria.map { item in
            let criterion: AssessmentCriterion = switch item.criterion {
            case .taskFulfilment: .taskFulfilment
            case .organisation: .organisation
            case .vocabulary: .vocabulary
            case .grammar: .grammar
            }
            let level: CEFRLevel = switch item.level {
            case .a1: .a1
            case .a2: .a2
            case .b1: .b1
            case .b2: .b2
            case .c1: .c1
            case .c2: .c2
            }
            return CriterionResult(criterion: criterion, level: level, comment: item.comment)
        }
        // overallLevel, wordCount and length flags are recomputed by ExamValidator.
        return ExamAssessment(criteria: results, overallLevel: .a1, strengths: strengths,
                              improvements: improvements.map(\.domain), wordCount: 0, isUnderLength: false)
    }
}
#endif
