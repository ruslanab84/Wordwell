import XCTest
@testable import WordwellAICore

// MARK: - Shared stubs

private actor Sequencer<T: Sendable> {
    private let items: [T]
    private var index = 0
    init(_ items: [T]) { self.items = items }
    func next() -> T {
        defer { index += 1 }
        return items[min(index, items.count - 1)]
    }
    var calls: Int { index }
}

private enum Words {
    static let borrow = AIWordContext(lemma: "borrow", partOfSpeech: "verb", cefrLevel: .a2,
                                      senses: [.init(id: "s1", definition: "to take something and give it back later")],
                                      forms: ["borrows", "borrowed", "borrowing"])
    static let lend = AIWordContext(lemma: "lend", partOfSpeech: "verb", cefrLevel: .a2,
                                    senses: [.init(id: "s1", definition: "to give something to someone for a short time")],
                                    forms: ["lends", "lent", "lending"])
    static let vertigo = AIWordContext(lemma: "vertigo", partOfSpeech: "noun", cefrLevel: .c1,
                                       senses: [.init(id: "s1", definition: "a feeling of dizziness caused by looking down from a great height, or a fear of heights")])
    static let luggage = AIWordContext(lemma: "luggage", partOfSpeech: "noun", cefrLevel: .a2,
                                       senses: [.init(id: "s1", definition: "the bags and cases that you take with you when you travel")])
}

// MARK: - Mistake classifier

final class MistakeClassifierTests: XCTestCase {
    func test_classification_table() {
        let cases: [(String, String, SentenceIssue.Kind?, MistakePattern)] = [
            ("I have a apple", "I have an apple", nil, .articles),
            ("She is teacher", "She is a teacher", nil, .articles),
            ("She depends of her parents", "She depends on her parents", nil, .prepositions),
            ("We discussed about the plan", "We discussed the plan", nil, .prepositions),
            ("I went to home", "I went home", nil, .prepositions),
            ("I am in the school", "I am at school", nil, .prepositions),
            ("He go to school every day", "He goes to school every day", nil, .agreement),
            ("She always go there", "She always goes there", nil, .agreement),
            ("She have a car", "She has a car", nil, .agreement),
            ("They was late", "They were late", nil, .agreement),
            ("The information are useful", "The information is useful", nil, .agreement),
            ("Two book are on the table", "Two books are on the table", nil, .plurals),
            ("He bought two book yesterday", "He bought two books yesterday", nil, .plurals),
            ("Yesterday I go to the cinema", "Yesterday I went to the cinema", nil, .verbForms),
            ("I am agree with you", "I agree with you", nil, .verbForms),
            ("He is go home", "He is going home", nil, .verbForms),
            ("I will went home", "I will go home", nil, .verbForms),
            ("She can to swim", "She can swim", nil, .verbForms),
            ("I want go", "I want to go", nil, .verbForms),
            ("I like very much music", "I like music very much", nil, .wordOrder),
            ("Can you borrow me your pen?", "Can you lend me your pen?", .wordChoice, .wordChoice),
            ("She said me the truth", "She told me the truth", .wordChoice, .wordChoice),
            ("I recieve a letter", "I receive a letter", nil, .spelling),
            ("I want that you help me", "I want you to help me", nil, .other),
            ("He suggested me to take a taxi", "He suggested that I take a taxi", nil, .other),
            ("Make a decision", "Make a decision", nil, .other),
        ]
        for (wrong, right, hint, expected) in cases {
            XCTAssertEqual(MistakeClassifier.classify(wrong: wrong, right: right, hint: hint), expected, "\(wrong) → \(right)")
        }
    }

    func test_grammarHintDoesNotOverrideRules() {
        XCTAssertEqual(MistakeClassifier.classify(wrong: "I have a apple", right: "I have an apple", hint: .wordChoice), .articles)
    }
}

// MARK: - Pattern analyzer

final class MistakePatternAnalyzerTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func record(_ wrong: String, _ right: String, daysAgo: Double) -> MistakeRecord {
        MistakeRecord(wrong: wrong, right: right, date: now.addingTimeInterval(-daysAgo * 86_400))
    }

    private var articles: [(String, String)] {
        [("I have a apple", "I have an apple"), ("She is teacher", "She is a teacher"), ("He wants to buy car", "He wants to buy a car")]
    }
    private var prepositions: [(String, String)] {
        [("She depends of her parents", "She depends on her parents"), ("We discussed about the plan", "We discussed the plan"),
         ("I am in the school", "I am at school")]
    }

    func test_recentPatternOutranksOlderPatternWithSameCount() {
        let records = articles.map { record($0.0, $0.1, daysAgo: 25) } + prepositions.map { record($0.0, $0.1, daysAgo: 1) }
        let stats = MistakePatternAnalyzer().analyze(records, now: now)

        XCTAssertEqual(stats.map(\.pattern), [.prepositions, .articles])
        XCTAssertEqual(stats.first?.recent, 3)
        XCTAssertEqual(stats.last?.recent, 0)
    }

    func test_recordsOutsideWindowAreIgnored() {
        let records = [record("I have a apple", "I have an apple", daysAgo: 40)]
        XCTAssertTrue(MistakePatternAnalyzer().analyze(records, now: now).isEmpty)
    }

    func test_lessonCandidateSkipsOtherAndRequiresEvidence() {
        let unclassified = (0..<4).map { record("I want that you help me\($0)", "I want you to help me\($0)", daysAgo: 1) }
        var records = unclassified + articles.map { record($0.0, $0.1, daysAgo: 5) }
        let analyzer = MistakePatternAnalyzer()

        XCTAssertEqual(analyzer.lessonCandidate(in: analyzer.analyze(records, now: now))?.pattern, .articles)

        records.removeLast()
        XCTAssertNil(analyzer.lessonCandidate(in: analyzer.analyze(records, now: now)), "two articles are not enough evidence")
    }

    func test_examplesAreDistinctAndCapped() {
        let same = (0..<5).map { record("I have a apple", "I have an apple", daysAgo: Double($0)) }
        let stat = MistakePatternAnalyzer().analyze(same, now: now).first
        XCTAssertEqual(stat?.total, 5)
        XCTAssertEqual(stat?.examples.count, 1)
    }
}

// MARK: - Lesson validation & coach

final class MistakeLessonTests: XCTestCase {
    private let learnerExample = MistakeRecord(wrong: "I have a apple", right: "I have an apple")

    private func lesson(_ exercises: [(String, String)]) -> MiniLessonContent {
        MiniLessonContent(title: "A or an", rule: "Use an before vowel sounds.", tip: " ",
                          exercises: exercises.map { MistakeExercise(incorrect: $0.0, correct: $0.1) })
    }

    func test_keepsOnlyExercisesTheClassifierAgreesWith() throws {
        let content = lesson([
            ("She has apple", "She has an apple"),          // articles ✓
            ("He is doctor", "He is a doctor"),             // articles ✓
            ("He go home", "He goes home"),                 // agreement ✗ for articles
            ("I have a apple", "I have an apple"),          // learner's own sentence ✗
            ("Same text.", "Same text"),                    // no change ✗
        ])
        let result = try MistakeLessonValidator().validate(content, pattern: .articles, examples: [learnerExample])

        XCTAssertEqual(result.exercises.count, 2)
        XCTAssertNil(result.tip)
    }

    func test_throwsWhenTooFewVerifiedExercises() {
        let content = lesson([("She has apple", "She has an apple"), ("He go home", "He goes home")])
        XCTAssertThrowsError(try MistakeLessonValidator().validate(content, pattern: .articles, examples: []))
    }

    func test_coachRegeneratesUntilLessonIsValid() async throws {
        let bad = lesson([("She has apple", "She has an apple")])
        let good = lesson([("She has apple", "She has an apple"), ("He is doctor", "He is a doctor")])
        let sequencer = Sequencer([bad, good])
        let coach = MistakeCoach(service: StubLessons(sequencer: sequencer))

        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let records = [("I have a apple", "I have an apple"), ("She is teacher", "She is a teacher"),
                       ("He wants to buy car", "He wants to buy a car")]
            .map { MistakeRecord(wrong: $0.0, right: $0.1, date: now.addingTimeInterval(-86_400)) }

        let result = try await coach.weeklyLesson(from: records, now: now, learner: Fixtures.learner)

        XCTAssertEqual(result?.pattern, .articles)
        XCTAssertEqual(result?.content.exercises.count, 2)
        let calls = await sequencer.calls
        XCTAssertEqual(calls, 2)
    }

    func test_coachReturnsNilWithoutEnoughEvidence() async throws {
        let coach = MistakeCoach(service: StubLessons(sequencer: Sequencer([lesson([])])))
        let result = try await coach.weeklyLesson(from: [learnerExample], learner: Fixtures.learner)
        XCTAssertNil(result)
    }
}

private struct StubLessons: MistakeLessonService {
    let identifier = "stub"
    let promptVersion = "test"
    let sequencer: Sequencer<MiniLessonContent>

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}
    func lesson(for pattern: MistakePattern, examples: [MistakeRecord], learner: LearnerProfile) async throws -> MiniLessonContent {
        await sequencer.next()
    }
}

// MARK: - Stories

final class StoryTests: XCTestCase {
    private let sentenceA = "We decided to walk to the old market today and then we borrowed a little cart from Anna."
    private let sentenceB = "She lent him her old bike after lunch and he thanked her warmly at the door."

    private func story(_ sentences: [String], copies: Int = 1) -> WordStory {
        let paragraph = Array(repeating: sentences.joined(separator: " "), count: copies).joined(separator: " ")
        return WordStory(title: "A busy day", paragraphs: [paragraph, paragraph, paragraph])
    }

    func test_validatorReportsCoverageAndHighlights() throws {
        let result = try StoryValidator().validate(story([sentenceA], copies: 2),
                                                   words: [Fixtures.decide, Words.borrow, Words.lend],
                                                   learner: Fixtures.learner)

        XCTAssertEqual(result.usedWords, ["decide", "borrow"])
        XCTAssertEqual(result.missingWords, ["lend"])
        XCTAssertFalse(result.isComplete)

        let first = try XCTUnwrap(result.highlights.first?.first)
        let text = NSString(string: result.paragraphs[0]).substring(with: NSRange(location: first.location, length: first.length))
        XCTAssertEqual(text, "decided")
        XCTAssertEqual(result.highlights[0].count, 4, "two sentences × two target words")
    }

    func test_validatorRejectsTooShortStory() {
        let short = WordStory(title: "Tiny", paragraphs: ["We decided to go."])
        XCTAssertThrowsError(try StoryValidator().validate(short, words: [Fixtures.decide], learner: Fixtures.learner))
    }

    func test_pipelineRegeneratesUntilAllWordsAppear() async throws {
        let partial = story([sentenceA], copies: 2)   // decide + borrow: 2/3, below the 75% floor
        let complete = story([sentenceA, sentenceB])
        let sequencer = Sequencer([partial, complete])
        let pipeline = StoryPipeline(service: StubStories(sequencer: sequencer))

        let result = try await pipeline.story(words: [Fixtures.decide, Words.borrow, Words.lend],
                                              topicHint: nil, learner: Fixtures.learner)

        XCTAssertTrue(result.isComplete)
        let calls = await sequencer.calls
        XCTAssertEqual(calls, 2)
    }

    func test_pipelineAcceptsBestAttemptAtCoverageFloorAndFlagsMissingWord() async throws {
        // "zebra" never appears: 3 of 4 target words = 75%, exactly the floor.
        let zebra = AIWordContext(lemma: "zebra", partOfSpeech: "noun", cefrLevel: .a1,
                                  senses: [.init(id: "s1", definition: "a wild African animal with black and white stripes")])
        let sequencer = Sequencer([story([sentenceA, sentenceB])])
        let pipeline = StoryPipeline(service: StubStories(sequencer: sequencer))

        let result = try await pipeline.story(words: [Fixtures.decide, Words.borrow, Words.lend, zebra],
                                              topicHint: nil, learner: Fixtures.learner)

        XCTAssertFalse(result.isComplete)
        XCTAssertEqual(result.missingWords, ["zebra"])
        let calls = await sequencer.calls
        XCTAssertEqual(calls, 3, "keeps regenerating up to maxAttempts before accepting the best attempt")
    }

    func test_pipelineFailsBelowCoverageFloor() async {
        // Only decide + borrow of three words (67%) in every attempt.
        let pipeline = StoryPipeline(service: StubStories(sequencer: Sequencer([story([sentenceA], copies: 2)])))
        do {
            _ = try await pipeline.story(words: [Fixtures.decide, Words.borrow, Words.lend], topicHint: nil, learner: Fixtures.learner)
            XCTFail("expected failure")
        } catch {
            XCTAssertEqual(error as? AIError, .invalidResponse("story does not use enough target words"))
        }
    }

    func test_pipelineRejectsWordCountOutsideRange() async {
        let pipeline = StoryPipeline(service: StubStories(sequencer: Sequencer([story([sentenceA])])))
        do {
            _ = try await pipeline.story(words: [Fixtures.decide], topicHint: nil, learner: Fixtures.learner)
            XCTFail("one word is below the minimum")
        } catch {
            XCTAssertEqual(error as? AIError, .invalidResponse("choose 2–8 words"))
        }
    }
}

private struct StubStories: StoryService {
    let identifier = "stub"
    let promptVersion = "test"
    let sequencer: Sequencer<WordStory>

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}
    func story(using words: [AIWordContext], topicHint: String?, learner: LearnerProfile) async throws -> WordStory {
        await sequencer.next()
    }
}

// MARK: - Reverse dictionary

final class ReverseDictionaryTests: XCTestCase {
    private let dictionary = MemoryDictionary(words: [Words.vertigo, Words.luggage, Words.borrow])

    func test_mergesModelAndRetrievalAndDropsUnverifiedWords() async throws {
        let finder = StubFinder { ["Vertigo", "luggage", "madeupword", "fear of heights", "vertigo"] }
        let result = try await ReverseDictionary(service: finder, dictionary: dictionary)
            .find("fear of heights", learner: Fixtures.learner)

        XCTAssertTrue(result.aiUsed)
        XCTAssertEqual(result.matches.map(\.lemma), ["vertigo", "luggage"])
        XCTAssertEqual(result.matches.first?.source, .both)
        XCTAssertEqual(result.matches.last?.source, .model)
        XCTAssertEqual(result.matches.first?.definition, Words.vertigo.senses[0].definition)
    }

    func test_degradesToRetrievalWhenModelUnavailable() async throws {
        let finder = StubFinder { throw AIError.unavailable(.deviceNotEligible) }
        let result = try await ReverseDictionary(service: finder, dictionary: dictionary)
            .find("fear of heights", learner: Fixtures.learner)

        XCTAssertFalse(result.aiUsed)
        XCTAssertEqual(result.aiUnavailableReason, .deviceNotEligible)
        XCTAssertEqual(result.matches.first?.lemma, "vertigo")
        XCTAssertEqual(result.matches.first?.source, .retrieval)
    }

    func test_guardrailErrorsAreNotSwallowed() async {
        let finder = StubFinder { throw AIError.guardrailViolation }
        do {
            _ = try await ReverseDictionary(service: finder, dictionary: dictionary).find("fear of heights", learner: Fixtures.learner)
            XCTFail("expected guardrail error")
        } catch {
            XCTAssertEqual(error as? AIError, .guardrailViolation)
        }
    }

    func test_inputLimits() async {
        let finder = StubFinder { [] }
        let sut = ReverseDictionary(service: finder, dictionary: dictionary)
        do { _ = try await sut.find("   ", learner: Fixtures.learner); XCTFail() } catch {}
        do {
            _ = try await sut.find(String(repeating: "a ", count: 200), learner: Fixtures.learner)
            XCTFail()
        } catch {
            XCTAssertEqual(error as? AIError, .inputTooLong(limit: 200))
        }
    }

    func test_stemmingMeetsInflectedForms() {
        XCTAssertEqual(QueryTerms.stem("arrived"), QueryTerms.stem("arrive"))
        XCTAssertEqual(QueryTerms.stem("bags"), QueryTerms.stem("bag"))
        XCTAssertEqual(QueryTerms.stem("heights"), QueryTerms.stem("height"))
    }
}

private struct MemoryDictionary: SearchableDictionary {
    let words: [AIWordContext]

    func wordContext(for lemma: String) async throws -> AIWordContext? {
        words.first { $0.lemma == lemma.lowercased() }
    }
    func distractors(for lemma: String, level: CEFRLevel?, limit: Int) async throws -> [String] { [] }
    func candidates(matching query: String, limit: Int) async throws -> [AIWordContext] {
        let terms = Set(QueryTerms.terms(query))
        return words
            .filter { !terms.isDisjoint(with: Set(QueryTerms.terms($0.senses.map(\.definition).joined(separator: " ")))) }
            .prefix(limit)
            .map { $0 }
    }
}

private struct StubFinder: WordFinderService {
    let identifier = "stub"
    let promptVersion = "test"
    let result: @Sendable () throws -> [String]

    init(_ result: @escaping @Sendable () throws -> [String]) { self.result = result }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}
    func proposeWords(for description: String, shortlist: [AIWordContext], learner: LearnerProfile) async throws -> [String] {
        try result()
    }
}

// MARK: - Placement

final class PlacementPipelineTests: XCTestCase {
    private let policy = RestrictedTermsPolicy(plainTerms: ["Acme Exam"])

    private func assessment(_ task: CEFRLevel, _ organisation: CEFRLevel, _ vocabulary: CEFRLevel, _ grammar: CEFRLevel) -> ExamAssessment {
        ExamAssessment(
            criteria: [
                CriterionResult(criterion: .taskFulfilment, level: task, comment: "ok"),
                CriterionResult(criterion: .organisation, level: organisation, comment: "ok"),
                CriterionResult(criterion: .vocabulary, level: vocabulary, comment: "ok"),
                CriterionResult(criterion: .grammar, level: grammar, comment: "ok"),
            ],
            overallLevel: .c2, strengths: [], improvements: [], wordCount: 0, isUnderLength: false)
    }

    private func longAnswers() -> [PlacementAnswer] {
        let text = Array(repeating: "I usually get up early and then I walk to work with my friend every day", count: 3).joined(separator: " ")
        return PlacementPrompts.standard.map { PlacementAnswer(promptID: $0.id, text: text) }
    }

    func test_longSampleUsesConservativeMedianAndHighConfidence() async throws {
        let pipeline = PlacementPipeline(service: StubPlacement(assessment(.b2, .b2, .c1, .b1)), policy: policy)
        let result = try await pipeline.assess(longAnswers())

        XCTAssertEqual(result.startingLevel, .b2)
        XCTAssertEqual(result.confidence, .high)
        XCTAssertFalse(result.cappedByConfidence)
    }

    func test_shortSampleIsCappedAtB1() async throws {
        let pipeline = PlacementPipeline(service: StubPlacement(assessment(.c1, .c1, .c1, .c1)), policy: policy)
        let result = try await pipeline.assess([PlacementAnswer(promptID: 1, text: "I like my job and my family very much.")])

        XCTAssertEqual(result.confidence, .low)
        XCTAssertEqual(result.startingLevel, .b1)
        XCTAssertTrue(result.cappedByConfidence)
        XCTAssertTrue(result.assessment.isUnderLength)
    }

    func test_unevenProfileLowersConfidence() async throws {
        let pipeline = PlacementPipeline(service: StubPlacement(assessment(.c2, .b1, .c2, .a2)), policy: policy)
        let result = try await pipeline.assess(longAnswers())
        XCTAssertEqual(result.confidence, .medium, "high lowered by a wide spread between criteria")
    }

    func test_restrictedTermInCommentIsRejected() async {
        var bad = assessment(.b1, .b1, .b1, .b1)
        bad = ExamAssessment(criteria: bad.criteria.map { CriterionResult(criterion: $0.criterion, level: $0.level, comment: "Like the Acme Exam.") },
                             overallLevel: .b1, strengths: [], improvements: [], wordCount: 0, isUnderLength: false)
        let pipeline = PlacementPipeline(service: StubPlacement(bad), policy: policy, maxAttempts: 1)
        do {
            _ = try await pipeline.assess(longAnswers())
            XCTFail("expected rejection")
        } catch {
            XCTAssertTrue(error is AIError)
        }
    }

    func test_emptyAnswersAreRejected() async {
        let pipeline = PlacementPipeline(service: StubPlacement(assessment(.b1, .b1, .b1, .b1)), policy: policy)
        do {
            _ = try await pipeline.assess([PlacementAnswer(promptID: 1, text: "   ")])
            XCTFail("expected rejection")
        } catch {
            XCTAssertEqual(error as? AIError, .invalidResponse("no answers"))
        }
    }
}

private struct StubPlacement: PlacementService {
    let identifier = "stub"
    let promptVersion = "test"
    let value: ExamAssessment

    init(_ value: ExamAssessment) { self.value = value }

    func availability(languageCode: String?) async -> AIAvailability { .available }
    func prewarm(for task: AITask) async {}
    func assess(answers: [PlacementAnswer]) async throws -> ExamAssessment { value }
}
