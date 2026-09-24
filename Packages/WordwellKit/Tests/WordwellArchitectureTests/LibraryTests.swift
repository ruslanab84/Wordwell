import Testing
import WordwellData
import WordwellDomain

@Test func librarySavesAndOrganizesWordsLocally() async throws {
    let library: any WordLibraryRepository = try LocalWordLibraryRepository(inMemory: true)

    try await library.recordViewed(wordID: "family.n")
    try await library.save(wordID: "family.n")
    try await library.save(wordID: "family.n")
    #expect(try await library.allSavedWords().count == 1)
    #expect(try await library.recentlyViewedWordIDs(limit: 1) == ["family.n"])

    let collection = try await library.createCollection(named: "  Favorites  ")
    #expect(collection.name == "Favorites")
    var state = try #require(try await library.state(for: "family.n"))
    state.collectionIDs = [collection.id]
    state.isFavorite = true
    try await library.update(state)
    #expect(try await library.state(for: "family.n") == state)
    #expect(try await library.collections() == [collection])
    await #expect(throws: WordLibraryError.duplicateCollectionName) {
        try await library.createCollection(named: "favorites")
    }

    try await library.remove(wordID: "family.n")
    #expect(try await library.allSavedWords().isEmpty)
    #expect(try await library.recentlyViewedWordIDs(limit: 1) == ["family.n"])
}

@Test func vocabularyTopicsOpenBundledDictionaryEntries() async throws {
    let dictionary = try LocalDictionaryRepository()
    #expect(Set(VocabularyTopic.all.map(\.id)).count == VocabularyTopic.all.count)

    for topic in VocabularyTopic.all {
        #expect(topic.words.count == 50)
        #expect(Set(topic.wordIDs).count == topic.wordIDs.count)
        for (word, id) in zip(topic.words, topic.wordIDs) {
            let entry = try? await dictionary.entry(id: id)
            #expect(entry?.word == word, "\(topic.title): \(id)")
        }
    }
}
