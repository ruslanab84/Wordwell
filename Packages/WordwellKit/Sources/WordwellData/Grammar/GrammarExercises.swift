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
    public func nextLessonID() -> String {
        func ratio(_ id: String) -> Double {
            Double(scores[id] ?? 0) / Double(GrammarExercises.items(for: id).count)
        }
        let candidates = GrammarCatalog.all.map(\.id).filter { !GrammarExercises.items(for: $0).isEmpty }
        return candidates.min { ratio($0) < ratio($1) } ?? "present-simple"
    }

    /// Done = every exercise answered correctly at least once.
    public func isDone(_ lessonID: String) -> Bool {
        let total = GrammarExercises.items(for: lessonID).count
        return total > 0 && (scores[lessonID] ?? 0) >= total
    }

    private var scores: [String: Int] { defaults.dictionary(forKey: key) as? [String: Int] ?? [:] }
}
