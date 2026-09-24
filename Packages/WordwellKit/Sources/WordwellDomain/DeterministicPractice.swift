import Foundation

public enum ChoicePracticeMode: Equatable, Sendable {
    case quiz, listening
}

public enum DeterministicPractice {
    public static func questions(
        from entries: [WordEntry], targetIDs: [String], mode: ChoicePracticeMode, limit: Int = 5
    ) -> [QuizQuestion] {
        let candidates = Dictionary(entries.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            .values.filter { !$0.senses.isEmpty && !$0.senses[0].definition.isEmpty }
            .sorted { $0.id < $1.id }
        let optionText: (WordEntry) -> String = { mode == .quiz ? $0.senses[0].definition : $0.word }
        var seen = Set<String>()
        let available = candidates.map(optionText).filter { seen.insert($0).inserted }
        guard available.count >= 4 else { return [] }
        let targetSet = Set(targetIDs)
        seen.removeAll()
        var targets = Array(candidates.filter { targetSet.isEmpty || targetSet.contains($0.id) }
            .filter { seen.insert(optionText($0)).inserted }
            .prefix(max(limit, 0)))
        guard !targets.isEmpty else { return [] }

        var pools = [
            targets.enumerated().filter { $0.offset.isMultiple(of: 2) }.map { optionText($0.element) },
            targets.enumerated().filter { !$0.offset.isMultiple(of: 2) }.map { optionText($0.element) },
        ]
        let needed = pools.reduce(0) { $0 + ($1.isEmpty ? 0 : max(4, $1.count)) }
        if available.count < needed {
            targets = Array(targets.prefix(1))
            pools = [[optionText(targets[0])], []]
        }
        let targetAnswers = Set(targets.map(optionText))
        var fillers = available.filter { !targetAnswers.contains($0) }
        for group in pools.indices where !pools[group].isEmpty {
            while pools[group].count < 4 { pools[group].append(fillers.removeFirst()) }
        }

        return targets.enumerated().map { index, entry in
            let answer = optionText(entry)
            let slot = index % 4
            var choices = Array(pools[index % 2].filter { $0 != answer }.prefix(3))
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
}
