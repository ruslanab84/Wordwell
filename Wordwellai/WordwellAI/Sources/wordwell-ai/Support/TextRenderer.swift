import Foundation
import WordwellAICore

/// Human-readable terminal output. Mirrors the calm, editorial tone of the app.
enum TextRenderer {
    static func explanation(_ value: SimpleExplanation) -> String {
        var lines = [value.explanation]
        if let analogy = value.analogy { lines.append("≈ \(analogy)") }
        lines += value.examples.map { "  • \($0)" }
        if let sense = value.senseID { lines.append("(sense \(sense))") }
        return lines.joined(separator: "\n")
    }

    static func examples(_ values: [ExampleSentence]) -> String {
        values.map { "  • \($0.text)\($0.senseID.map { "  [\($0)]" } ?? "")" }.joined(separator: "\n")
    }

    static func comparison(_ value: WordComparison) -> String {
        var lines = [
            value.coreDifference,
            "\(value.first): \(value.useFirstWhen)",
            "\(value.second): \(value.useSecondWhen)",
        ]
        lines += value.examples.map { "  • [\($0.lemma)] \($0.sentence)" }
        return lines.joined(separator: "\n")
    }

    static func mistakes(_ values: [CommonMistake]) -> String {
        values.map { "✗ \($0.incorrect)\n✓ \($0.correct)\n  \($0.explanation)" }.joined(separator: "\n\n")
    }

    static func quiz(_ value: WordQuiz, showAnswers: Bool) -> String {
        value.questions.enumerated().map { index, question in
            let options = question.options.enumerated().map { optionIndex, option in
                let mark = showAnswers && optionIndex == question.correctIndex ? " ✓" : ""
                return "   \(optionIndex + 1)) \(option)\(mark)"
            }
            return (["\(index + 1). \(question.prompt)"] + options).joined(separator: "\n")
        }.joined(separator: "\n\n")
    }

    static func improvement(_ value: SentenceImprovement) -> String {
        guard !value.isAlreadyCorrect else { return "✓ The sentence is correct." }
        var lines = ["→ \(value.corrected)"]
        lines += value.issues.map { "  • [\($0.kind.rawValue)] \"\($0.fragment)\" → \"\($0.fix)\": \($0.explanation)" }
        return lines.joined(separator: "\n")
    }

    static func speakingPrompt(_ value: SpeakingPrompt) -> String {
        (["Topic: \(value.topic)", "Target words: \(value.targetWords.joined(separator: ", "))"]
            + value.guidingQuestions.map { "  – \($0)" }).joined(separator: "\n")
    }

    static func feedback(_ value: SpeakingFeedback) -> String {
        var lines = [value.summary]
        lines += value.strengths.map { "  + \($0)" }
        lines += value.mistakes.map { "  • \"\($0.fragment)\" → \"\($0.fix)\": \($0.explanation)" }
        lines.append("Better answer: \(value.betterAnswer)")
        lines.append("Used: \(value.usedTargetWords.joined(separator: ", ")) | Missed: \(value.missedTargetWords.joined(separator: ", "))")
        return lines.joined(separator: "\n")
    }

    static func insight(_ value: WeeklyInsight) -> String {
        "\(value.headline)\n\(value.observation)\n→ \(value.recommendation)"
    }
}
