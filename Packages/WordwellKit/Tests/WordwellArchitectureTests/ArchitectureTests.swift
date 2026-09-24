import CoreText
import Foundation
import SwiftUI
import Testing
#if canImport(AppKit)
import AppKit
#endif
import WordwellAI
import WordwellData
import WordwellDesign
import WordwellDomain

@Test func noAIReportsUnavailableAndNeverGenerates() async {
    let service: any LanguageAIService = NoAIService()
    let context = AIContext(profile: LearningProfile(
        cefrLevel: .b1,
        explanationLanguage: "en",
        preferredEnglishVariant: .both,
        dailyGoalMinutes: 10
    ))

    #expect(await service.availability(for: "en") == .unavailable(.notConfigured))
    do {
        _ = try await service.generateQuiz(words: [], context: context)
        Issue.record("NoAIService generated a quiz")
    } catch let error as AIServiceError {
        #expect(error == .unavailable(.notConfigured))
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test func dictionaryWithoutSeedFailsExplicitly() async {
    let repository: any DictionaryRepository = UnavailableDictionaryRepository()
    do {
        _ = try await repository.search("family", limit: 10)
        Issue.record("Unconfigured dictionary returned entries")
    } catch let error as DictionaryRepositoryError {
        #expect(error == .notConfigured)
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test func illustrationBindingUsesSchemaSenseId() throws {
    let data = Data("""
        {
          "id":"illustration.family.noun.plate",
          "word":"family",
          "lemma":"family",
          "partOfSpeech":"noun",
          "senseId":"family-1",
          "assetName":"word_family_plate",
          "assetPath":"Resources/IllustrationsSVG/Words/word_family_plate.svg",
          "style":"monochrome_line_art",
          "contexts":["dictionary_entry"],
          "version":1,
          "tags":["people"],
          "altText":"A family drawn in simple outlines",
          "isDecorative":false,
          "notes":null
        }
        """.utf8)

    let binding = try JSONDecoder().decode(IllustrationBinding.self, from: data)
    #expect(binding.senseID == "family-1")
    #expect(binding.style == .monochromeLineArt)
    #expect(binding.contexts == [.dictionaryEntry])
}

@Test func bundledIllustrationsReuseWordAcrossAllowedContexts() async throws {
    let repository = LocalIllustrationBindingRepository()
    let library = try await repository.binding(lemma: " FAMILY ", partOfSpeech: .noun,
                                               senseID: "any-sense", context: .library)
    let review = try await repository.binding(lemma: "family", partOfSpeech: .noun,
                                              senseID: nil, context: .review)
    let detail = try await repository.binding(lemma: "family", partOfSpeech: .noun,
                                              senseID: nil, context: .dictionaryEntry)
    #expect(library?.assetName == "word_family_line")
    #expect(review?.assetName == library?.assetName)
    #expect(detail?.assetName == "word_family_plate")
    let apple = try await repository.binding(lemma: "apple", partOfSpeech: .noun,
                                             senseID: nil, context: .dictionaryEntry)
    #expect(apple?.assetName == "word_apple_plate")
    let phoneNoun = try await repository.binding(lemma: "phone", partOfSpeech: .noun,
                                                 senseID: nil, context: .dictionaryEntry)
    let phoneVerb = try await repository.binding(lemma: "phone", partOfSpeech: .verb,
                                                 senseID: nil, context: .dictionaryEntry)
    #expect(phoneNoun?.assetName == phoneVerb?.assetName)
    let below = try await repository.binding(lemma: "below", partOfSpeech: .adverb,
                                              senseID: nil, context: .dictionaryEntry)
    #expect(below?.assetName == "word_below_adverb_plate")
    #expect(try await repository.binding(lemma: "family", partOfSpeech: .verb,
                                         senseID: nil, context: .library) == nil)
    #expect(try await repository.binding(lemma: "unknown", partOfSpeech: .noun,
                                         senseID: nil, context: .dictionaryEntry) == nil)
}

@Test func bundledPhrasalVerbsLoadOffline() {
    let entries = LocalPhrasalVerbCatalog.all
    #expect(entries.count == 300)
    #expect(Set(entries.map(\.phrase)).count == 300)
    #expect(entries.contains { $0.phrase == "get up" })
    #expect(entries.contains { $0.phrase == "wind up" })
    #expect(entries.allSatisfy { $0.phrase.contains(" ") && !$0.baseVerb.isEmpty })
    #expect(Set(entries.filter { $0.baseVerb == "look" }.map(\.phrase)).isSuperset(of: ["look after", "look out"]))
    #expect(Set(entries.filter { $0.baseVerb == "turn" }.map(\.phrase)).isSuperset(of: ["turn down", "turn around"]))
}

@Test func designFontsLoadFromPackageBundle() {
    WordwellFonts.register()
    let display = CTFontCreateWithName("Fraunces-Regular" as CFString, 12, nil)
    let body = CTFontCreateWithName("WorkSans-Regular" as CFString, 12, nil)
    #expect(CTFontCopyFamilyName(display) as String == "Fraunces")
    #expect(CTFontCopyFamilyName(body) as String == "Work Sans")
}

#if canImport(AppKit)
@Test func designTextColorsMeetContrastInBothAppearances() {
    let pairs: [(Color, Color)] = [
        (WordwellColor.ink, WordwellColor.paper),
        (WordwellColor.secondaryText, WordwellColor.paper),
        (WordwellColor.CEFR.beginnerText, WordwellColor.CEFR.beginnerBackground),
        (WordwellColor.CEFR.intermediateText, WordwellColor.CEFR.intermediateBackground),
        (WordwellColor.CEFR.advancedText, WordwellColor.CEFR.advancedBackground),
    ]

    for name in [NSAppearance.Name.aqua, .darkAqua] {
        let appearance = NSAppearance(named: name)!
        for (index, pair) in pairs.enumerated() {
            let value = contrast(pair.0, pair.1, appearance: appearance)
            #expect(value >= 4.5, "\(name.rawValue) pair \(index): \(value)")
        }
    }
}

private func contrast(_ foreground: Color, _ background: Color, appearance: NSAppearance) -> Double {
    func luminance(_ color: Color) -> Double {
        var resolved: NSColor!
        appearance.performAsCurrentDrawingAppearance {
            resolved = NSColor(color).usingColorSpace(.deviceRGB)
        }
        func channel(_ value: CGFloat) -> Double {
            let value = Double(value)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(resolved.redComponent)
            + 0.7152 * channel(resolved.greenComponent)
            + 0.0722 * channel(resolved.blueComponent)
    }

    let lighter = max(luminance(foreground), luminance(background))
    let darker = min(luminance(foreground), luminance(background))
    return (lighter + 0.05) / (darker + 0.05)
}
#endif
