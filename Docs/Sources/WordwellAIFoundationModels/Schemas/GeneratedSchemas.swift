#if canImport(FoundationModels)
import Foundation
import FoundationModels

// Internal guided-generation schemas. Kept separate from WordwellAICore models so the domain
// layer never depends on FoundationModels. Property order = generation/streaming order.

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExplanation {
    @Guide(description: "ID of the explained sense copied from SENSES, for example s1")
    var senseID: String
    @Guide(description: "Plain explanation for the learner, at most two short sentences, in the EXPLANATION LANGUAGE if given")
    var explanation: String
    @Guide(description: "Short everyday comparison that makes the meaning memorable, or an empty string, in the EXPLANATION LANGUAGE if given")
    var analogy: String
    @Guide(description: "Natural English sentences that use the headword", .count(2))
    var examples: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExample {
    @Guide(description: "ID of the sense used, copied from SENSES")
    var senseID: String
    @Guide(description: "One natural English sentence containing the headword")
    var text: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExamples {
    @Guide(.maximumCount(5))
    var sentences: [GExample]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GComparisonExample {
    @Guide(description: "Exactly one of the two compared words")
    var lemma: String
    @Guide(description: "Natural English sentence using that word")
    var sentence: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GComparison {
    @Guide(description: "The main difference in one sentence, in the EXPLANATION LANGUAGE if given")
    var coreDifference: String
    @Guide(description: "When to use word A, one sentence, in the EXPLANATION LANGUAGE if given")
    var useFirstWhen: String
    @Guide(description: "When to use word B, one sentence, in the EXPLANATION LANGUAGE if given")
    var useSecondWhen: String
    @Guide(description: "One example for each word", .count(2))
    var examples: [GComparisonExample]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GMistake {
    @Guide(description: "Typical wrong learner sentence")
    var incorrect: String
    @Guide(description: "Corrected sentence using the headword")
    var correct: String
    @Guide(description: "Why it is wrong, one short sentence, in the EXPLANATION LANGUAGE if given")
    var explanation: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GMistakes {
    @Guide(.maximumCount(3))
    var mistakes: [GMistake]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GGapSentences {
    @Guide(description: "Sentences that each contain the headword exactly once", .maximumCount(6))
    var sentences: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
enum GIssueKind {
    case grammar, wordChoice, collocation, spelling, register, other
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GIssue {
    var kind: GIssueKind
    @Guide(description: "Exact wrong fragment copied from the learner text")
    var fragment: String
    @Guide(description: "Corrected fragment")
    var fix: String
    @Guide(description: "Short reason, one sentence, in the EXPLANATION LANGUAGE if given")
    var explanation: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GImprovement {
    @Guide(description: "Minimally corrected sentence")
    var corrected: String
    @Guide(.maximumCount(4))
    var issues: [GIssue]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GSpeakingPrompt {
    @Guide(description: "Everyday speaking topic, a few words")
    var topic: String
    @Guide(description: "Open, simple questions", .count(3))
    var guidingQuestions: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GSpeakingFeedback {
    @Guide(description: "Overall feedback, one or two kind sentences, in the EXPLANATION LANGUAGE if given")
    var summary: String
    @Guide(description: "What the learner did well, in the EXPLANATION LANGUAGE if given", .maximumCount(2))
    var strengths: [String]
    @Guide(.maximumCount(3))
    var mistakes: [GIssue]
    @Guide(description: "Improved answer close to the learner's ideas, using the target words, at most 4 sentences")
    var betterAnswer: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GWeeklyInsight {
    @Guide(description: "Headline, at most 6 words")
    var headline: String
    @Guide(description: "One sentence about the week, using only given numbers")
    var observation: String
    @Guide(description: "One concrete action for next week, in the EXPLANATION LANGUAGE if given")
    var recommendation: String
}
#endif
