import Foundation

public enum PartOfSpeech: String, Codable, CaseIterable, Sendable {
    case noun, verb, adjective, adverb, pronoun, preposition
    case conjunction, interjection, determiner, phrase
}

public enum CEFRLevel: String, Codable, CaseIterable, Sendable {
    case a1 = "A1", a2 = "A2", b1 = "B1", b2 = "B2", c1 = "C1", c2 = "C2"
}

public struct DefinitionSense: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let definition: String
    public let examples: [String]
    public let register: String?

    public init(id: String, definition: String, examples: [String], register: String? = nil) {
        self.id = id
        self.definition = definition
        self.examples = examples
        self.register = register
    }
}

public struct CommonMistake: Codable, Hashable, Sendable {
    public let incorrect: String
    public let corrected: String
    public let explanation: String

    public init(incorrect: String, corrected: String, explanation: String) {
        self.incorrect = incorrect
        self.corrected = corrected
        self.explanation = explanation
    }
}

public struct WordEntry: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let word: String
    public let lemma: String
    public let partOfSpeech: PartOfSpeech
    public let ipaUK: String?
    public let ipaUS: String?
    public let senses: [DefinitionSense]
    public let synonyms: [String]
    public let antonyms: [String]
    public let collocations: [String]
    public let cefrLevel: CEFRLevel?
    public let usageNotes: [String]
    public let commonMistakes: [CommonMistake]
    public let audioUK: String?
    public let audioUS: String?

    public init(
        id: String,
        word: String,
        lemma: String,
        partOfSpeech: PartOfSpeech,
        ipaUK: String? = nil,
        ipaUS: String? = nil,
        senses: [DefinitionSense],
        synonyms: [String] = [],
        antonyms: [String] = [],
        collocations: [String] = [],
        cefrLevel: CEFRLevel? = nil,
        usageNotes: [String] = [],
        commonMistakes: [CommonMistake] = [],
        audioUK: String? = nil,
        audioUS: String? = nil
    ) {
        self.id = id
        self.word = word
        self.lemma = lemma
        self.partOfSpeech = partOfSpeech
        self.ipaUK = ipaUK
        self.ipaUS = ipaUS
        self.senses = senses
        self.synonyms = synonyms
        self.antonyms = antonyms
        self.collocations = collocations
        self.cefrLevel = cefrLevel
        self.usageNotes = usageNotes
        self.commonMistakes = commonMistakes
        self.audioUK = audioUK
        self.audioUS = audioUS
    }
}

public struct WordSummary: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let word: String
    public let partOfSpeech: PartOfSpeech
    public let previewDefinition: String
    public let cefrLevel: CEFRLevel?

    public init(
        id: String,
        word: String,
        partOfSpeech: PartOfSpeech,
        previewDefinition: String,
        cefrLevel: CEFRLevel? = nil
    ) {
        self.id = id
        self.word = word
        self.partOfSpeech = partOfSpeech
        self.previewDefinition = previewDefinition
        self.cefrLevel = cefrLevel
    }
}

public struct SearchHistory: Codable, Equatable, Sendable {
    public private(set) var terms: [String] = []

    public init() {}

    public mutating func record(_ query: String) {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return }
        terms.removeAll { $0.localizedCaseInsensitiveCompare(term) == .orderedSame }
        terms.insert(term, at: 0)
        if terms.count > 20 { terms.removeLast(terms.count - 20) }
    }
}
