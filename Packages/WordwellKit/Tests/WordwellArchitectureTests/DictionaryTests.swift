import Foundation
import Testing
import WordwellData
import WordwellDomain

@Test func bundledDictionarySearchesOffline() async throws {
    let repository: any DictionaryRepository = try LocalDictionaryRepository()

    let exact = try await repository.search("family", limit: 5)
    #expect(exact.first?.word == "family")
    #expect(exact.first?.partOfSpeech == .noun)

    let inflected = try await repository.search("happier", limit: 5)
    #expect(inflected.first?.word == "happy")

    let meaning = try await repository.search("creature imagination", limit: 5)
    #expect(meaning.contains { $0.word == "imaginary being" })

    let suggestions = try await repository.suggestions(prefix: "happy", limit: 5)
    #expect(suggestions.first == "happy")

    let entry = try #require(try await repository.entry(id: exact[0].id))
    #expect(entry.word == "family")
    #expect(entry.senses.count > 1)
    #expect(entry.senses.allSatisfy { !$0.definition.isEmpty })
    #expect(try await repository.entry(lemma: "family")?.id == entry.id)

    #expect(try await repository.search("", limit: 5).isEmpty)
    #expect(try await repository.search("family", limit: 0).isEmpty)
    #expect(try await repository.entry(id: "missing") == nil)
}

@Test func featuredWordChangesOnNextOpening() async throws {
    let repository = try LocalDictionaryRepository()
    let first = try #require(try await repository.featuredEntry(excluding: nil))
    let next = try #require(try await repository.featuredEntry(excluding: first.id))
    #expect(next.word != first.word)
    #expect(!first.senses.isEmpty && !next.senses.isEmpty)
}

@Test func notificationWordsAreDistinctAndHaveTranscription() async throws {
    let repository = try LocalDictionaryRepository()
    let first = try await repository.notificationEntries(excluding: [], limit: 60)
    #expect(first.count == 60)
    #expect(Set(first.map(\.lemma)).count == 60)
    #expect(first.allSatisfy { $0.ipaUK != nil || $0.ipaUS != nil })
    let next = try await repository.notificationEntries(
        excluding: Set(first.map(\.id) + first.map { $0.lemma.lowercased() }), limit: 10)
    #expect(next.count == 10)
    #expect(Set(next.map(\.id)).isDisjoint(with: Set(first.map(\.id))))
    #expect(Set(next.map(\.lemma)).isDisjoint(with: Set(first.map(\.lemma))))
}

@Test func oldLearningProfileDefaultsWordNotificationsToOff() throws {
    let data = Data("""
        {"cefrLevel":"B1","explanationLanguage":"en","preferredEnglishVariant":"us", "dailyGoalMinutes":10,"aiEnabled":true}
        """.utf8)
    let profile = try JSONDecoder().decode(LearningProfile.self, from: data)
    #expect(profile.newWordsPerDay == 0)
    var enabled = profile
    enabled.newWordsPerDay = 10
    #expect(try JSONDecoder().decode(LearningProfile.self, from: JSONEncoder().encode(enabled)).newWordsPerDay == 10)
}

@Test func dictionaryRejectsMissingDatabase() {
    #expect(throws: DictionaryRepositoryError.invalidDatabase) {
        try LocalDictionaryRepository(databaseURL: URL(fileURLWithPath: "/nonexistent/wordwell.sqlite"))
    }
}

@Test func cancelledDictionaryLookupStopsBeforeReturningResults() async throws {
    let repository: any DictionaryRepository = try LocalDictionaryRepository()
    let lookup = Task {
        withUnsafeCurrentTask { $0?.cancel() }
        do {
            _ = try await repository.search("family", limit: 5)
            return false
        } catch is CancellationError {
            return true
        } catch {
            return false
        }
    }
    #expect(await lookup.value)
}

@Test func searchHistoryKeepsDistinctRecentQueries() throws {
    var history = SearchHistory()
    history.record("  Family  ")
    history.record("friend")
    history.record("family")
    history.record("  ")
    #expect(history.terms == ["family", "friend"])

    for index in 0..<25 { history.record("word\(index)") }
    #expect(history.terms.count == 20)
    #expect(history.terms.first == "word24")
    #expect(history.terms.last == "word5")

    let restored = try JSONDecoder().decode(SearchHistory.self, from: JSONEncoder().encode(history))
    #expect(restored == history)
}
