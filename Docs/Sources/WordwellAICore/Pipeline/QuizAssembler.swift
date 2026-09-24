import Foundation

/// Builds gap-fill questions from model sentences + dictionary distractors.
/// The model never sees or chooses the answer options, so the answer key cannot be hallucinated.
public struct QuizAssembler: Sendable {
    public static let gap = "_____"

    public init() {}

    public func assemble<R: RandomNumberGenerator>(
        word: AIWordContext,
        sentences: [String],
        distractors: [String],
        questionCount: Int,
        optionCount: Int = 4,
        using rng: inout R
    ) -> WordQuiz {
        let lemma = word.lemma.lowercased()
        let pool = distractors.map(\.trimmed).filter { !$0.isEmpty && $0.lowercased() != lemma }.uniqued()
        guard !pool.isEmpty else { return WordQuiz(lemma: word.lemma, questions: []) }

        var questions: [QuizQuestion] = []
        for (index, sentence) in sentences.enumerated() where questions.count < questionCount {
            guard let match = FormMatcher.firstMatch(of: word.allForms, in: sentence) else { continue }

            let prompt = sentence.replacingCharacters(in: match.range, with: Self.gap)
            let offset = index % pool.count
            let rotated = Array(pool[offset...] + pool[..<offset])
            var options = [word.lemma] + rotated.prefix(max(1, optionCount - 1))
            options.shuffle(using: &rng)

            guard let correctIndex = options.firstIndex(of: word.lemma) else { continue }
            questions.append(QuizQuestion(
                id: "\(word.lemma)-\(index)",
                prompt: prompt,
                options: options,
                correctIndex: correctIndex,
                answerForm: match.text
            ))
        }
        return WordQuiz(lemma: word.lemma, questions: questions)
    }

    public func assemble(word: AIWordContext, sentences: [String], distractors: [String], questionCount: Int) -> WordQuiz {
        var rng = SystemRandomNumberGenerator()
        return assemble(word: word, sentences: sentences, distractors: distractors,
                        questionCount: questionCount, using: &rng)
    }
}
