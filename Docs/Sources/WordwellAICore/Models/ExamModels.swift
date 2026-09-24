import Foundation

// Original exam-style practice. All material is generated fresh; no real exam brand,
// score scale or published test content is referenced. Levels are reported as CEFR only.

public enum SpeakingPart: String, Codable, Sendable, CaseIterable {
    /// Short personal questions.
    case interview
    /// Topic card with prompts, preparation time and a longer monologue.
    case longTurn
    /// Abstract follow-up questions.
    case discussion

    /// Timing is app-defined, never model-defined.
    public var preparationSeconds: Int { self == .longTurn ? 60 : 0 }
    public var speakingSeconds: Int {
        switch self {
        case .interview: 30
        case .longTurn: 120
        case .discussion: 60
        }
    }
}

public enum WritingTaskKind: String, Codable, Sendable, CaseIterable {
    case dataDescription
    case opinionEssay

    public var minimumWords: Int { self == .dataDescription ? 150 : 250 }
    public var suggestedMinutes: Int { self == .dataDescription ? 20 : 40 }
}

public struct ExamSpeakingTask: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public let part: SpeakingPart
    public let topic: String
    /// Questions (interview, discussion) or topic-card prompts (long turn).
    public let prompts: [String]

    public init(id: UUID = UUID(), part: SpeakingPart, topic: String, prompts: [String]) {
        self.id = id
        self.part = part
        self.topic = topic
        self.prompts = prompts
    }
}

public struct DataTable: Codable, Sendable, Hashable {
    public struct Row: Codable, Sendable, Hashable {
        public let label: String
        public let values: [Double]

        public init(label: String, values: [Double]) {
            self.label = label
            self.values = values
        }
    }

    public let title: String
    public let unit: String
    public let columns: [String]
    public let rows: [Row]

    public init(title: String, unit: String, columns: [String], rows: [Row]) {
        self.title = title
        self.unit = unit
        self.columns = columns
        self.rows = rows
    }
}

public struct ExamWritingTask: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public let kind: WritingTaskKind
    /// Task statement written by the model (topic / question).
    public let prompt: String
    /// Present for `.dataDescription`; values are fictional.
    public let data: DataTable?

    public var minimumWords: Int { kind.minimumWords }
    public var suggestedMinutes: Int { kind.suggestedMinutes }

    public init(id: UUID = UUID(), kind: WritingTaskKind, prompt: String, data: DataTable?) {
        self.id = id
        self.kind = kind
        self.prompt = prompt
        self.data = data
    }
}

/// UI labels: "True" / "False" / "Not stated".
public enum ReadingAnswer: String, Codable, Sendable, CaseIterable {
    case agrees, contradicts, notStated
}

public struct ReadingQuestion: Codable, Sendable, Hashable, Identifiable {
    public let id: Int
    public let statement: String
    public let answer: ReadingAnswer
    /// Quote from the passage supporting the answer; nil for `.notStated`.
    public let evidence: String?

    public init(id: Int, statement: String, answer: ReadingAnswer, evidence: String?) {
        self.id = id
        self.statement = statement
        self.answer = answer
        self.evidence = evidence
    }
}

public struct ExamReadingSet: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public let title: String
    public let passage: String
    public let questions: [ReadingQuestion]

    public init(id: UUID = UUID(), title: String, passage: String, questions: [ReadingQuestion]) {
        self.id = id
        self.title = title
        self.passage = passage
        self.questions = questions
    }
}

/// App-defined criteria (own naming). Pronunciation is not assessed from a transcript.
public enum AssessmentCriterion: String, Codable, Sendable, CaseIterable {
    case taskFulfilment, organisation, vocabulary, grammar
}

public struct CriterionResult: Codable, Sendable, Hashable {
    public let criterion: AssessmentCriterion
    public let level: CEFRLevel
    public let comment: String

    public init(criterion: AssessmentCriterion, level: CEFRLevel, comment: String) {
        self.criterion = criterion
        self.level = level
        self.comment = comment
    }
}

public struct ExamAssessment: Codable, Sendable, Hashable {
    public let criteria: [CriterionResult]
    /// Computed deterministically (conservative median), never taken from the model.
    public let overallLevel: CEFRLevel
    public let strengths: [String]
    public let improvements: [SentenceIssue]
    public let wordCount: Int
    public let isUnderLength: Bool
    /// UI must always show this as an unofficial practice estimate.
    public static let disclaimerKey = "exam.assessment.disclaimer"

    public init(criteria: [CriterionResult], overallLevel: CEFRLevel, strengths: [String],
                improvements: [SentenceIssue], wordCount: Int, isUnderLength: Bool) {
        self.criteria = criteria
        self.overallLevel = overallLevel
        self.strengths = strengths
        self.improvements = improvements
        self.wordCount = wordCount
        self.isUnderLength = isUnderLength
    }
}
