#if canImport(FoundationModels)
import Foundation
import WordwellAICore

/// Renders compact, token-efficient prompts. Dictionary data is inlined (no extra tool round-trip);
/// senses are trimmed until the prompt fits the context budget.
@available(iOS 26.0, macOS 26.0, *)
public struct PromptBuilder: Sendable {
    public var maxSenses: Int
    public var maxCollocations: Int
    public let budget: TokenBudget

    public init(maxSenses: Int = 3, maxCollocations: Int = 5, budget: TokenBudget = TokenBudget()) {
        self.maxSenses = maxSenses
        self.maxCollocations = maxCollocations
        self.budget = budget
    }

    // MARK: - Word-level prompts

    public func explain(_ word: AIWordContext, learner: LearnerProfile, languageCode: String?) async -> String {
        await fitted(.explain) { senses in
            """
            \(render(word, maxSenses: senses))
            \(learnerBlock(learner, languageCode: languageCode))
            TASK: Explain the most useful sense of "\(word.lemma)" for this learner and give 2 examples.
            """
        }
    }

    public func examples(_ word: AIWordContext, learner: LearnerProfile, count: Int) async -> String {
        await fitted(.examples) { senses in
            """
            \(render(word, maxSenses: senses))
            \(learnerBlock(learner, languageCode: nil))
            TASK: Write \(count) different example sentences with "\(word.lemma)". Set senseID to the sense each sentence uses.
            """
        }
    }

    public func compare(_ first: AIWordContext, _ second: AIWordContext, learner: LearnerProfile) async -> String {
        await fitted(.compare) { senses in
            """
            WORD A
            \(render(first, maxSenses: senses))
            WORD B
            \(render(second, maxSenses: senses))
            \(learnerBlock(learner, languageCode: nil))
            TASK: Explain the difference between "\(first.lemma)" and "\(second.lemma)". Give one example for each word; set lemma to exactly "\(first.lemma)" or "\(second.lemma)".
            """
        }
    }

    public func commonMistakes(_ word: AIWordContext, learner: LearnerProfile) async -> String {
        await fitted(.commonMistakes) { senses in
            """
            \(render(word, maxSenses: senses))
            \(learnerBlock(learner, languageCode: nil))
            TASK: List up to 3 mistakes learners at this level often make with "\(word.lemma)".
            """
        }
    }

    public func gapSentences(_ word: AIWordContext, learner: LearnerProfile, count: Int) async -> String {
        await fitted(.quiz) { senses in
            """
            \(render(word, maxSenses: senses))
            \(learnerBlock(learner, languageCode: nil))
            TASK: Write \(count) quiz sentences. Each uses "\(word.lemma)" (any form) exactly once.
            """
        }
    }

    public func improve(_ sentence: String, target: AIWordContext?, learner: LearnerProfile) async -> String {
        await fitted(.improveSentence) { senses in
            var parts = ["LEARNER SENTENCE: <<<\(sentence)>>>"]
            if let target {
                parts.append("TARGET WORD\n" + render(target, maxSenses: senses))
            }
            parts.append(learnerBlock(learner, languageCode: nil))
            parts.append("TASK: Correct the learner sentence.")
            return parts.joined(separator: "\n")
        }
    }

    // MARK: - Speaking & insight

    public func speakingPrompt(_ words: [AIWordContext], learner: LearnerProfile) async -> String {
        """
        TARGET WORDS
        \(words.map(renderShort).joined(separator: "\n"))
        \(learnerBlock(learner, languageCode: nil))
        TASK: Create a speaking topic and 3 guiding questions that need these words.
        """
    }

    public func speakingFeedback(transcript: String, prompt: SpeakingPrompt, words: [AIWordContext], learner: LearnerProfile) async -> String {
        """
        TOPIC: \(prompt.topic)
        QUESTIONS: \(prompt.guidingQuestions.joined(separator: " | "))
        TARGET WORDS
        \(words.map(renderShort).joined(separator: "\n"))
        \(learnerBlock(learner, languageCode: nil))
        TRANSCRIPT: <<<\(transcript)>>>
        TASK: Give feedback on the transcript.
        """
    }

    public func weeklyInsight(_ stats: WeeklyStats, learner: LearnerProfile) async -> String {
        """
        WEEK STATS: words learned \(stats.wordsLearned); words reviewed \(stats.wordsReviewed); speaking sessions \(stats.speakingSessions); listening minutes \(stats.listeningMinutes); quiz accuracy \(Int(stats.quizAccuracy * 100))%; streak \(stats.streakDays) days
        WEAK WORDS: \(stats.weakWords.prefix(5).joined(separator: ", "))
        \(learnerBlock(learner, languageCode: nil))
        TASK: Write the weekly insight.
        """
    }

    // MARK: - Rendering

    public func render(_ word: AIWordContext, maxSenses: Int) -> String {
        var lines = ["HEADWORD: \(word.lemma) (\(word.partOfSpeech)\(word.cefrLevel.map { ", \($0.rawValue)" } ?? ""))"]
        if !word.forms.isEmpty {
            lines.append("FORMS: \(word.forms.joined(separator: ", "))")
        }
        lines.append("SENSES:")
        for sense in word.senses.prefix(max(1, maxSenses)) {
            let example = sense.example.map { " Example: \($0)" } ?? ""
            lines.append("[\(sense.id)] \(sense.definition).\(example)")
        }
        if !word.collocations.isEmpty {
            lines.append("COLLOCATIONS: \(word.collocations.prefix(maxCollocations).joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }

    private func renderShort(_ word: AIWordContext) -> String {
        "- \(word.lemma) (\(word.partOfSpeech)): \(word.senses.first?.definition ?? "")"
    }

    private func learnerBlock(_ learner: LearnerProfile, languageCode: String?) -> String {
        var lines = ["LEARNER LEVEL: \(learner.level.rawValue)"]
        if let languageCode, !languageCode.lowercased().hasPrefix("en") {
            let name = Locale(identifier: "en").localizedString(forLanguageCode: languageCode) ?? languageCode
            lines.append("EXPLANATION LANGUAGE: \(name)")
        }
        if !learner.interests.isEmpty {
            lines.append("INTERESTS: \(learner.interests.prefix(3).joined(separator: ", "))")
        }
        return lines.joined(separator: "\n")
    }

    private func fitted(_ task: AITask, _ make: (Int) -> String) async -> String {
        let instructions = AIPrompts.instructions(for: task)
        var senses = maxSenses
        var prompt = make(senses)
        while senses > 1, !(await budget.fits(prompt: prompt, instructions: instructions)) {
            senses -= 1
            prompt = make(senses)
        }
        return prompt
    }
}
#endif
