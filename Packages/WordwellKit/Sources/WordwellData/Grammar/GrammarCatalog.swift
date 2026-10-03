import Foundation

public enum GrammarLevel: Int, Comparable, CaseIterable, Sendable {
    case foundation, intermediate, advanced

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    public var label: String {
        switch self {
        case .foundation: "A1–A2"
        case .intermediate: "B1–B2"
        case .advanced: "C1"
        }
    }
}

public enum GrammarCategory: String, CaseIterable, Identifiable, Sendable {
    case tenses = "Tenses"
    case conditionals = "Conditionals & wishes"
    case modals = "Modal verbs"
    case nouns = "Nouns, articles & pronouns"
    case adjectives = "Adjectives & adverbs"
    case prepositions = "Prepositions"
    case buildingSentences = "Building sentences"
    case verbPatterns = "Verb patterns"
    case clauses = "Clauses & linking"
    case passiveReported = "Passive & reported speech"
    case advanced = "Advanced structures"

    public var id: String { rawValue }

    public var summary: String {
        switch self {
        case .tenses: "Present, past, and future actions"
        case .conditionals: "Real possibilities and imagined situations"
        case .modals: "Ability, obligation, possibility, and politeness"
        case .nouns: "Naming and referring to people and things"
        case .adjectives: "Describing, comparing, and adding detail"
        case .prepositions: "Where, when, and how things relate"
        case .buildingSentences: "Word order, questions, and clear writing"
        case .verbPatterns: "What can follow a verb"
        case .clauses: "Joining ideas into longer sentences"
        case .passiveReported: "Changing focus and reporting speech"
        case .advanced: "Emphasis, omission, and unreal meaning"
        }
    }

    public var overview: String {
        switch self {
        case .tenses:
            "English verb forms show when something happens and how we see the action. Start with the time: present, past, or future. Then ask whether it is a habit, in progress, finished, or still connected to now."
        case .conditionals:
            "A conditional connects a situation with its result. Choose a form by deciding whether the situation is generally true, realistically possible, imagined, or already impossible to change."
        case .modals:
            "Modal verbs change the meaning of the main verb. They can express ability, permission, obligation, probability, or a more polite tone. Most are followed by the base verb."
        case .nouns:
            "Nouns name people and things. Articles, determiners, and pronouns help a listener know how many you mean, which one you mean, or what a word refers back to."
        case .adjectives:
            "Adjectives describe nouns; adverbs often describe actions or adjectives. Their position and form help you compare things and show how strong a description is."
        case .prepositions:
            "Prepositions connect an action or object to a place, time, direction, or another word. The same short word can have different uses, so learn it with a phrase and an example."
        case .buildingSentences:
            "English sentences usually put the subject before the verb. Auxiliaries help form questions and negatives, while agreement and punctuation make the message clear."
        case .verbPatterns:
            "The verb you choose affects what can come next: an -ing form, an infinitive, an object, or a particle. Learning the full pattern makes a sentence sound natural."
        case .clauses:
            "Clauses let you add a reason, time, contrast, or description to a main idea. Notice which words join the parts and whether both parts need a subject and verb."
        case .passiveReported:
            "The passive highlights an action or its receiver. Reported speech retells someone’s words and may change pronouns, time words, and verb forms."
        case .advanced:
            "Advanced structures can shift emphasis, leave understood words out, or present a situation as unreal. Use them when their meaning is clearer than the simpler alternative."
        }
    }

    public var symbol: String {
        switch self {
        case .tenses: "clock"
        case .conditionals: "arrow.triangle.branch"
        case .modals: "slider.horizontal.3"
        case .nouns: "textformat.abc"
        case .adjectives: "textformat.size"
        case .prepositions: "square.on.square"
        case .buildingSentences: "text.alignleft"
        case .verbPatterns: "arrow.left.arrow.right"
        case .clauses: "link"
        case .passiveReported: "quote.bubble"
        case .advanced: "asterisk"
        }
    }

    public var expectedLessonCount: Int {
        switch self {
        case .tenses: 14
        case .conditionals: 6
        case .modals: 7
        case .nouns: 12
        case .adjectives: 6
        case .prepositions: 6
        case .buildingSentences: 9
        case .verbPatterns: 6
        case .clauses: 6
        case .passiveReported: 5
        case .advanced: 5
        }
    }
}

public enum GrammarTimeline: Sendable {
    case repeated, now, past, pastPeriod, pastToNow, future
}

public enum GrammarDiagram: Sendable {
    case timeline(GrammarTimeline)
    case place
    case compare([String])
    case flow([String])

    public var labels: [String] {
        switch self {
        case .timeline: ["Past", "Now", "Future"]
        case .place: ["In", "On", "Under"]
        case .compare(let labels), .flow(let labels): labels
        }
    }
}

public struct GrammarExample: Sendable, Decodable {
    public let sentence: String
    public let meaning: String
}

/// One multiple-choice item; "___" in `prompt` marks the gap.
public struct GrammarExercise: Sendable, Decodable {
    public let prompt: String
    public let options: [String]
    public let answer: Int
    public let explanation: String
}

/// A typical learner error shown as wrong / right / why.
public struct GrammarMistake: Sendable, Decodable {
    public let wrong: String
    public let right: String
    public let why: String
}

public struct GrammarLesson: Identifiable, Sendable {
    public let id: String
    public let category: GrammarCategory
    public let cefr: GrammarCEFR
    public let title: String
    public let summary: String
    public let use: String
    public let form: String
    public let examples: [GrammarExample]
    public let commonMistake: String
    public let diagram: GrammarDiagram
    public let diagramCaption: String
    public let related: [String]
    public let mistake: GrammarMistake
    public let exercises: [GrammarExercise]

    public var level: GrammarLevel { cefr.band }
}

/// Lessons live in the bundled `Grammar.json`. A missing or broken file yields an empty catalog,
/// never invented content; `GrammarTests` fails if that happens.
public enum GrammarCatalog: Sendable {
    public static let all: [GrammarLesson] = {
        guard let url = Bundle.module.url(forResource: "Grammar", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(GrammarFile.self, from: data) else { return [] }
        let base = file.lessons.compactMap(\.lesson)
        // Group by category, then by CEFR step, easiest first; the index keeps file order within a step.
        let order = Dictionary(uniqueKeysWithValues: GrammarCategory.allCases.enumerated().map { ($1, $0) })
        return base.enumerated().sorted {
            let (a, b) = ($0.element, $1.element)
            if a.category != b.category { return order[a.category]! < order[b.category]! }
            return a.cefr != b.cefr ? a.cefr < b.cefr : $0.offset < $1.offset
        }.map(\.element)
    }()

    public static func lessons(in category: GrammarCategory, level: GrammarCEFR? = nil) -> [GrammarLesson] {
        all.filter { $0.category == category && (level == nil || $0.cefr == level) }
    }

    public static let related: [String: [String]] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0.related) })
}

// MARK: - JSON shape

private struct GrammarFile: Decodable {
    let lessons: [GrammarLessonDTO]
}

private struct GrammarDiagramDTO: Decodable {
    let kind: String
    let moment: String?
    let labels: [String]?

    var diagram: GrammarDiagram? {
        switch kind {
        case "timeline":
            let moments: [String: GrammarTimeline] = ["repeated": .repeated, "now": .now, "past": .past,
                                                      "pastPeriod": .pastPeriod, "pastToNow": .pastToNow, "future": .future]
            return moment.flatMap { moments[$0] }.map(GrammarDiagram.timeline)
        case "place": return .place
        case "compare": return labels.map(GrammarDiagram.compare)
        case "flow": return labels.map(GrammarDiagram.flow)
        default: return nil
        }
    }
}

private struct GrammarLessonDTO: Decodable {
    let id: String
    let category: String
    let cefr: String
    let title: String
    let summary: String
    let use: String
    let form: String
    let examples: [GrammarExample]
    let commonMistake: String
    let diagram: GrammarDiagramDTO
    let diagramCaption: String
    let related: [String]
    let mistake: GrammarMistake
    let exercises: [GrammarExercise]

    var lesson: GrammarLesson? {
        guard let category = GrammarCategory(rawValue: category),
              let cefr = GrammarCEFR.allCases.first(where: { $0.label == cefr }),
              let diagram = diagram.diagram else { return nil }
        return GrammarLesson(id: id, category: category, cefr: cefr, title: title, summary: summary, use: use,
                             form: form, examples: examples, commonMistake: commonMistake, diagram: diagram,
                             diagramCaption: diagramCaption, related: related, mistake: mistake, exercises: exercises)
    }
}
