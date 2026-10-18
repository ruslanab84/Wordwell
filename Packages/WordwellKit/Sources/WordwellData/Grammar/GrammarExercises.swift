import Foundation

public enum GrammarExercises: Sendable {
    public static func items(for lessonID: String) -> [GrammarExercise] { byLesson[lessonID] ?? [] }

    public static let byLesson: [String: [GrammarExercise]] =
        Dictionary(uniqueKeysWithValues: GrammarCatalog.all.map { ($0.id, $0.exercises) })
}

/// Best score per lesson, kept in UserDefaults (same approach as SkillsCheckDraftStore).
public struct GrammarProgressStore {
    private let defaults: UserDefaults
    private let key = "grammar.bestScores.v1"

    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    public func bestScore(_ lessonID: String) -> Int? { scores[lessonID] }

    public func record(_ lessonID: String, score: Int) {
        var all = scores
        all[lessonID] = max(all[lessonID] ?? 0, score)
        defaults.set(all, forKey: key)
    }

    /// Lesson with exercises and the lowest best-score ratio (never tried = 0); ties keep catalog order.
    public func nextLessonID(freeOnly: Bool = false) -> String {
        func ratio(_ id: String) -> Double {
            Double(scores[id] ?? 0) / Double(GrammarExercises.items(for: id).count)
        }
        let candidates = GrammarCatalog.all.filter { !freeOnly || $0.isFree }.map(\.id)
            .filter { !GrammarExercises.items(for: $0).isEmpty }
        return candidates.min { ratio($0) < ratio($1) } ?? "present-simple"
    }

    /// Done = every exercise answered correctly at least once.
    public func isDone(_ lessonID: String) -> Bool {
        let total = GrammarExercises.items(for: lessonID).count
        return total > 0 && (scores[lessonID] ?? 0) >= total
    }

    private var scores: [String: Int] { defaults.dictionary(forKey: key) as? [String: Int] ?? [:] }
}

/// One practice question, addressed by lesson and position in that lesson's exercises.
public struct GrammarReviewItem: Hashable, Sendable {
    public let lessonID: String
    public let index: Int

    public init(lessonID: String, index: Int) {
        self.lessonID = lessonID
        self.index = index
    }

    public var exercise: GrammarExercise? {
        let items = GrammarExercises.items(for: lessonID)
        return items.indices.contains(index) ? items[index] : nil
    }
}

/// Missed practice questions come back after 1, 3, then 7 days; three correct reviews in a row clear them.
public struct GrammarReviewStore {
    private let defaults: UserDefaults
    private let key = "grammar.review.v1"
    private static let intervals: [TimeInterval] = [1, 3, 7].map { $0 * 86_400 }

    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    public func recordWrong(lessonID: String, index: Int, now: Date = .now) {
        save(GrammarReviewItem(lessonID: lessonID, index: index), step: 0, now: now)
    }

    public func recordCorrect(_ item: GrammarReviewItem, now: Date = .now) {
        guard let step = entries[id(item)].map({ Int($0[0]) }) else { return }
        save(item, step: step + 1, now: now)
    }

    /// Due questions, oldest first; entries whose exercise no longer exists are skipped.
    public func due(now: Date = .now) -> [GrammarReviewItem] {
        entries
            .filter { $0.value[1] <= now.timeIntervalSince1970 }
            .sorted { ($0.value[1], $0.key) < ($1.value[1], $1.key) }
            .compactMap { key, _ in
                guard let split = key.lastIndex(of: "#"), let index = Int(key[key.index(after: split)...]) else { return nil }
                let item = GrammarReviewItem(lessonID: String(key[..<split]), index: index)
                return item.exercise == nil ? nil : item
            }
    }

    private func save(_ item: GrammarReviewItem, step: Int, now: Date) {
        var all = entries
        if Self.intervals.indices.contains(step) {
            all[id(item)] = [Double(step), now.timeIntervalSince1970 + Self.intervals[step]]
        } else {
            all[id(item)] = nil
        }
        defaults.set(all, forKey: key)
    }

    private func id(_ item: GrammarReviewItem) -> String { "\(item.lessonID)#\(item.index)" }

    /// "lesson#index" → [step, due timestamp].
    private var entries: [String: [Double]] {
        (defaults.dictionary(forKey: key) as? [String: [Double]] ?? [:]).filter { $0.value.count == 2 }
    }
}

/// Checks a typed gap-fill answer against the correct option.
public enum GrammarAnswer {
    public static func matches(_ typed: String, _ correct: String) -> Bool {
        let typed = normalized(typed)
        return !typed.isEmpty && typed == normalized(correct)
    }

    /// Lowercased, curly apostrophes straightened, contractions expanded, single-spaced, no final dot.
    /// ponytail: 's is left alone (is / has / possessive are ambiguous).
    public static func normalized(_ text: String) -> String {
        var s = text.lowercased().replacingOccurrences(of: "’", with: "'")
        for (short, full) in [("won't", "will not"), ("can't", "cannot"), ("n't", " not"),
                              ("'m", " am"), ("'re", " are"), ("'ve", " have"), ("'ll", " will")] {
            s = s.replacingOccurrences(of: short, with: full)
        }
        s = s.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        while s.hasSuffix(".") { s.removeLast() }
        return s.trimmingCharacters(in: .whitespaces)
    }
}
