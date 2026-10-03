import Foundation

public struct SimpleExplanation: Codable, Sendable, Hashable {
    public let senseID: String?
    public let explanation: String
    public let analogy: String?
    public let examples: [String]
    public let languageCode: String?

    public init(senseID: String?, explanation: String, analogy: String?, examples: [String], languageCode: String?) {
        self.senseID = senseID
        self.explanation = explanation
        self.analogy = analogy
        self.examples = examples
        self.languageCode = languageCode
    }
}

/// Streaming snapshot. Fields fill in progressively; `isComplete` marks the final value.
public struct ExplanationDraft: Sendable, Hashable {
    public var senseID: String?
    public var explanation: String?
    public var analogy: String?
    public var examples: [String]
    public var isComplete: Bool

    public init(senseID: String? = nil, explanation: String? = nil, analogy: String? = nil,
                examples: [String] = [], isComplete: Bool = false) {
        self.senseID = senseID
        self.explanation = explanation
        self.analogy = analogy
        self.examples = examples
        self.isComplete = isComplete
    }
}

public struct ExampleSentence: Codable, Sendable, Hashable {
    public let text: String
    public let senseID: String?

    public init(text: String, senseID: String?) {
        self.text = text
        self.senseID = senseID
    }
}

public struct WordComparison: Codable, Sendable, Hashable {
    public struct Example: Codable, Sendable, Hashable {
        public let lemma: String
        public let sentence: String

        public init(lemma: String, sentence: String) {
            self.lemma = lemma
            self.sentence = sentence
        }
    }

    public let first: String
    public let second: String
    public let coreDifference: String
    public let useFirstWhen: String
    public let useSecondWhen: String
    public let examples: [Example]

    public init(first: String, second: String, coreDifference: String, useFirstWhen: String,
                useSecondWhen: String, examples: [Example]) {
        self.first = first
        self.second = second
        self.coreDifference = coreDifference
        self.useFirstWhen = useFirstWhen
        self.useSecondWhen = useSecondWhen
        self.examples = examples
    }
}

public struct CommonMistake: Codable, Sendable, Hashable {
    public let incorrect: String
    public let correct: String
    public let explanation: String

    public init(incorrect: String, correct: String, explanation: String) {
        self.incorrect = incorrect
        self.correct = correct
        self.explanation = explanation
    }
}

public struct QuizQuestion: Codable, Sendable, Hashable, Identifiable {
    public let id: String
    /// Sentence with a gap ("_____").
    public let prompt: String
    /// Base forms. The correct option is always the lemma.
    public let options: [String]
    public let correctIndex: Int
    /// Form used in the original sentence, shown after answering ("decided").
    public let answerForm: String

    public init(id: String, prompt: String, options: [String], correctIndex: Int, answerForm: String) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctIndex = correctIndex
        self.answerForm = answerForm
    }
}

public struct WordQuiz: Codable, Sendable, Hashable {
    public let lemma: String
    public let questions: [QuizQuestion]

    public init(lemma: String, questions: [QuizQuestion]) {
        self.lemma = lemma
        self.questions = questions
    }
}

public struct SentenceIssue: Codable, Sendable, Hashable {
    public enum Kind: String, Codable, Sendable, CaseIterable {
        case grammar, wordChoice, collocation, spelling, register, other
    }

    public let kind: Kind
    /// Exact fragment from the learner's text.
    public let fragment: String
    public let fix: String
    public let explanation: String

    public init(kind: Kind, fragment: String, fix: String, explanation: String) {
        self.kind = kind
        self.fragment = fragment
        self.fix = fix
        self.explanation = explanation
    }
}

public struct SentenceImprovement: Codable, Sendable, Hashable {
    public let original: String
    public let corrected: String
    public let issues: [SentenceIssue]

    public var isAlreadyCorrect: Bool { issues.isEmpty }

    public init(original: String, corrected: String, issues: [SentenceIssue]) {
        self.original = original
        self.corrected = corrected
        self.issues = issues
    }
}

public struct SpeakingPrompt: Codable, Sendable, Hashable {
    public let topic: String
    public let guidingQuestions: [String]
    public let targetWords: [String]

    public init(topic: String, guidingQuestions: [String], targetWords: [String]) {
        self.topic = topic
        self.guidingQuestions = guidingQuestions
        self.targetWords = targetWords
    }
}

public struct SpeakingFeedback: Codable, Sendable, Hashable {
    public let summary: String
    public let strengths: [String]
    public let mistakes: [SentenceIssue]
    public let betterAnswer: String
    /// Computed deterministically from the transcript, not by the model.
    public let usedTargetWords: [String]
    public let missedTargetWords: [String]

    public init(summary: String, strengths: [String], mistakes: [SentenceIssue], betterAnswer: String,
                usedTargetWords: [String], missedTargetWords: [String]) {
        self.summary = summary
        self.strengths = strengths
        self.mistakes = mistakes
        self.betterAnswer = betterAnswer
        self.usedTargetWords = usedTargetWords
        self.missedTargetWords = missedTargetWords
    }
}

public struct WeeklyInsight: Codable, Sendable, Hashable {
    public let headline: String
    public let observation: String
    public let recommendation: String

    public init(headline: String, observation: String, recommendation: String) {
        self.headline = headline
        self.observation = observation
        self.recommendation = recommendation
    }
}
