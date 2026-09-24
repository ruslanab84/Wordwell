enum GrammarLevel: Int, Comparable {
    case foundation, intermediate, advanced

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .foundation: "A1–A2"
        case .intermediate: "B1–B2"
        case .advanced: "C1"
        }
    }
}

enum GrammarCategory: String, CaseIterable, Identifiable {
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

    var id: String { rawValue }

    var summary: String {
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

    var overview: String {
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

    var symbol: String {
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

    var expectedLessonCount: Int {
        switch self {
        case .tenses: 12
        case .conditionals: 6
        case .modals: 5
        case .nouns: 10
        case .adjectives: 5
        case .prepositions: 4
        case .buildingSentences: 9
        case .verbPatterns: 4
        case .clauses: 5
        case .passiveReported: 5
        case .advanced: 5
        }
    }
}

enum GrammarTimeline {
    case repeated, now, past, pastPeriod, pastToNow, future
}

enum GrammarDiagram {
    case timeline(GrammarTimeline)
    case place
    case compare([String])
    case flow([String])

    var labels: [String] {
        switch self {
        case .timeline: ["Past", "Now", "Future"]
        case .place: ["In", "On", "Under"]
        case .compare(let labels), .flow(let labels): labels
        }
    }
}

struct GrammarExample {
    let sentence: String
    let meaning: String
}

struct GrammarLesson: Identifiable {
    let id: String
    let category: GrammarCategory
    let level: GrammarLevel
    let title: String
    let summary: String
    let use: String
    let form: String
    let examples: [GrammarExample]
    let commonMistake: String
    let diagram: GrammarDiagram
    let diagramCaption: String

    init(_ id: String, category: GrammarCategory, level: GrammarLevel, title: String,
         summary: String, use: String, form: String, examples: [(String, String)],
         commonMistake: String, diagram: GrammarDiagram, diagramCaption: String) {
        self.id = id
        self.category = category
        self.level = level
        self.title = title
        self.summary = summary
        self.use = use
        self.form = form
        self.examples = examples.map { GrammarExample(sentence: $0.0, meaning: $0.1) }
        self.commonMistake = commonMistake
        self.diagram = diagram
        self.diagramCaption = diagramCaption
    }
}

enum GrammarCatalog {
    static let all: [GrammarLesson] = {
        let lessons = tenses + conditionals + modals + nouns + adjectives + prepositions
            + buildingSentences + verbPatterns + clauses + passiveReported + advanced
        assert(lessons.count == 70 && Set(lessons.map(\.id)).count == lessons.count)
        assert(GrammarCategory.allCases.allSatisfy { category in
            let items = lessons.filter { $0.category == category }
            return items.count == category.expectedLessonCount
                && zip(items, items.dropFirst()).allSatisfy { $0.0.level <= $0.1.level }
        })
        assert(lessons.allSatisfy { lesson in
            !lesson.id.isEmpty && !lesson.title.isEmpty && !lesson.summary.isEmpty
                && !lesson.use.isEmpty && !lesson.form.isEmpty && !lesson.commonMistake.isEmpty
                && !lesson.diagramCaption.isEmpty && !lesson.diagram.labels.isEmpty
                && lesson.examples.count >= 2
                && lesson.examples.allSatisfy { !$0.sentence.isEmpty && !$0.meaning.isEmpty }
        })
        return lessons
    }()

    static func lessons(in category: GrammarCategory) -> [GrammarLesson] {
        all.filter { $0.category == category }
    }

    private static let tenses: [GrammarLesson] = [
        .init("present-simple", category: .tenses, level: .foundation, title: "Present Simple",
              summary: "Habits and things that are generally true",
              use: "Use it for routines, facts, and regular actions.",
              form: "I/you/we/they + verb · he/she/it + verb-s. For questions and negatives, use do or does + base verb.",
              examples: [("I walk to work every day.", "A regular habit"),
                         ("She doesn’t drink coffee.", "Doesn’t + base verb")],
              commonMistake: "After does or doesn’t, drop the -s: Does she work?",
              diagram: .timeline(.repeated), diagramCaption: "An action that repeats over time"),
        .init("present-continuous", category: .tenses, level: .foundation, title: "Present Continuous",
              summary: "Something happening now or around now",
              use: "Use it for an action in progress now or a temporary situation.",
              form: "am/is/are + verb-ing. For questions, put am/is/are before the subject.",
              examples: [("I’m reading a book now.", "Happening at this moment"),
                         ("They’re staying with friends this week.", "Temporary situation")],
              commonMistake: "Use Present Simple for routines: I read every evening.",
              diagram: .timeline(.now), diagramCaption: "An action in progress now"),
        .init("past-simple", category: .tenses, level: .foundation, title: "Past Simple",
              summary: "A finished action at a past time",
              use: "Use it when an event is complete and its time is in the past.",
              form: "Regular verbs: verb-ed. Irregular verbs: past form. Questions and negatives: did + base verb.",
              examples: [("We visited London last year.", "Finished at a known past time"),
                         ("Did you see the film?", "Did + base verb, not saw")],
              commonMistake: "After did or didn’t, use the base verb: She didn’t go.",
              diagram: .timeline(.past), diagramCaption: "A finished point before now"),
        .init("past-continuous", category: .tenses, level: .foundation, title: "Past Continuous",
              summary: "An action in progress in the past",
              use: "Use it for background activity or an action interrupted by another event.",
              form: "was/were + verb-ing.",
              examples: [("I was cooking when you called.", "The cooking was already in progress"),
                         ("They were walking at 6 pm.", "In progress at a past time")],
              commonMistake: "The shorter interrupting action often uses Past Simple.",
              diagram: .timeline(.pastPeriod), diagramCaption: "A stretch of time before now"),
        .init("future", category: .tenses, level: .foundation, title: "Talking about the future",
              summary: "Will, going to, and present arrangements",
              use: "Choose will for a decision made now or a prediction; going to for a plan or visible evidence; Present Continuous for a fixed arrangement.",
              form: "will + base verb · am/is/are going to + base verb · am/is/are + verb-ing.",
              examples: [("I’ll answer the phone.", "A decision made now"),
                         ("It’s going to rain.", "Evidence is visible"),
                         ("I’m meeting Ana tomorrow.", "An arranged meeting")],
              commonMistake: "After will and going to, use the base verb.",
              diagram: .timeline(.future), diagramCaption: "An event after now"),
        .init("present-perfect", category: .tenses, level: .intermediate, title: "Present Perfect",
              summary: "A past action connected to now",
              use: "Use it for experience or a past action whose result matters now. The exact past time is not stated.",
              form: "have/has + past participle.",
              examples: [("I’ve lost my keys.", "I don’t have them now"),
                         ("She has visited Japan.", "An experience; no exact time")],
              commonMistake: "With a finished time such as yesterday, use Past Simple: I lost them yesterday.",
              diagram: .timeline(.pastToNow), diagramCaption: "Something in the past with a link to now"),
        .init("present-perfect-continuous", category: .tenses, level: .intermediate,
              title: "Present Perfect Continuous", summary: "An activity continuing up to now",
              use: "Use it to stress the duration or recent activity behind a present result.",
              form: "have/has been + verb-ing; often with for or since.",
              examples: [("I’ve been studying for two hours.", "The activity began earlier and continues"),
                         ("She’s been painting; her hands are blue.", "Recent activity explains the result")],
              commonMistake: "Use for with a duration and since with a starting point, not the reverse.",
              diagram: .flow(["Started earlier", "Still happening or just stopped", "Result now"]),
              diagramCaption: "Activity over time with a present connection"),
        .init("past-perfect-simple", category: .tenses, level: .intermediate,
              title: "Past Perfect Simple", summary: "The earlier of two past events",
              use: "Use it to make clear that one past event happened before another.",
              form: "had + past participle.",
              examples: [("The train had left when we arrived.", "Leaving happened first"),
                         ("I had never flown before that trip.", "Experience before a past point")],
              commonMistake: "Do not use had with a past form: had went is wrong; had gone is right.",
              diagram: .flow(["Train left", "We arrived", "Now"]),
              diagramCaption: "One past action precedes another"),
        .init("past-perfect-continuous", category: .tenses, level: .intermediate,
              title: "Past Perfect Continuous", summary: "Duration before a past moment",
              use: "Use it to show how long an activity had been continuing before another past event.",
              form: "had been + verb-ing.",
              examples: [("We had been walking for hours when it rained.", "Walking continued before the rain"),
                         ("Her eyes were tired because she had been reading.", "Earlier activity explains a past result")],
              commonMistake: "Use had been, not have been, when both reference points are in the past.",
              diagram: .flow(["Activity starts", "Activity continues", "Past event"]),
              diagramCaption: "Ongoing activity before another past event"),
        .init("future-continuous", category: .tenses, level: .intermediate,
              title: "Future Continuous", summary: "In progress at a future time",
              use: "Use it for an activity expected to be underway at a specified future moment.",
              form: "will be + verb-ing.",
              examples: [("At nine, I’ll be working.", "Work will be in progress then"),
                         ("This time tomorrow, we’ll be flying.", "The flight will be underway")],
              commonMistake: "Do not leave out be: will working is wrong.",
              diagram: .flow(["Now", "Activity begins", "Future point during activity"]),
              diagramCaption: "A future point inside an ongoing action"),
        .init("future-perfect", category: .tenses, level: .intermediate,
              title: "Future Perfect", summary: "Finished before a future point",
              use: "Use it to say an action will be complete by a future deadline.",
              form: "will have + past participle; often with by.",
              examples: [("By Friday, I’ll have finished the report.", "Completion before Friday"),
                         ("They’ll have left by the time we arrive.", "Their departure comes first")],
              commonMistake: "After will have, use the past participle: will have written.",
              diagram: .flow(["Now", "Action completed", "Future deadline"]),
              diagramCaption: "Completion comes before a future deadline"),
        .init("past-habits", category: .tenses, level: .intermediate,
              title: "Past habits", summary: "Used to, would, and past routines",
              use: "Use used to for past habits or states that are no longer true. Would can describe repeated past actions, but usually not past states.",
              form: "used to + base verb · would + base verb · past simple.",
              examples: [("I used to live by the sea.", "A former state"),
                         ("Every summer, we would swim at dawn.", "A repeated past action")],
              commonMistake: "Do not use would for a former state: I would live there is not the same as I used to live there.",
              diagram: .compare(["used to: habits or states", "would: repeated actions"]),
              diagramCaption: "Used to and would have different ranges of meaning")
    ]

    private static let conditionals: [GrammarLesson] = [
        .init("zero-conditional", category: .conditionals, level: .foundation,
              title: "Zero Conditional", summary: "Results that generally follow",
              use: "Use it for general facts, instructions, and repeated results.",
              form: "If + present simple, present simple. When can replace if for a predictable result.",
              examples: [("If I skip breakfast, I get hungry early.", "A repeated result"),
                         ("When ice warms up, it melts.", "A general fact")],
              commonMistake: "Do not add will to the if-clause for a general fact.",
              diagram: .flow(["If this happens", "This usually happens"]),
              diagramCaption: "A general condition leads to a general result"),
        .init("first-conditional", category: .conditionals, level: .intermediate,
              title: "First Conditional", summary: "A realistic future possibility",
              use: "Use it for a possible future condition and its likely result. Unless means if not.",
              form: "If + present simple, will + base verb. The clauses can change order; add a comma when if comes first.",
              examples: [("If the bus is late, I’ll walk.", "A real future possibility"),
                         ("We’ll go outside unless it rains.", "Unless = if it does not rain")],
              commonMistake: "Use present, not will, after if: If it rains, we’ll stay in.",
              diagram: .flow(["If + present", "Possible future result"]),
              diagramCaption: "A realistic condition points to a future result"),
        .init("second-conditional", category: .conditionals, level: .intermediate,
              title: "Second Conditional", summary: "An imagined present or future",
              use: "Use it for a situation that is unlikely or not true now and imagine its result.",
              form: "If + past simple, would + base verb. Were is common with I/he/she/it in careful style.",
              examples: [("If I had more time, I’d learn Italian.", "I do not have enough time now"),
                         ("If she were here, she would know what to do.", "She is not here")],
              commonMistake: "Past form here expresses distance from reality, not necessarily past time.",
              diagram: .flow(["Imagined condition now", "Imagined result"]),
              diagramCaption: "An unreal or unlikely condition creates an imagined result"),
        .init("third-conditional", category: .conditionals, level: .intermediate,
              title: "Third Conditional", summary: "An alternative to a finished past",
              use: "Use it to imagine how a past result could have changed.",
              form: "If + past perfect, would have + past participle.",
              examples: [("If we had left earlier, we would have caught the train.", "We left late and missed it"),
                         ("She would have joined us if she had known.", "She did not know")],
              commonMistake: "Keep would out of the if-clause: If I had known, not if I would have known.",
              diagram: .flow(["Past event did not happen", "Imagine a different past result"]),
              diagramCaption: "Both the condition and result are imagined in the past"),
        .init("mixed-conditionals", category: .conditionals, level: .intermediate,
              title: "Mixed Conditionals", summary: "A past cause with a present result, or the reverse",
              use: "Use mixed forms when the imagined condition and result belong to different times.",
              form: "If + past perfect, would + base verb for a present result; if + past simple, would have + participle for a past result.",
              examples: [("If I had slept more, I wouldn’t be tired now.", "Past cause, present result"),
                         ("If she spoke French, she would have taken that job.", "Present ability, past result")],
              commonMistake: "Choose each verb form by its own time reference; do not force both clauses into the same time.",
              diagram: .compare(["Past condition → present result", "Present condition → past result"]),
              diagramCaption: "The two clauses can refer to different times"),
        .init("wish-if-only", category: .conditionals, level: .intermediate,
              title: "Wish and if only", summary: "Regret and desired change",
              use: "Use a past form for a present wish, past perfect for a past regret, and would for a change you want another person or situation to make.",
              form: "wish + past simple · wish + past perfect · wish + would + base verb.",
              examples: [("I wish I knew the answer.", "I do not know it now"),
                         ("If only we had booked earlier.", "We regret a past choice"),
                         ("I wish the noise would stop.", "I want the situation to change")],
              commonMistake: "Do not use wish + would for your own deliberate action: say I wish I could leave.",
              diagram: .compare(["wish + past: now", "wish + past perfect: past", "wish + would: change"]),
              diagramCaption: "Verb form shows whether the wish concerns now, the past, or change")
    ]

    private static let modals: [GrammarLesson] = [
        .init("ability-permission", category: .modals, level: .foundation,
              title: "Ability and permission", summary: "Can, could, and be able to",
              use: "Use can for present ability or informal permission; could can describe general past ability or make a polite request.",
              form: "can/could + base verb · be able to + base verb.",
              examples: [("My brother can swim well.", "Present ability"),
                         ("Could I borrow your pen?", "Polite permission request")],
              commonMistake: "Do not add to after can or could: can swim, not can to swim.",
              diagram: .compare(["can: now", "could: past or polite", "be able to: other forms"]),
              diagramCaption: "Different forms express ability and permission"),
        .init("obligation-advice", category: .modals, level: .foundation,
              title: "Obligation, prohibition, and advice", summary: "Must, have to, mustn’t, and should",
              use: "Use must/have to for necessity, mustn’t for prohibition, don’t have to for no necessity, and should for advice.",
              form: "modal + base verb · have to + base verb.",
              examples: [("You must wear a helmet here.", "It is required"),
                         ("You don’t have to come early.", "Coming early is optional"),
                         ("You mustn’t park here.", "Parking is forbidden")],
              commonMistake: "Mustn’t means forbidden; don’t have to means optional.",
              diagram: .compare(["must: required", "mustn’t: forbidden", "don’t have to: optional"]),
              diagramCaption: "Prohibition and lack of necessity are different"),
        .init("requests-offers", category: .modals, level: .intermediate,
              title: "Requests and offers", summary: "Could, would, shall, and may",
              use: "Choose a modal to make a request, offer help, or ask permission with the right degree of politeness.",
              form: "Could you + base verb? · Would you like + noun/to-infinitive? · Shall I + base verb?",
              examples: [("Could you close the window?", "A polite request"),
                         ("Shall I carry your bag?", "An offer of help")],
              commonMistake: "Would you like to help? asks about willingness; Shall I help? offers your help.",
              diagram: .compare(["Could you…? request", "Shall I…? offer", "May I…? permission"]),
              diagramCaption: "The subject and modal show who will act"),
        .init("possibility-deduction", category: .modals, level: .intermediate,
              title: "Possibility and deduction", summary: "How certain are you now?",
              use: "Use might/may/could for possibility, must for a strong positive deduction, and can’t for a strong negative one.",
              form: "modal + base verb; for an action happening now, modal + be + verb-ing.",
              examples: [("She might be at the library.", "Possible, not certain"),
                         ("The lights are on; they must be home.", "Strong evidence"),
                         ("He can’t be asleep; I can hear him talking.", "Evidence against it")],
              commonMistake: "Mustn’t expresses prohibition, not a negative deduction; use can’t be.",
              diagram: .compare(["might: possible", "must: very likely", "can’t: nearly impossible"]),
              diagramCaption: "Modal choice reflects the strength of evidence"),
        .init("past-deduction", category: .modals, level: .intermediate,
              title: "Deductions about the past", summary: "What probably happened?",
              use: "Use modal perfect forms to judge an earlier event from evidence you have now.",
              form: "must/might/could/can’t + have + past participle.",
              examples: [("The floor is wet; it must have rained.", "A strong past deduction"),
                         ("She might have missed the bus.", "One possible explanation"),
                         ("They can’t have left yet; their car is here.", "Evidence against departure")],
              commonMistake: "Use have + participle after the modal: might have gone, not might went.",
              diagram: .flow(["Evidence now", "Modal + have", "Conclusion about past"]),
              diagramCaption: "Present evidence supports a conclusion about the past")
    ]
    private static let nouns: [GrammarLesson] = [
        .init("countable-uncountable", category: .nouns, level: .foundation,
              title: "Countable and uncountable nouns", summary: "One, many, or an amount",
              use: "Countable nouns can have a singular and plural form. Uncountable nouns are normally treated as a mass.",
              form: "a/an + singular countable noun · some + plural or uncountable noun.",
              examples: [("I bought three oranges.", "Oranges can be counted"),
                         ("We need some rice.", "Rice is treated as an amount")],
              commonMistake: "Do not use a before an uncountable noun: say some advice, not an advice.",
              diagram: .compare(["one orange → three oranges", "some rice → an amount"]),
              diagramCaption: "Countable nouns take numbers; uncountable nouns name amounts"),
        .init("plurals-possessive", category: .nouns, level: .foundation,
              title: "Plurals and possessive ’s", summary: "More than one, and who owns it",
              use: "Use plural forms for more than one; use possessive ’s to connect a person or animal to something they have.",
              form: "one book → two books · child → children · Sara’s book · the students’ books.",
              examples: [("Two children are playing outside.", "Irregular plural"),
                         ("This is Maya’s jacket.", "The jacket belongs to Maya")],
              commonMistake: "Do not use an apostrophe for an ordinary plural: books, not book’s.",
              diagram: .compare(["books: plural", "Maya’s book: possession", "students’ books: plural possession"]),
              diagramCaption: "Plural -s and possessive apostrophes do different jobs"),
        .init("articles", category: .nouns, level: .foundation, title: "A, an, and the",
              summary: "Introducing and identifying a noun",
              use: "Use a/an for one non-specific countable thing; use the for something specific or already known.",
              form: "a + consonant sound · an + vowel sound · the + specific noun.",
              examples: [("I saw a dog.", "One dog, introduced for the first time"),
                         ("The dog was friendly.", "The same dog, now known"),
                         ("She ate an apple.", "An before a vowel sound")],
              commonMistake: "Choose a or an by sound: an hour, a university.",
              diagram: .compare(["a book", "an old book", "the book"]),
              diagramCaption: "A new thing becomes the known thing"),
        .init("zero-article", category: .nouns, level: .foundation,
              title: "The or no article", summary: "General things and named places",
              use: "Leave out an article when speaking generally about plural or uncountable nouns; use the when a specific group or item is clear.",
              form: "Books are useful. · The books on this shelf are mine.",
              examples: [("Music helps me focus.", "Music in general"),
                         ("The music next door is loud.", "Specific music")],
              commonMistake: "Do not add the before a general plural: Dogs need exercise.",
              diagram: .compare(["Music: general", "The music: specific"]),
              diagramCaption: "The narrows a general idea to a known one"),
        .init("demonstratives", category: .nouns, level: .foundation,
              title: "This, that, these, and those", summary: "Pointing to near and far things",
              use: "Use this/these for something near the speaker and that/those for something farther away.",
              form: "this/that + singular noun · these/those + plural noun.",
              examples: [("This chair is comfortable.", "One chair nearby"),
                         ("Those trees are very tall.", "Several trees farther away")],
              commonMistake: "Match number: these books, not this books.",
              diagram: .compare(["near: this / these", "far: that / those"]),
              diagramCaption: "Distance and number determine the demonstrative"),
        .init("quantifiers", category: .nouns, level: .foundation,
              title: "Quantifiers", summary: "Some, any, much, many, few, and little",
              use: "Choose quantity words according to whether the noun is countable and how much is meant.",
              form: "many/few + plural countable · much/little + uncountable · some/any + either type.",
              examples: [("There are a few seats left.", "A small but useful number"),
                         ("We have very little time.", "A small amount")],
              commonMistake: "Use many with countable plurals and much with uncountable nouns.",
              diagram: .compare(["many books / a few books", "much water / a little water"]),
              diagramCaption: "Quantity words depend on countability"),
        .init("subject-object-pronouns", category: .nouns, level: .foundation,
              title: "Subject and object pronouns", summary: "Who acts and who receives an action",
              use: "A subject pronoun usually comes before the verb; an object pronoun follows a verb or preposition.",
              form: "I/me · he/him · she/her · we/us · they/them.",
              examples: [("She called me yesterday.", "She acts; me receives the call"),
                         ("We sat beside them.", "Them follows a preposition")],
              commonMistake: "Use I as the subject and me as the object: He helped me.",
              diagram: .flow(["She", "called", "me"]),
              diagramCaption: "Subject, action, and object occupy different positions"),
        .init("possessive-reflexive-pronouns", category: .nouns, level: .foundation,
              title: "Possessive and reflexive pronouns", summary: "Ownership and action back to the subject",
              use: "Use possessive forms to show who owns something and reflexive forms when the object refers back to the subject.",
              form: "my book → mine · her book → hers · she → herself.",
              examples: [("That red bag is mine.", "Mine replaces my bag"),
                         ("He taught himself to cook.", "He and himself refer to one person")],
              commonMistake: "A possessive pronoun stands alone: mine, not mine book.",
              diagram: .compare(["my bag → mine", "he taught → himself"]),
              diagramCaption: "One form shows ownership; another points back to the subject"),
        .init("indefinite-pronouns", category: .nouns, level: .intermediate,
              title: "Indefinite pronouns", summary: "Someone, anything, nobody, and more",
              use: "Use these pronouns when a person or thing is not named or not known.",
              form: "some-/any-/no-/every- + one/body/thing/where.",
              examples: [("Someone left a note for you.", "The person is not identified"),
                         ("I didn’t see anyone outside.", "Any person in a negative sentence")],
              commonMistake: "Avoid a second negative in standard English: I didn’t see anyone, not I didn’t see nobody.",
              diagram: .compare(["someone: an unspecified person", "anyone: open choice", "no one: zero people"]),
              diagramCaption: "Prefixes change how definite the reference is"),
        .init("noun-modifiers", category: .nouns, level: .advanced,
              title: "Noun modifiers", summary: "Nouns that describe other nouns",
              use: "Put a noun before another noun to classify it; the final noun names the main thing.",
              form: "modifier noun + head noun; a longer phrase may contain several modifiers.",
              examples: [("She bought a train ticket.", "A ticket for a train"),
                         ("The city transport plan changed.", "The plan is the main noun")],
              commonMistake: "The modifier normally stays singular: shoe shop, not shoes shop.",
              diagram: .flow(["city", "transport", "plan: main noun"]),
              diagramCaption: "The last noun is the head; earlier nouns narrow its meaning")
    ]

    private static let adjectives: [GrammarLesson] = [
        .init("ed-ing-adjectives", category: .adjectives, level: .foundation,
              title: "-ed and -ing adjectives", summary: "A feeling or what causes it",
              use: "Use -ed to describe how someone feels and -ing to describe the thing that produces that feeling.",
              form: "interested person · interesting subject.",
              examples: [("I’m bored by this film.", "My feeling"),
                         ("The film is boring.", "What causes the feeling")],
              commonMistake: "I am boring means I make others bored; use I am bored for your feeling.",
              diagram: .flow(["boring film", "makes me feel", "bored"]),
              diagramCaption: "The -ing thing causes the -ed feeling"),
        .init("adverbs", category: .adjectives, level: .foundation,
              title: "Adverbs of manner and frequency", summary: "How and how often",
              use: "Manner adverbs describe an action; frequency adverbs say how regularly it happens.",
              form: "verb + manner adverb · frequency adverb before a main verb, but after be.",
              examples: [("She spoke quietly.", "How she spoke"),
                         ("We usually eat at home.", "How often we do it")],
              commonMistake: "With be, put a frequency adverb after be: She is often late.",
              diagram: .compare(["quietly: how", "usually: how often"]),
              diagramCaption: "Different adverbs answer different questions"),
        .init("comparisons", category: .adjectives, level: .foundation,
              title: "Comparatives and superlatives", summary: "Comparing two or more things",
              use: "Use a comparative for two things and a superlative to identify one at an extreme within a group.",
              form: "-er / more + adjective + than · the -est / the most + adjective · as + adjective + as.",
              examples: [("This route is shorter than the old one.", "A comparison of two routes"),
                         ("It is the quietest room here.", "One room among several")],
              commonMistake: "Do not double the comparison: more easier is wrong; easier is enough.",
              diagram: .compare(["shorter than: two", "the shortest: a group", "as short as: equal"]),
              diagramCaption: "Comparison form depends on what is being compared"),
        .init("adjective-order", category: .adjectives, level: .intermediate,
              title: "Adjective order", summary: "Putting descriptions before a noun",
              use: "When several adjectives come before a noun, opinion usually comes before size, age, colour, origin, and material.",
              form: "opinion → size → age → colour → origin/material → noun.",
              examples: [("She found a beautiful old wooden table.", "Opinion, age, material"),
                         ("He bought a small blue bag.", "Size before colour")],
              commonMistake: "Do not force a long adjective chain; two clear adjectives often sound more natural.",
              diagram: .flow(["beautiful", "old", "wooden table"]),
              diagramCaption: "Typical adjective order moves from opinion toward type"),
        .init("degree-intensifiers", category: .adjectives, level: .intermediate,
              title: "Degree, too, and enough", summary: "Strengthening or limiting a description",
              use: "Use intensifiers to change degree, too for more than is acceptable, and enough for a sufficient amount.",
              form: "very + adjective · too + adjective · adjective + enough · enough + noun.",
              examples: [("The tea is too hot to drink.", "Excessive heat"),
                         ("The room is warm enough.", "Sufficient warmth")],
              commonMistake: "Enough follows an adjective but precedes a noun: warm enough; enough space.",
              diagram: .compare(["not warm enough", "warm enough", "too hot"]),
              diagramCaption: "Enough marks a useful threshold; too goes beyond it")
    ]
    private static let prepositions: [GrammarLesson] = [
        .init("place", category: .prepositions, level: .foundation,
              title: "Prepositions of place", summary: "In, on, and under",
              use: "In means inside; on means touching a surface; under means below something.",
              form: "preposition + place or object.",
              examples: [("The ball is in the box.", "Inside the box"),
                         ("The ball is on the box.", "Touching the top"),
                         ("The ball is under the box.", "Below the box")],
              commonMistake: "Say on the table for something resting on its surface.",
              diagram: .place, diagramCaption: "The ball is in, on, or under the box"),
        .init("time", category: .prepositions, level: .foundation,
              title: "Prepositions of time", summary: "At, on, and in",
              use: "Use at for a clock time, on for a day or date, and in for a month, year, season, or long period.",
              form: "at + time · on + day/date · in + month/year/season.",
              examples: [("The class starts at 8:00.", "A precise time"),
                         ("We meet on Monday.", "A day"),
                         ("My birthday is in July.", "A month")],
              commonMistake: "Say in the morning, but at night.",
              diagram: .compare(["at 8:00", "on Monday", "in July"]),
              diagramCaption: "At points to a time, on to a day, and in to a longer period"),
        .init("movement-prepositions", category: .prepositions, level: .foundation,
              title: "Prepositions of movement", summary: "To, into, onto, through, and across",
              use: "Choose a preposition that shows the direction or path of movement.",
              form: "move + to a destination · into a space · onto a surface · through an interior · across an area.",
              examples: [("She walked into the room.", "Movement from outside to inside"),
                         ("We ran across the field.", "Movement from one side to the other")],
              commonMistake: "Use in for position and into for movement toward the inside.",
              diagram: .flow(["outside", "into", "inside"]),
              diagramCaption: "Into describes a change of position"),
        .init("dependent-prepositions", category: .prepositions, level: .intermediate,
              title: "Dependent prepositions", summary: "Words that regularly pair with a preposition",
              use: "Many adjectives and verbs take a particular preposition. Learn the pair as one phrase.",
              form: "interested in · depend on · listen to · proud of.",
              examples: [("I’m interested in astronomy.", "Interested pairs with in"),
                         ("The result depends on the weather.", "Depend pairs with on")],
              commonMistake: "Do not translate the preposition word for word from another language.",
              diagram: .compare(["interested → in", "depend → on", "listen → to"]),
              diagramCaption: "The main word selects its usual preposition")
    ]

    private static let buildingSentences: [GrammarLesson] = [
        .init("basic-word-order", category: .buildingSentences, level: .foundation,
              title: "Basic word order", summary: "Subject, verb, and object",
              use: "In a basic statement, say who or what acts, then the action, then its object if there is one.",
              form: "subject + verb + object/complement.",
              examples: [("Mina reads novels.", "Subject, verb, object"),
                         ("The garden looks beautiful.", "Subject, verb, complement")],
              commonMistake: "Do not normally omit a subject in an English statement: It is raining.",
              diagram: .flow(["Mina: subject", "reads: verb", "novels: object"]),
              diagramCaption: "A basic English statement moves from subject to verb to object"),
        .init("be-have-got", category: .buildingSentences, level: .foundation,
              title: "Be and have got", summary: "Identity, state, and possession",
              use: "Use be for identity or state and have/have got for possession. Have got is especially common in conversation.",
              form: "I am / she is / they are · I have / she has · I’ve got / she’s got.",
              examples: [("She is a doctor.", "Identity"),
                         ("We’ve got two tickets.", "Possession")],
              commonMistake: "Do not use do with have got: Have you got a pen?",
              diagram: .compare(["be → identity or state", "have (got) → possession"]),
              diagramCaption: "Be and have got answer different questions"),
        .init("there-is-are", category: .buildingSentences, level: .foundation,
              title: "There is and there are", summary: "Saying that something exists",
              use: "Use there is to introduce one thing or an uncountable amount, and there are for plural things.",
              form: "there is + singular/uncountable · there are + plural.",
              examples: [("There is a café nearby.", "One café exists there"),
                         ("There are three windows.", "Several windows exist")],
              commonMistake: "Match the verb to what follows: There are two chairs, not there is two chairs.",
              diagram: .compare(["one → there is", "many → there are"]),
              diagramCaption: "The noun that follows determines is or are"),
        .init("questions", category: .buildingSentences, level: .foundation,
              title: "Question forms", summary: "Yes–no and information questions",
              use: "Put an auxiliary before the subject in most questions; add a question word when asking for specific information.",
              form: "auxiliary + subject + base verb? · question word + auxiliary + subject + base verb?",
              examples: [("Do they live nearby?", "A yes–no question"),
                         ("Where did you find it?", "An information question")],
              commonMistake: "After did, use the base verb: Where did she go?, not did she went?",
              diagram: .flow(["Where", "did you", "find it?"] ),
              diagramCaption: "Question word and auxiliary come before the main verb"),
        .init("negatives", category: .buildingSentences, level: .foundation,
              title: "Negatives and auxiliaries", summary: "Saying that something is not true",
              use: "Add not to an auxiliary or be. Use do/does/did when a simple-tense statement has no other auxiliary.",
              form: "am/is/are not · do/does/did not + base verb · modal + not + base verb.",
              examples: [("He doesn’t work on Sundays.", "Present Simple negative"),
                         ("We haven’t finished yet.", "Negative after have")],
              commonMistake: "Do not use two finite auxiliaries: She doesn’t can go is wrong; She can’t go is right.",
              diagram: .flow(["subject", "auxiliary + not", "main verb"]),
              diagramCaption: "The negative attaches to an auxiliary"),
        .init("imperatives-exclamations", category: .buildingSentences, level: .foundation,
              title: "Imperatives and exclamations", summary: "Instructions and strong reactions",
              use: "Use a base verb for an instruction; use what or how to express a strong reaction.",
              form: "base verb + rest · don’t + base verb · what + (a/an) + noun! · how + adjective/adverb!",
              examples: [("Please close the door.", "A polite instruction"),
                         ("What a lovely view!", "An exclamation about a noun")],
              commonMistake: "Use a before a singular countable noun after what: What a surprise!",
              diagram: .compare(["Close the door: instruction", "What a view!: reaction"]),
              diagramCaption: "Different sentence shapes express instructions and reactions"),
        .init("subject-verb-agreement", category: .buildingSentences, level: .intermediate,
              title: "Subject–verb agreement", summary: "Matching the verb to the subject",
              use: "The verb agrees with the grammatical subject, even if other words appear between them.",
              form: "singular subject + singular verb · plural subject + plural verb.",
              examples: [("The list of names is long.", "List is the singular subject"),
                         ("The players on the team are ready.", "Players is the plural subject")],
              commonMistake: "Do not match the verb to the nearest noun: The box of pencils is here.",
              diagram: .flow(["The list", "of names", "is long"]),
              diagramCaption: "The head of the subject controls the verb"),
        .init("question-tags", category: .buildingSentences, level: .intermediate,
              title: "Question tags", summary: "Checking or inviting agreement",
              use: "Add a short question after a statement to check information or invite a response.",
              form: "positive statement + negative tag · negative statement + positive tag.",
              examples: [("You’re coming, aren’t you?", "Positive statement, negative tag"),
                         ("She hasn’t left, has she?", "Negative statement, positive tag")],
              commonMistake: "Repeat the matching auxiliary in the tag: He can swim, can’t he?",
              diagram: .compare(["positive → negative tag", "negative → positive tag"]),
              diagramCaption: "The tag usually reverses the statement’s polarity"),
        .init("writing-conventions", category: .buildingSentences, level: .intermediate,
              title: "Capital letters and punctuation", summary: "Clear written sentences",
              use: "Start a sentence and proper name with a capital letter; use punctuation to mark endings, questions, and possession.",
              form: "Capital + sentence · ? for a direct question · ’ for possession/contraction.",
              examples: [("Is Daniel’s bike outside?", "Capital, possessive apostrophe, question mark"),
                         ("We’re meeting on Tuesday.", "Contraction and capitalised day")],
              commonMistake: "Its is possessive; it’s means it is or it has.",
              diagram: .compare(["its colour: possession", "it’s blue: it is"]),
              diagramCaption: "An apostrophe can change the meaning of it’s")
    ]
    private static let verbPatterns: [GrammarLesson] = [
        .init("infinitive-purpose", category: .verbPatterns, level: .foundation,
              title: "Infinitive of purpose", summary: "Saying why you do something",
              use: "Use to + base verb to explain the purpose of an action.",
              form: "main action + to + base verb.",
              examples: [("I called to ask a question.", "The reason for calling"),
                         ("She went outside to get some air.", "The reason for going outside")],
              commonMistake: "Do not use for + base verb to express purpose: say to ask, not for ask.",
              diagram: .flow(["action", "to + verb", "purpose"]),
              diagramCaption: "The infinitive explains the purpose of the first action"),
        .init("gerund-infinitive", category: .verbPatterns, level: .intermediate,
              title: "-ing forms and infinitives", summary: "Choosing what follows a verb",
              use: "Some verbs take an -ing form, some take to + verb, and some allow both with a change in meaning.",
              form: "enjoy + verb-ing · decide + to-infinitive · stop + verb-ing / to-infinitive.",
              examples: [("We enjoy hiking.", "Enjoy takes an -ing form"),
                         ("She decided to leave.", "Decide takes a to-infinitive"),
                         ("He stopped to rest.", "He paused another action in order to rest")],
              commonMistake: "Stop doing means end an action; stop to do means pause for another purpose.",
              diagram: .compare(["enjoy → doing", "decide → to do", "stop doing ≠ stop to do"]),
              diagramCaption: "The first verb determines the next verb form"),
        .init("phrasal-verbs", category: .verbPatterns, level: .intermediate,
              title: "Phrasal verbs", summary: "A verb plus a particle",
              use: "A particle can change a verb’s meaning. With a separable phrasal verb, a pronoun object goes between the verb and particle.",
              form: "turn on the light / turn the light on · turn it on · look after someone.",
              examples: [("Please turn the lamp off.", "Off completes a separable phrasal verb"),
                         ("Can you look after my cat?", "Look after means care for")],
              commonMistake: "Say turn it off, not turn off it. Look after is not separated.",
              diagram: .compare(["turn it off: separable", "look after it: inseparable"]),
              diagramCaption: "Object position depends on the phrasal verb"),
        .init("stative-verbs", category: .verbPatterns, level: .intermediate,
              title: "Stative verbs", summary: "States and actions",
              use: "Verbs of belief, possession, and feeling often describe a state and usually use a simple form; some change meaning in a continuous form.",
              form: "I know the answer. · I’m thinking about it.",
              examples: [("I believe you.", "A belief, normally simple"),
                         ("She’s having lunch.", "Have means eat here, an action")],
              commonMistake: "I’m knowing is not the usual form for a state; say I know.",
              diagram: .compare(["know: state → simple", "have lunch: action → continuous"]),
              diagramCaption: "Meaning determines whether a continuous form is natural")
    ]

    private static let clauses: [GrammarLesson] = [
        .init("linking-ideas", category: .clauses, level: .foundation,
              title: "Reason, result, and contrast", summary: "Because, so, although, and despite",
              use: "Join ideas by showing why something happened, what followed, or how two facts contrast.",
              form: "because + clause · so + result clause · although + clause · despite + noun/-ing.",
              examples: [("We stayed inside because it was cold.", "A reason"),
                         ("Although it was cold, we went out.", "A contrast"),
                         ("Despite the rain, we walked.", "Contrast before a noun")],
              commonMistake: "Use despite + noun or -ing, not despite + full clause without the fact that.",
              diagram: .compare(["because → reason", "so → result", "although/despite → contrast"]),
              diagramCaption: "Linking words tell the reader how ideas relate"),
        .init("time-clauses", category: .clauses, level: .intermediate,
              title: "Time clauses", summary: "When, before, after, and until",
              use: "Use a time clause to place one event in relation to another. A future meaning normally takes a present verb after when or until.",
              form: "when/before/after/until + clause, main clause.",
              examples: [("I’ll call when I arrive.", "The arrival is in the future"),
                         ("Wait until the rain stops.", "The waiting ends then")],
              commonMistake: "Do not normally use will in the future time clause: when I arrive, not when I will arrive.",
              diagram: .flow(["Arrive", "Then call"]),
              diagramCaption: "The time clause places one event before another"),
        .init("defining-relatives", category: .clauses, level: .intermediate,
              title: "Defining relative clauses", summary: "Identifying which person or thing",
              use: "Add essential information that identifies the noun. Who refers to people; which to things; that can refer to either in this kind of clause.",
              form: "noun + who/which/that + defining clause; no separating commas.",
              examples: [("The woman who lives upstairs is a nurse.", "Identifies the woman"),
                         ("I found the book that you wanted.", "Identifies the book")],
              commonMistake: "Do not put commas around information needed to identify the noun.",
              diagram: .flow(["the woman", "who lives upstairs", "is a nurse"]),
              diagramCaption: "The relative clause identifies which woman is meant"),
        .init("nondefining-relatives", category: .clauses, level: .intermediate,
              title: "Non-defining relative clauses", summary: "Adding extra information",
              use: "Add information about a noun already identified; the sentence still identifies it if the clause is removed.",
              form: "known noun, who/which/whose + extra clause, rest of sentence.",
              examples: [("My aunt, who lives in Cork, is visiting.", "The location is extra information"),
                         ("The museum, which opened last year, is free.", "Opening date is extra information")],
              commonMistake: "Do not use that in a non-defining relative clause; use who or which.",
              diagram: .flow(["known noun", ", extra information,", "main idea continues"]),
              diagramCaption: "Commas mark information that can be removed"),
        .init("participle-clauses", category: .clauses, level: .advanced,
              title: "Participle clauses", summary: "Adding information more compactly",
              use: "Use an -ing or past-participle clause to link related actions or states, usually with the same understood subject as the main clause.",
              form: "verb-ing clause, main clause · past participle clause, main clause.",
              examples: [("Walking home, I noticed a new café.", "I was walking and I noticed it"),
                         ("Built in 1900, the bridge still stands.", "The bridge was built then")],
              commonMistake: "Keep the understood subject clear: Walking home, the café caught my eye wrongly makes the café the walker.",
              diagram: .flow(["same subject", "shortened clause", "main clause"]),
              diagramCaption: "The participle clause shares its subject with the main clause")
    ]
    private static let passiveReported: [GrammarLesson] = [
        .init("passive-basics", category: .passiveReported, level: .intermediate,
              title: "The passive voice", summary: "Focusing on the action or receiver",
              use: "Use the passive when the action or its receiver matters more than who did it, or when the actor is unknown.",
              form: "be in the needed tense + past participle; optional by + actor.",
              examples: [("The window was broken last night.", "The actor is unknown"),
                         ("The invitations are sent by email.", "The process matters")],
              commonMistake: "Keep the tense on be: is built (present), was built (past).",
              diagram: .flow(["active object", "be + participle", "passive subject"]),
              diagramCaption: "The receiver of the action becomes the subject"),
        .init("reported-statements", category: .passiveReported, level: .intermediate,
              title: "Reported statements", summary: "Retelling what someone said",
              use: "Report another person’s statement. When the reporting verb is in the past, verb forms often shift back if the situation is viewed from that past point.",
              form: "said (that) + reported clause · told + person + (that) + reported clause.",
              examples: [("‘I’m tired,’ Lea said. → Lea said she was tired.", "Pronoun and tense shift"),
                         ("He told us he had already eaten.", "An earlier event is reported")],
              commonMistake: "When a that-clause follows told, name the listener: She told me that she was tired.",
              diagram: .flow(["original speaker", "said / told someone", "reported clause"]),
              diagramCaption: "A report changes viewpoint from the original speaker"),
        .init("reported-questions-commands", category: .passiveReported, level: .intermediate,
              title: "Reported questions and commands", summary: "Retelling a question or instruction",
              use: "Report a question with statement word order; report an instruction with told/asked + person + to-infinitive.",
              form: "asked + if/whether or question word + subject + verb · told + person + to + verb.",
              examples: [("‘Where are you?’ → She asked where I was.", "Reported question word order"),
                         ("‘Please wait.’ → He asked us to wait.", "Reported request")],
              commonMistake: "Do not keep question inversion: asked where I was, not asked where was I.",
              diagram: .compare(["direct: Where are you?", "reported: where I was"]),
              diagramCaption: "Reported questions use statement word order"),
        .init("advanced-passive", category: .passiveReported, level: .advanced,
              title: "Advanced passive forms", summary: "Reporting and multi-word passive patterns",
              use: "Use passive infinitives, continuous forms, and reporting patterns when the action or claim is more important than its actor.",
              form: "to be + participle · being + participle · it is said that / subject is said to.",
              examples: [("The bridge is being repaired.", "An ongoing passive action"),
                         ("The artist is said to live abroad.", "A reported claim with passive reporting")],
              commonMistake: "Do not drop being from an ongoing passive: is being repaired.",
              diagram: .compare(["is repaired: general", "is being repaired: now", "is said to: report"]),
              diagramCaption: "The auxiliary pattern changes passive meaning"),
        .init("reporting-verbs", category: .passiveReported, level: .advanced,
              title: "Reporting verb patterns", summary: "Advise, deny, promise, and insist",
              use: "Choose the complement pattern required by the reporting verb; different verbs take a person, an -ing form, an infinitive, or a that-clause.",
              form: "advise + person + to + verb · deny + verb-ing · promise + to + verb · insist + that-clause.",
              examples: [("She advised me to rest.", "Advice directed at a person"),
                         ("He denied taking the keys.", "Deny followed by -ing")],
              commonMistake: "Do not use one pattern for every reporting verb: deny doing, not deny to do.",
              diagram: .compare(["advise → person + to", "deny → -ing", "promise → to"]),
              diagramCaption: "Each reporting verb selects its own complement pattern")
    ]

    private static let advanced: [GrammarLesson] = [
        .init("negative-inversion", category: .advanced, level: .advanced,
              title: "Inversion after negative adverbials", summary: "Formal emphasis with reversed word order",
              use: "Place a negative or restrictive adverbial first to add emphasis, then put the auxiliary before the subject.",
              form: "negative adverbial + auxiliary + subject + main verb.",
              examples: [("Never had I heard such silence.", "Never is emphasised"),
                         ("Only later did we understand why.", "Understanding came later")],
              commonMistake: "Invert the auxiliary, not the main verb: Never have I seen, not Never seen I.",
              diagram: .flow(["Never", "have I", "seen this"]),
              diagramCaption: "Fronting a negative expression moves the auxiliary before the subject"),
        .init("conditional-inversion", category: .advanced, level: .advanced,
              title: "Inversion in conditionals", summary: "Formal alternatives without if",
              use: "In formal style, omit if and put had, were, or should before the subject.",
              form: "Had + subject + participle · Were + subject + complement/to-infinitive · Should + subject + base verb.",
              examples: [("Had I known, I would have called.", "If I had known"),
                         ("Should you need help, contact us.", "If you need help")],
              commonMistake: "Do not keep if after inversion: Had I known, not If had I known.",
              diagram: .compare(["If I had known", "Had I known"]),
              diagramCaption: "Formal inversion replaces if in the condition"),
        .init("cleft-sentences", category: .advanced, level: .advanced,
              title: "Cleft sentences", summary: "Putting one part in focus",
              use: "Use a cleft structure to highlight a person, time, place, or reason rather than present every part equally.",
              form: "It is/was + focus + that/who + clause · What + clause + is/was + focus.",
              examples: [("It was Nia who found the key.", "Nia is the focus"),
                         ("What I need is a quiet hour.", "A quiet hour is the focus")],
              commonMistake: "Do not add a second subject: It was Nia who found it, not It was Nia who she found it.",
              diagram: .flow(["It was", "Nia: focus", "who found the key"]),
              diagramCaption: "A cleft sentence places one element in focus"),
        .init("ellipsis-substitution", category: .advanced, level: .advanced,
              title: "Ellipsis and substitution", summary: "Avoiding needless repetition",
              use: "Omit words that are clear from context or replace them with a short form such as one, so, or an auxiliary.",
              form: "full idea → recoverable gap or substitute word.",
              examples: [("I ordered tea, and Noor did too.", "Did replaces ordered tea"),
                         ("Need a charger? I have one.", "One replaces a charger")],
              commonMistake: "Only omit words when the listener can identify what is missing.",
              diagram: .compare(["ordered tea → did too", "a charger → one"]),
              diagramCaption: "A shorter form points back to a known idea"),
        .init("unreal-time", category: .advanced, level: .advanced,
              title: "Unreal time", summary: "Past forms for present wishes and preferences",
              use: "Use a past form after expressions such as it’s time or I’d rather to show that the idea is unreal, preferred, or overdue now.",
              form: "It’s time + subject + past simple · I’d rather + subject + past simple.",
              examples: [("It’s time we left.", "Leaving is due now"),
                         ("I’d rather you stayed.", "I prefer you to stay now")],
              commonMistake: "The past form does not mean past time here; it shows distance from the current reality.",
              diagram: .flow(["past verb form", "unreal meaning", "present situation"]),
              diagramCaption: "A past form can express an unreal present preference")
    ]
}
