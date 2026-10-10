#if canImport(FoundationModels)
import Testing
import WordwellAICore
@testable import WordwellAIFoundationModels

@available(macOS 26.0, *)
@Test func languageNameIsNilForEnglishAndNamedOtherwise() {
    #expect(AIPrompts.languageName(nil) == nil)
    #expect(AIPrompts.languageName("en") == nil)
    #expect(AIPrompts.languageName("ru") == "Russian")
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
    #expect(await builder.explain(word, learner: ru, languageCode: nil).contains("Write the explanation and analogy in Russian"))
    #expect(await !builder.improve("I runs", target: nil, learner: en).contains("EXPLANATION LANGUAGE"))
}
#endif
