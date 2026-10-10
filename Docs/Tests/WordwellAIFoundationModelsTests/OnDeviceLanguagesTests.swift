import Testing
@testable import WordwellAIFoundationModels

@Test func unsupportedLanguagesAreDroppedAndEnglishStays() {
    let all = [(code: "de", name: "German"), (code: "en", name: "English"), (code: "ru", name: "Russian")]
    let result = onDeviceSupportedLanguages(all) { $0 == "de" }
    #expect(result.map(\.code) == ["de", "en"])
}
