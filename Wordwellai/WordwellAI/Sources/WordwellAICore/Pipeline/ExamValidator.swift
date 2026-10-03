import Foundation

/// Deterministic checks for exam-style material and assessments.
/// Any restricted term or structural problem → `AIError.invalidResponse` (the decorator regenerates).
public struct ExamValidator: Sendable {
    public struct Limits: Sendable {
        public var passageWords = 150...420
        public var tableSize = 2...6
        public init() {}
    }

    public let policy: RestrictedTermsPolicy
    public let limits: Limits

    public init(policy: RestrictedTermsPolicy, limits: Limits = Limits()) {
        self.policy = policy
        self.limits = limits
    }

    // MARK: - Material

    public func validate(_ task: ExamSpeakingTask) throws -> ExamSpeakingTask {
        let prompts = task.prompts.compactMap(\.nilIfBlank).uniqued()
        guard let topic = task.topic.nilIfBlank, prompts.count >= 3 else {
            throw AIError.invalidResponse("incomplete speaking task")
        }
        try enforcePolicy([topic] + prompts)
        return ExamSpeakingTask(id: task.id, part: task.part, topic: topic, prompts: Array(prompts.prefix(5)))
    }

    public func validate(_ task: ExamWritingTask) throws -> ExamWritingTask {
        guard let prompt = task.prompt.nilIfBlank else { throw AIError.invalidResponse("empty writing prompt") }

        var data: DataTable?
        if task.kind == .dataDescription {
            guard let table = task.data, isValid(table) else { throw AIError.invalidResponse("invalid data table") }
            data = table
            try enforcePolicy([table.title, table.unit] + table.columns + table.rows.map(\.label))
        }
        try enforcePolicy([prompt])
        return ExamWritingTask(id: task.id, kind: task.kind, prompt: prompt, data: data)
    }

    public func validate(_ set: ExamReadingSet, questionCount: Int) throws -> ExamReadingSet {
        guard let title = set.title.nilIfBlank, limits.passageWords.contains(WordCounter.count(set.passage)) else {
            throw AIError.invalidResponse("passage length out of range")
        }
        let passage = set.passage.normalizedForComparison

        let questions = set.questions
            .filter { question in
                guard question.statement.nilIfBlank != nil else { return false }
                if question.answer == .notStated { return true }
                // Answer key must be grounded in a quote that really exists in the passage.
                guard let evidence = question.evidence?.nilIfBlank else { return false }
                return passage.contains(evidence.normalizedForComparison)
            }
            .prefix(questionCount)
            .enumerated()
            .map { index, question in
                ReadingQuestion(id: index + 1, statement: question.statement.trimmed, answer: question.answer,
                                evidence: question.answer == .notStated ? nil : question.evidence?.trimmed)
            }

        guard questions.count >= min(3, questionCount) else { throw AIError.invalidResponse("too few grounded questions") }
        try enforcePolicy([title, set.passage] + questions.map(\.statement))
        return ExamReadingSet(id: set.id, title: title, passage: set.passage.trimmed, questions: questions)
    }

    // MARK: - Assessment

    public func validate(_ assessment: ExamAssessment, response: String, minimumWords: Int?) throws -> ExamAssessment {
        let byCriterion = Dictionary(grouping: assessment.criteria, by: \.criterion)
        guard AssessmentCriterion.allCases.allSatisfy({ byCriterion[$0]?.count == 1 }) else {
            throw AIError.invalidResponse("each criterion must be assessed exactly once")
        }

        let wordCount = WordCounter.count(response)
        let isUnderLength = minimumWords.map { wordCount < $0 } ?? false

        // Deterministic rule: under-length answers lose one level on task fulfilment.
        let criteria: [CriterionResult] = AssessmentCriterion.allCases.compactMap { criterion in
            guard let result = byCriterion[criterion]?.first else { return nil }
            guard criterion == .taskFulfilment, isUnderLength, result.level != .a1 else { return result }
            return CriterionResult(criterion: criterion, level: CEFRLevel.allCases[result.level.index - 1],
                                   comment: result.comment)
        }

        let normalizedResponse = response.normalizedForComparison
        let improvements = assessment.improvements.filter { issue in
            guard let fragment = issue.fragment.nilIfBlank, issue.fix.nilIfBlank != nil else { return false }
            return normalizedResponse.contains(fragment.normalizedForComparison)
        }

        try enforcePolicy(criteria.map(\.comment) + assessment.strengths + improvements.map(\.explanation))

        return ExamAssessment(
            criteria: criteria,
            overallLevel: Self.conservativeMedian(criteria.map(\.level)),
            strengths: assessment.strengths.compactMap(\.nilIfBlank),
            improvements: improvements,
            wordCount: wordCount,
            isUnderLength: isUnderLength
        )
    }

    /// Lower median: never rounds the learner up.
    public static func conservativeMedian(_ levels: [CEFRLevel]) -> CEFRLevel {
        let sorted = levels.sorted()
        guard !sorted.isEmpty else { return .a1 }
        return sorted[(sorted.count - 1) / 2]
    }

    // MARK: - Helpers

    private func enforcePolicy(_ texts: [String]) throws {
        let found = policy.violations(in: texts)
        guard found.isEmpty else { throw AIError.invalidResponse("restricted terms: \(found.count)") }
    }

    private func isValid(_ table: DataTable) -> Bool {
        limits.tableSize.contains(table.columns.count)
            && limits.tableSize.contains(table.rows.count)
            && table.title.nilIfBlank != nil
            && table.rows.allSatisfy { row in
                row.label.nilIfBlank != nil
                    && row.values.count == table.columns.count
                    && row.values.allSatisfy { $0.isFinite && $0 >= 0 }
            }
    }
}

public enum WordCounter {
    public static func count(_ text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace)
            .filter { $0.contains { $0.isLetter || $0.isNumber } }
            .count
    }
}
