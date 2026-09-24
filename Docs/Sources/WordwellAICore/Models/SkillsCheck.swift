import Foundation

public struct SkillsCheckPack: Sendable {
    public let id = "original-1"
    public let reading: ExamReadingSet
    public let listening: ExamReadingSet
    public let writing: ExamWritingTask
    public let speaking: ExamSpeakingTask

    public static let standard = SkillsCheckPack()

    private init() {
        reading = ExamReadingSet(title: "The shared garden", passage: """
        At the edge of the town of Bellmere, an unused parking area became a shared garden. The idea began when a group of neighbours noticed that rainwater collected there after every storm. They asked the town council for permission to replace part of the hard surface with soil and plants. The council agreed to a two-year trial, provided the paths stayed open to everyone.

        The first summer was difficult. Most volunteers knew little about growing food, and a long dry spell damaged several beds. A retired gardener named Mara offered a free workshop every Saturday. She showed the group how to cover the soil with leaves to keep it cool and moist. By autumn, the volunteers had harvested enough vegetables to fill twenty small baskets.

        The garden is now used for more than growing food. Local students measure rainfall there for a science project, and neighbours meet beside a long wooden table. Anyone can take a basket of vegetables, but visitors are invited to help with a simple task, such as watering or sweeping a path. The council will decide whether to extend the trial next spring. Until then, the volunteers keep a notebook of harvests, repairs, and visitor comments to show how the space is used.
        """, questions: [
            ReadingQuestion(id: 1, statement: "The site used to be a parking area.", answer: .agrees, evidence: "an unused parking area"),
            ReadingQuestion(id: 2, statement: "The council permanently gave the land to the neighbours.", answer: .contradicts, evidence: "The council agreed to a two-year trial"),
            ReadingQuestion(id: 3, statement: "Mara charges visitors for her workshops.", answer: .contradicts, evidence: "a free workshop every Saturday"),
            ReadingQuestion(id: 4, statement: "Students use the garden to study rainfall.", answer: .agrees, evidence: "Local students measure rainfall there for a science project"),
            ReadingQuestion(id: 5, statement: "The garden opens at eight in the morning.", answer: .notStated, evidence: nil),
        ])

        listening = ExamReadingSet(title: "A library workshop", passage: """
        Hello, and welcome to the Bellmere Library workshop on repairing everyday objects. I'm Nia, and I'll guide you through today's session. We will begin at ten with a short demonstration in the main room. After that, you can visit one of three tables: clothing, small furniture, or bicycles. Please choose only one table before lunch, so that everyone has enough time with a volunteer.

        We have basic tools here, but you should bring the object you want to repair. If a part is missing, a volunteer can help you write down what to look for later. We cannot sell replacement parts at the library. There is no charge for the workshop, and you do not need to register in advance.

        At half past twelve, we will stop for a break. You may bring your own lunch or buy something from the café across the square. The afternoon session starts at one and ends at three. Before you leave, please return any borrowed tools to the blue box by the door. Next month, we hope to add a table for lamps, but that plan is not confirmed yet. Thank you for coming, and let's get started.
        """, questions: [
            ReadingQuestion(id: 1, statement: "The first demonstration begins at ten.", answer: .agrees, evidence: "We will begin at ten"),
            ReadingQuestion(id: 2, statement: "Visitors should move between all three tables before lunch.", answer: .contradicts, evidence: "Please choose only one table before lunch"),
            ReadingQuestion(id: 3, statement: "Replacement parts can be bought at the library.", answer: .contradicts, evidence: "We cannot sell replacement parts at the library"),
            ReadingQuestion(id: 4, statement: "The afternoon session lasts two hours.", answer: .agrees, evidence: "The afternoon session starts at one and ends at three"),
            ReadingQuestion(id: 5, statement: "The café offers a discount to workshop visitors.", answer: .notStated, evidence: nil),
        ])

        writing = ExamWritingTask(kind: .dataDescription,
            prompt: "Describe the main changes in the fictional town library's weekly visits. Compare the three years and include the most noticeable differences.",
            data: DataTable(title: "Weekly visits to Bellmere Library", unit: "visits",
                columns: ["Year 1", "Year 2", "Year 3"], rows: [
                    .init(label: "Children's room", values: [120, 150, 180]),
                    .init(label: "Study space", values: [200, 190, 210]),
                    .init(label: "Events", values: [60, 90, 130]),
                    .init(label: "Borrowing desk", values: [240, 220, 200]),
                ]))

        speaking = ExamSpeakingTask(part: .longTurn, topic: "A place where people learn together", prompts: [
            "Describe the place and where it is.",
            "Explain what people can learn there.",
            "Say who you would visit it with.",
            "Explain why you think it is useful.",
        ])
    }

    public func validate(policy: RestrictedTermsPolicy) throws {
        let validator = ExamValidator(policy: policy)
        guard reading.questions.count == 5, listening.questions.count == 5 else {
            throw AIError.invalidResponse("skills check requires five questions per section")
        }
        guard try validator.validate(reading, questionCount: 5).questions.count == 5,
              try validator.validate(listening, questionCount: 5).questions.count == 5 else {
            throw AIError.invalidResponse("skills check questions need grounded answers")
        }
        _ = try validator.validate(writing)
        _ = try validator.validate(speaking)
    }

    public func score(_ answers: [ReadingAnswer?], for set: ExamReadingSet) -> Int {
        zip(answers, set.questions).filter { $0.0 == $0.1.answer }.count
    }
}

public struct SkillsCheckDraft: Codable, Sendable, Equatable {
    public let id: UUID
    public let packID: String
    public var section: Int
    public var readingAnswers: [ReadingAnswer?]
    public var listeningAnswers: [ReadingAnswer?]
    public var writingText: String
    public var listeningUnavailable: Bool
    public var elapsedSeconds: [Int]

    public init(pack: SkillsCheckPack = .standard) {
        id = UUID()
        packID = pack.id
        section = 0
        readingAnswers = Array(repeating: nil, count: pack.reading.questions.count)
        listeningAnswers = Array(repeating: nil, count: pack.listening.questions.count)
        writingText = ""
        listeningUnavailable = false
        elapsedSeconds = [0, 0, 0, 0]
    }

    public func isValid(for pack: SkillsCheckPack) -> Bool {
        packID == pack.id && (0...3).contains(section)
            && readingAnswers.count == pack.reading.questions.count
            && listeningAnswers.count == pack.listening.questions.count
            && elapsedSeconds.count == 4 && elapsedSeconds.allSatisfy { $0 >= 0 }
    }
}

public struct SkillsCheckDraftStore {
    private let defaults: UserDefaults
    private let key = "wordwell.skillsCheck.draft"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load(pack: SkillsCheckPack = .standard) -> SkillsCheckDraft? {
        guard let data = defaults.data(forKey: key),
              let draft = try? JSONDecoder().decode(SkillsCheckDraft.self, from: data),
              draft.isValid(for: pack) else { return nil }
        return draft
    }

    public func save(_ draft: SkillsCheckDraft) {
        if let data = try? JSONEncoder().encode(draft) { defaults.set(data, forKey: key) }
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}
