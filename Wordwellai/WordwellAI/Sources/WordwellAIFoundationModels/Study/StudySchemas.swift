#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GWordGuesses {
    @Guide(description: "English words in base form, best first, words only", .maximumCount(5))
    var words: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GStory {
    @Guide(description: "Short title, at most five words")
    var title: String
    @Guide(description: "Story paragraphs of two or three short sentences each", .count(3))
    var paragraphs: [String]
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GExercise {
    @Guide(description: "Natural sentence with exactly one mistake of the given pattern")
    var incorrect: String
    @Guide(description: "The same sentence with that mistake fixed")
    var correct: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GMiniLesson {
    @Guide(description: "Lesson title, at most six words")
    var title: String
    @Guide(description: "The rule in at most two short sentences")
    var rule: String
    @Guide(description: "One memorable tip, one sentence")
    var tip: String
    @Guide(description: "Practice pairs", .count(4))
    var exercises: [GExercise]
}
#endif
