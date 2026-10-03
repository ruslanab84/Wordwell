import Foundation

public enum ChoicePracticeMode: Equatable, Sendable {
    case quiz, listening
}

public enum DeterministicPractice {
    /// `targetIDs` is priority-ordered (weakest first); empty means any word may be asked.
    public static func questions(
        from entries: [WordEntry], targetIDs: [String], mode: ChoicePracticeMode, limit: Int = 5
    ) -> [QuizQuestion] {
        var rng = SystemRandomNumberGenerator()
        return questions(from: entries, targetIDs: targetIDs, mode: mode, limit: limit, using: &rng)
    }

    public static func questions<G: RandomNumberGenerator>(
        from entries: [WordEntry], targetIDs: [String], mode: ChoicePracticeMode, limit: Int = 5,
        using rng: inout G
    ) -> [QuizQuestion] {
        let byID = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        // Quiz options are definitions with the headword masked; listening options are the words.
        let optionText: (WordEntry) -> String = {
            mode == .quiz ? maskingHeadword(in: $0.senses[0].definition, word: $0.word) : $0.word
        }
        var seen = Set<String>()
        let candidates = byID.values.filter { !$0.senses.isEmpty && !$0.senses[0].definition.isEmpty }
            .sorted { $0.id < $1.id }
            .filter { seen.insert(optionText($0)).inserted }
        guard candidates.count >= 4, limit > 0 else { return [] }

        let ordered: [WordEntry]
        if targetIDs.isEmpty {
            ordered = candidates.shuffled(using: &rng)
        } else {
            let usable = Dictionary(candidates.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            ordered = targetIDs.compactMap { usable[$0] }
        }

        return ordered.prefix(limit).shuffled(using: &rng).map { entry in
            let answer = optionText(entry)
            // Prefer distractors of the same part of speech, then the same CEFR level.
            let distractors = candidates.filter { $0.id != entry.id }
                .shuffled(using: &rng)
                .enumerated()
                .sorted { lhs, rhs in
                    let l = closeness(lhs.element, to: entry), r = closeness(rhs.element, to: entry)
                    return l != r ? l > r : lhs.offset < rhs.offset
                }
                .prefix(3)
                .map { optionText($0.element) }
            var choices = Array(distractors)
            let slot = Int.random(in: 0...choices.count, using: &rng)
            choices.insert(answer, at: slot)
            return QuizQuestion(
                id: "\(mode == .quiz ? "quiz" : "listening").\(entry.id)",
                prompt: mode == .quiz ? "What does “\(entry.word)” mean?" : "Which word do you hear?",
                choices: choices,
                correctChoiceIndex: slot,
                wordID: entry.id
            )
        }
    }

    private static func closeness(_ other: WordEntry, to entry: WordEntry) -> Int {
        (other.partOfSpeech == entry.partOfSpeech ? 2 : 0)
            + (other.cefrLevel != nil && other.cefrLevel == entry.cefrLevel ? 1 : 0)
    }

    private static func maskingHeadword(in definition: String, word: String) -> String {
        definition.replacingOccurrences(
            of: "\\b\(NSRegularExpression.escapedPattern(for: word))\\b",
            with: "____", options: [.regularExpression, .caseInsensitive]
        )
    }
}
