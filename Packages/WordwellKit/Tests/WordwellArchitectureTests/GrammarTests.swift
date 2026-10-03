import Foundation
import Testing
@testable import WordwellData

@Suite struct GrammarCatalogTests {
    @Test func lessonIDsAreUniqueAndFieldsFilled() {
        let all = GrammarCatalog.all
        #expect(all.count == 82)
        #expect(Set(all.map(\.id)).count == all.count)
        for lesson in all {
            #expect(!lesson.title.isEmpty && !lesson.summary.isEmpty && !lesson.use.isEmpty
                    && !lesson.form.isEmpty && !lesson.commonMistake.isEmpty, "\(lesson.id)")
            #expect(lesson.examples.count >= 2, "\(lesson.id)")
        }
    }

    @Test func everyCategoryHasItsExpectedCountAndIsSortedByCEFR() {
        for category in GrammarCategory.allCases {
            let lessons = GrammarCatalog.lessons(in: category)
            #expect(lessons.count == category.expectedLessonCount, "\(category)")
            #expect(zip(lessons, lessons.dropFirst()).allSatisfy { $0.cefr <= $1.cefr }, "\(category)")
        }
    }

    @Test func everyLessonBelongsToItsCEFRBand() {
        #expect(GrammarCatalog.all.allSatisfy { $0.cefr.band == $0.level })
    }

    @Test func everyLessonHasAWrongRightWhyMistake() {
        for lesson in GrammarCatalog.all {
            let m = lesson.mistake
            #expect(!m.wrong.isEmpty && !m.right.isEmpty && !m.why.isEmpty && m.wrong != m.right, "\(lesson.id)")
        }
    }

    @Test func relatedLessonsExist() {
        let ids = Set(GrammarCatalog.all.map(\.id))
        for (id, others) in GrammarCatalog.related {
            #expect(ids.contains(id), "\(id)")
            for other in others { #expect(ids.contains(other), "\(id) -> \(other)") }
        }
    }
}

@Suite struct GrammarExerciseTests {
    @Test func everyLessonHasExercisesAndNoOrphans() {
        let ids = Set(GrammarCatalog.all.map(\.id))
        #expect(Set(GrammarExercises.byLesson.keys) == ids)
    }

    @Test func exercisesAreWellFormed() {
        for (id, items) in GrammarExercises.byLesson {
            #expect(items.count >= 3, "\(id)")
            for item in items {
                #expect(item.options.indices.contains(item.answer), "\(id): \(item.prompt)")
                #expect(Set(item.options).count == item.options.count, "\(id): \(item.prompt)")
                #expect(!item.explanation.isEmpty, "\(id): \(item.prompt)")
            }
        }
    }
}

@Suite struct GrammarProgressStoreTests {
    private func store() -> GrammarProgressStore {
        let name = "grammar-test-\(UUID().uuidString)"
        return GrammarProgressStore(defaults: UserDefaults(suiteName: name)!)
    }

    @Test func keepsBestScoreOnly() {
        let store = store()
        store.record("articles", score: 3)
        store.record("articles", score: 1)
        #expect(store.bestScore("articles") == 3)
    }

    @Test func doneNeedsAllAnswersCorrect() {
        let store = store()
        let total = GrammarExercises.items(for: "articles").count
        store.record("articles", score: total - 1)
        #expect(!store.isDone("articles"))
        store.record("articles", score: total)
        #expect(store.isDone("articles"))
    }

    @Test func nextLessonPrefersUntriedThenWeakest() {
        let store = store()
        let first = GrammarCatalog.all.first { !GrammarExercises.items(for: $0.id).isEmpty }!.id
        #expect(store.nextLessonID() == first)
        for lesson in GrammarCatalog.all where lesson.id != "articles" && lesson.id != "place" {
            store.record(lesson.id, score: GrammarExercises.items(for: lesson.id).count)
        }
        store.record("articles", score: 3)
        store.record("place", score: 1)
        #expect(store.nextLessonID() == "place")
    }
}
