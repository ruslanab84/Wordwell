import Testing
import WordwellData
import WordwellDomain

@Test func commonWordsListIsCompleteAndResolvable() async throws {
    let words = CommonWordsCatalog.load()
    #expect(words.count == 3000)
    #expect(Set(words.map(\.id)).count == 3000)
    #expect(words.first?.rank == 1)

    let repository: any DictionaryRepository = try LocalDictionaryRepository()
    for word in words.prefix(50) {
        #expect(try await repository.entry(id: word.id) != nil)
    }
}
