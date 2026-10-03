import Foundation

enum SentenceSplitter {
    static func sentences(_ text: String) -> [String] {
        var result: [String] = []
        var current = ""
        let characters = Array(text)
        for (index, character) in characters.enumerated() {
            current.append(character)
            guard ".!?".contains(character) else { continue }
            let next: Character? = index + 1 < characters.count ? characters[index + 1] : nil
            if next?.isWhitespace ?? true {
                if let sentence = current.nilIfBlank { result.append(sentence) }
                current = ""
            }
        }
        if let sentence = current.nilIfBlank { result.append(sentence) }
        return result
    }
}

/// Finds target words (any inflected form) in story text as UTF-16 spans for tap-to-define.
enum StoryHighlighter {
    static func highlights(in text: String, words: [AIWordContext]) -> [StoryHighlight] {
        let fullRange = NSRange(text.startIndex..., in: text)
        var spans: [StoryHighlight] = []

        for word in words {
            for form in word.allForms where form.nilIfBlank != nil {
                let pattern = "\\b" + NSRegularExpression.escapedPattern(for: form.trimmed) + "\\b"
                guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
                for match in regex.matches(in: text, range: fullRange) {
                    spans.append(StoryHighlight(lemma: word.lemma, location: match.range.location, length: match.range.length))
                }
            }
        }

        spans.sort { ($0.location, -$0.length) < ($1.location, -$1.length) }
        var result: [StoryHighlight] = []
        var end = 0
        for span in spans where span.location >= end {
            result.append(span)
            end = span.location + span.length
        }
        return result
    }
}

public struct StoryValidator: Sendable {
    public init() {}

    /// Structural checks + deterministic coverage. Missing words are reported, not hidden.
    public func validate(_ story: WordStory, words: [AIWordContext], learner: LearnerProfile) throws -> ValidatedStory {
        let paragraphs = story.paragraphs.compactMap(\.nilIfBlank)
        guard let title = story.title.nilIfBlank, (1...6).contains(paragraphs.count) else {
            throw AIError.invalidResponse("incomplete story")
        }

        let profile = StoryProfile.for(learner.level)
        let wordCount = WordCounter.count(paragraphs.joined(separator: " "))
        let lower = Int(Double(profile.wordRange.lowerBound) * 0.8)
        let upper = Int(Double(profile.wordRange.upperBound) * 1.2)
        guard (lower...upper).contains(wordCount) else {
            throw AIError.invalidResponse("story length \(wordCount) outside \(lower)...\(upper)")
        }

        let sentenceCount = paragraphs.flatMap { SentenceSplitter.sentences($0) }.count
        let average = Double(wordCount) / Double(max(1, sentenceCount))
        guard average <= profile.maxAverageSentenceWords * 1.35 else {
            throw AIError.invalidResponse("sentences too long for \(learner.level.rawValue)")
        }

        let highlights = paragraphs.map { StoryHighlighter.highlights(in: $0, words: words) }
        let usedLemmas = Set(highlights.flatMap { paragraph in paragraph.map(\.lemma) })
        let used = words.map(\.lemma).filter { usedLemmas.contains($0) }
        let missing = words.map(\.lemma).filter { !usedLemmas.contains($0) }

        return ValidatedStory(title: title, paragraphs: paragraphs, highlights: highlights, usedWords: used,
                              missingWords: missing, wordCount: wordCount, averageSentenceLength: average)
    }
}

/// "Story from my words": regenerates until every target word appears, keeps the best attempt.
public struct StoryPipeline: Sendable {
    public struct Configuration: Sendable {
        public var wordCountRange = 2...8
        public var maxAttempts = 3
        /// Share of target words a story must contain when no attempt is complete.
        public var minAcceptableCoverage = 0.75
        public init() {}
    }

    private let service: any StoryService
    private let validator = StoryValidator()
    private let configuration: Configuration

    public init(service: any StoryService, configuration: Configuration = Configuration()) {
        self.service = service
        self.configuration = configuration
    }

    public func story(words: [AIWordContext], topicHint: String?, learner: LearnerProfile) async throws -> ValidatedStory {
        var seen = Set<String>()
        let targets = words.filter { seen.insert($0.lemma.lowercased()).inserted }
        guard configuration.wordCountRange.contains(targets.count) else {
            throw AIError.invalidResponse("choose \(configuration.wordCountRange.lowerBound)–\(configuration.wordCountRange.upperBound) words")
        }
        let topic = topicHint?.nilIfBlank.map { String($0.prefix(60)) }

        var best: ValidatedStory?
        var lastError = AIError.invalidResponse("no attempts")

        for _ in 0..<max(1, configuration.maxAttempts) {
            do {
                let raw = try await service.story(using: targets, topicHint: topic, learner: learner)
                let candidate = try validator.validate(raw, words: targets, learner: learner)
                if candidate.isComplete { return candidate }
                if candidate.usedWords.count > (best?.usedWords.count ?? -1) { best = candidate }
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }

        if let best, Double(best.usedWords.count) / Double(targets.count) >= configuration.minAcceptableCoverage {
            return best
        }
        throw best == nil ? lastError : AIError.invalidResponse("story does not use enough target words")
    }
}
