import Foundation
import WidgetKit
import WordwellDomain

/// Picks one word per day ahead of time and shares the plan with the Home Screen widget.
@MainActor
final class WordOfTheDay {
    private let dictionary: any DictionaryRepository
    private let library: any WordLibraryRepository
    private let defaults = UserDefaults(suiteName: DailyWordSchedule.appGroup) ?? .standard
    private let daysAhead = 14

    init(dictionary: any DictionaryRepository, library: any WordLibraryRepository) {
        self.dictionary = dictionary
        self.library = library
    }

    /// Today's word, topping the schedule up to `daysAhead` days so the widget keeps changing at midnight.
    func today(variant: EnglishVariant, topicID: String?) async -> DailyWord? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let todayKey = DailyWordSchedule.dayKey(start)
        let stored = DailyWordSchedule.load(from: defaults)
        var schedule = stored.flatMap { $0.topicID == topicID && $0.variant == variant ? $0 : nil }
            ?? DailyWordSchedule(topicID: topicID, variant: variant, words: [])
        schedule.words.removeAll { $0.day < todayKey }

        let planned = Set(schedule.words.map(\.day))
        let missing = (0..<daysAhead)
            .map { DailyWordSchedule.dayKey(calendar.date(byAdding: .day, value: $0, to: start)!) }
            .filter { !planned.contains($0) }
        if !missing.isEmpty {
            let saved = (try? await library.allSavedWords())?.map(\.wordID) ?? []
            let topicIDs = VocabularyTopic.all.first { $0.id == topicID }.map { Set($0.wordIDs) }
            // ponytail: a used-up topic leaves the schedule short; it tops up on the next launch.
            let entries = (try? await dictionary.notificationEntries(
                excluding: Set(saved).union(schedule.words.map(\.wordID)), limit: missing.count, among: topicIDs
            )) ?? []
            schedule.words += zip(missing, entries).map { day, entry in
                DailyWord(day: day, wordID: entry.id, word: entry.word, partOfSpeech: entry.partOfSpeech.rawValue,
                          ipa: entry.ipa(for: variant), definition: entry.senses.first?.definition ?? "")
            }
            schedule.words.sort { $0.day < $1.day }
        }

        if schedule != stored {
            schedule.save(to: defaults)
            WidgetCenter.shared.reloadAllTimelines()
        }
        return schedule.words.first { $0.day == todayKey }
    }
}
