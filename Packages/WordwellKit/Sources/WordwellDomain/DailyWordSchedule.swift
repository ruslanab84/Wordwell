import Foundation

/// A word picked ahead of time for one calendar day, shown on Home and in the widget.
public struct DailyWord: Codable, Hashable, Sendable {
    /// Local calendar day as `yyyyMMdd`.
    public let day: String
    public let wordID: String
    public let word: String
    public let partOfSpeech: String
    public let ipa: String
    public let definition: String

    public init(day: String, wordID: String, word: String, partOfSpeech: String, ipa: String, definition: String) {
        self.day = day
        self.wordID = wordID
        self.word = word
        self.partOfSpeech = partOfSpeech
        self.ipa = ipa
        self.definition = definition
    }
}

/// Upcoming words of the day, written by the app and read by the widget through the App Group.
public struct DailyWordSchedule: Codable, Equatable, Sendable {
    public static let appGroup = "group.RuslanAbd.Wordwell"
    private static let key = "wordwell.dailyWordSchedule"

    public var topicID: String?
    public var variant: EnglishVariant
    public var words: [DailyWord]

    public init(topicID: String?, variant: EnglishVariant, words: [DailyWord]) {
        self.topicID = topicID
        self.variant = variant
        self.words = words
    }

    public static func load(from defaults: UserDefaults) -> DailyWordSchedule? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(DailyWordSchedule.self, from: $0) }
    }

    public func save(to defaults: UserDefaults) {
        defaults.set(try? JSONEncoder().encode(self), forKey: Self.key)
    }

    public static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", components.year!, components.month!, components.day!)
    }

    public func word(on date: Date, calendar: Calendar = .current) -> DailyWord? {
        let day = Self.dayKey(date, calendar: calendar)
        return words.first { $0.day == day }
    }
}

extension WordEntry {
    /// Transcription in the learner's variant, falling back to the other one.
    public func ipa(for variant: EnglishVariant) -> String {
        switch variant {
        case .uk: ipaUK ?? ipaUS ?? ""
        case .us, .both: ipaUS ?? ipaUK ?? ""
        }
    }
}
