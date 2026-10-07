import Testing
import WordwellData

struct CommonWordTopicsTests {
    @Test func everyCommonWordHasATopic() {
        let words = CommonWordsCatalog.load()
        let topics = CommonWordsCatalog.topics()
        #expect(words.count == 3000)
        #expect(words.filter { topics[$0.id] == nil }.isEmpty)
    }

    @Test func fewWordsFallBackToGeneral() {
        let topics = CommonWordsCatalog.topics()
        #expect(topics.values.filter { $0 == "general" }.count < 100)
    }
}
