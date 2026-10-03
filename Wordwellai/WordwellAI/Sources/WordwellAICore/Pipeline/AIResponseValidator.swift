import Foundation

/// Deterministic checks applied to every model output before it reaches UI or cache.
/// Invalid items are dropped; an empty result becomes `AIError.invalidResponse`.
public struct AIResponseValidator: Sendable {
    public struct Limits: Sendable {
        public var maxExplanationLength = 420
        public var maxSentenceLength = 220
        public init() {}
    }

    public let limits: Limits

    public init(limits: Limits = Limits()) {
        self.limits = limits
    }

    public func validate(_ value: SimpleExplanation, for word: AIWordContext) throws -> SimpleExplanation {
        guard let explanation = value.explanation.nilIfBlank else {
            throw AIError.invalidResponse("empty explanation")
        }
        let knownSense = word.senses.contains { $0.id == value.senseID }
        return SimpleExplanation(
            senseID: knownSense ? value.senseID : word.senses.first?.id,
            explanation: String(explanation.prefix(limits.maxExplanationLength)),
            analogy: value.analogy?.nilIfBlank,
            examples: validSentences(value.examples, containing: word.allForms),
            languageCode: value.languageCode
        )
    }

    public func validate(_ examples: [ExampleSentence], for word: AIWordContext) throws -> [ExampleSentence] {
        let senseIDs = Set(word.senses.map(\.id))
        let texts = validSentences(examples.map(\.text), containing: word.allForms)
        guard !texts.isEmpty else { throw AIError.invalidResponse("no example contains the headword") }

        return texts.map { text in
            let senseID = examples.first { $0.text.trimmed == text }?.senseID
            return ExampleSentence(text: text, senseID: senseID.flatMap { senseIDs.contains($0) ? $0 : nil })
        }
    }

    public func validate(_ value: WordComparison, first: AIWordContext, second: AIWordContext) throws -> WordComparison {
        guard
            let core = value.coreDifference.nilIfBlank,
            let useFirst = value.useFirstWhen.nilIfBlank,
            let useSecond = value.useSecondWhen.nilIfBlank
        else { throw AIError.invalidResponse("incomplete comparison") }

        let examples = value.examples.filter { example in
            let word = example.lemma.lowercased() == first.lemma.lowercased() ? first
                : example.lemma.lowercased() == second.lemma.lowercased() ? second : nil
            guard let word else { return false }
            return FormMatcher.contains(word.allForms, in: example.sentence)
        }

        return WordComparison(first: first.lemma, second: second.lemma, coreDifference: core,
                              useFirstWhen: useFirst, useSecondWhen: useSecond, examples: examples)
    }

    public func validate(_ mistakes: [CommonMistake], for word: AIWordContext) throws -> [CommonMistake] {
        let valid = mistakes.filter { mistake in
            guard let incorrect = mistake.incorrect.nilIfBlank, let correct = mistake.correct.nilIfBlank else { return false }
            return incorrect.normalizedForComparison != correct.normalizedForComparison
                && FormMatcher.contains(word.allForms, in: correct)
        }
        guard !valid.isEmpty else { throw AIError.invalidResponse("no valid mistakes") }
        return valid.uniqued()
    }

    public func validate(_ quiz: WordQuiz) throws -> WordQuiz {
        let questions = quiz.questions.filter { question in
            question.options.indices.contains(question.correctIndex)
                && Set(question.options.map { $0.lowercased() }).count == question.options.count
                && question.options.count >= 2
        }
        guard !questions.isEmpty else { throw AIError.invalidResponse("empty quiz") }
        return WordQuiz(lemma: quiz.lemma, questions: questions)
    }

    public func validate(_ value: SentenceImprovement) -> SentenceImprovement {
        let unchanged = value.corrected.normalizedForComparison == value.original.normalizedForComparison
        let issues = unchanged ? [] : validIssues(value.issues, in: value.original)
        return SentenceImprovement(
            original: value.original,
            corrected: issues.isEmpty ? value.original : value.corrected.trimmed,
            issues: issues
        )
    }

    public func validate(_ value: SpeakingFeedback, transcript: String) throws -> SpeakingFeedback {
        guard let summary = value.summary.nilIfBlank else { throw AIError.invalidResponse("empty feedback") }
        return SpeakingFeedback(
            summary: summary,
            strengths: value.strengths.compactMap(\.nilIfBlank),
            mistakes: validIssues(value.mistakes, in: transcript),
            betterAnswer: value.betterAnswer.trimmed,
            usedTargetWords: value.usedTargetWords,
            missedTargetWords: value.missedTargetWords
        )
    }

    public func validate(_ value: WeeklyInsight) throws -> WeeklyInsight {
        guard let headline = value.headline.nilIfBlank, let recommendation = value.recommendation.nilIfBlank else {
            throw AIError.invalidResponse("empty insight")
        }
        return WeeklyInsight(headline: headline, observation: value.observation.trimmed, recommendation: recommendation)
    }

    // MARK: - Helpers

    private func validSentences(_ sentences: [String], containing forms: [String]) -> [String] {
        sentences
            .map(\.trimmed)
            .filter { !$0.isEmpty && $0.count <= limits.maxSentenceLength && FormMatcher.contains(forms, in: $0) }
            .uniqued()
    }

    /// Keeps only issues that quote text actually present in the learner's input.
    private func validIssues(_ issues: [SentenceIssue], in source: String) -> [SentenceIssue] {
        let normalizedSource = source.normalizedForComparison
        return issues.filter { issue in
            guard let fragment = issue.fragment.nilIfBlank, issue.fix.nilIfBlank != nil else { return false }
            return normalizedSource.contains(fragment.normalizedForComparison)
                && fragment.normalizedForComparison != issue.fix.normalizedForComparison
        }
    }
}
