import Foundation

public enum IllustrationStyle: String, Codable, Sendable {
    case monochromeLineArt = "monochrome_line_art"
    case colorSwatch = "color_swatch"
}

public enum IllustrationContext: String, Codable, Sendable {
    case header, dictionaryEntry = "dictionary_entry", library, review, speaking
}

public struct IllustrationBinding: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let word: String
    public let lemma: String
    public let partOfSpeech: PartOfSpeech?
    public let senseID: String?
    public let assetName: String
    public let assetPath: String
    public let style: IllustrationStyle
    public let contexts: [IllustrationContext]
    public let version: Int
    public let tags: [String]
    public let altText: String?
    public let isDecorative: Bool
    public let notes: String?

    enum CodingKeys: String, CodingKey {
        case id, word, lemma, partOfSpeech, assetName, assetPath
        case style, contexts, version, tags, altText, isDecorative, notes
        case senseID = "senseId"
    }

    public init(
        id: String,
        word: String,
        lemma: String,
        partOfSpeech: PartOfSpeech? = nil,
        senseID: String? = nil,
        assetName: String,
        assetPath: String,
        style: IllustrationStyle,
        contexts: [IllustrationContext],
        version: Int,
        tags: [String],
        altText: String? = nil,
        isDecorative: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.word = word
        self.lemma = lemma
        self.partOfSpeech = partOfSpeech
        self.senseID = senseID
        self.assetName = assetName
        self.assetPath = assetPath
        self.style = style
        self.contexts = contexts
        self.version = version
        self.tags = tags
        self.altText = altText
        self.isDecorative = isDecorative
        self.notes = notes
    }
}
