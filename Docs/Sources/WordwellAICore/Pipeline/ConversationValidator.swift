import Foundation

/// Keeps model output honest: feedback may only quote what the learner actually wrote.
public struct ConversationValidator: Sendable {
    public var maxReplyCharacters = 400
    public var maxMistakes = 4
    public var maxExpressions = 5
    public var maxWordsToSave = 6

    public init() {}

    public func validate(_ reply: ConversationReply) throws -> ConversationReply {
        let text = reply.text.trimmed
        guard !text.isEmpty else { throw AIError.invalidResponse("empty reply") }
        guard text.count <= maxReplyCharacters else { throw AIError.invalidResponse("reply too long") }
        return ConversationReply(text: text, objectiveMet: reply.objectiveMet)
    }

    /// Mistakes whose `original` is not found in a learner turn are dropped, not repaired.
    public func validate(_ summary: ConversationSummary, turns: [ConversationTurn]) throws -> ConversationSummary {
        let learnerText = turns.filter { $0.speaker == .learner }.map(\.text.normalizedForComparison)
        guard !learnerText.isEmpty else { throw AIError.invalidResponse("no learner turns") }

        let mistakes = summary.mistakes.compactMap { mistake -> ConversationMistake? in
            let original = mistake.original.normalizedForComparison
            let better = mistake.better.trimmed
            guard !original.isEmpty, !better.isEmpty, mistake.why.nilIfBlank != nil,
                  better.normalizedForComparison != original,
                  learnerText.contains(where: { $0.contains(original) }) else { return nil }
            return ConversationMistake(original: mistake.original.trimmed, better: better, why: mistake.why.trimmed)
        }
        let expressions = summary.expressions.compactMap(\.nilIfBlank).uniqued()
        let words = summary.wordsToSave
            .compactMap { $0.trimmed.lowercased().nilIfBlank }
            .filter { $0.split(separator: " ").count <= 3 }
            .uniqued()

        return ConversationSummary(
            mistakes: Array(mistakes.prefix(maxMistakes)),
            expressions: Array(expressions.prefix(maxExpressions)),
            wordsToSave: Array(words.prefix(maxWordsToSave)),
            objectiveMet: summary.objectiveMet)
    }
}
