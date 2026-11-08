#if canImport(FoundationModels)
import Testing
import WordwellAICore
@testable import WordwellAIFoundationModels

@available(macOS 26.0, *)
@Test func languageNameIsNilForEnglishAndNamedOtherwise() {
    #expect(AIPrompts.languageName(nil) == nil)
    #expect(AIPrompts.languageName("en") == nil)
    #expect(AIPrompts.languageName("ru") == "Russian")
    #expect(AIPrompts.languageName("zh-Hans") == "Chinese, Simplified")
    #expect(AIPrompts.languageName("zh-Hant") == "Chinese, Traditional")
}

@available(macOS 26.0, *)
@Test func onlyNonEnglishInstructionsForceOutputLanguage() {
    let italian = AIPrompts.instructions(for: .explain, languageCode: "it")
    #expect(italian.hasPrefix("The person's locale is it."))
    #expect(italian.contains("You MUST respond in Italian, never in English."))
    #expect(AIPrompts.instructions(for: .explain, languageCode: "en") == AIPrompts.instructions(for: .explain))
    #expect(AIPrompts.localized("x", languageCode: "en", keepingEnglish: "y") == "x")
    #expect(AIPrompts.localized("x", languageCode: "xx", keepingEnglish: "y") == "x")
}

@available(macOS 26.0, *)
@Test func learnerLanguageReachesNonExplainPrompts() async {
    let word = AIWordContext(lemma: "run", partOfSpeech: "verb", cefrLevel: .a1,
                             senses: [.init(id: "s1", definition: "move fast")])
    let builder = PromptBuilder()
    let ru = LearnerProfile(level: .b1, nativeLanguageCode: "ru")
    let en = LearnerProfile(level: .b1, nativeLanguageCode: "en")

    #expect(await builder.improve("I runs", target: nil, learner: ru).contains("EXPLANATION LANGUAGE: Russian"))
    #expect(await builder.commonMistakes(word, learner: ru).contains("EXPLANATION LANGUAGE: Russian"))
    #expect(await builder.explain(word, learner: ru, languageCode: nil).contains("You MUST write the explanation and analogy in Russian"))
    #expect(await !builder.improve("I runs", target: nil, learner: en).contains("EXPLANATION LANGUAGE"))
}
#endif
