import Foundation
import WordwellAICore

enum StudyRenderer {
    // MARK: - Find

    static func finder(_ result: ReverseLookupResult) -> String {
        var lines: [String] = []
        if result.matches.isEmpty {
            lines.append("No matches. Try other words, or use a dictionary with more entries.")
        }
        for (index, match) in result.matches.enumerated() {
            let level = match.cefrLevel.map { ", \($0.rawValue)" } ?? ""
            lines.append("\(index + 1). \(match.lemma) (\(match.partOfSpeech)\(level)) — \(match.definition)  [\(label(match.source))]")
        }
        if !result.aiUsed {
            let reason = result.aiUnavailableReason.map { " (\($0.rawValue))" } ?? ""
            lines.append("\nAI not used\(reason): showing dictionary matches only.")
        }
        return lines.joined(separator: "\n")
    }

    private static func label(_ source: WordFinderMatch.Source) -> String {
        switch source {
        case .both: "AI + dictionary"
        case .model: "AI, verified in dictionary"
        case .retrieval: "dictionary match"
        }
    }

    // MARK: - Story

    static func story(_ story: ValidatedStory, glossary: [AIWordContext], bold: Bool) -> String {
        var lines = [story.title.uppercased(), ""]
        for (index, paragraph) in story.paragraphs.enumerated() {
            let spans = index < story.highlights.count ? story.highlights[index] : []
            lines.append(marked(paragraph, spans, bold: bold))
            lines.append("")
        }
        lines.append("Words")
        lines += glossary.map { "  \($0.lemma) — \($0.senses.first?.definition ?? "")" }
        var footer = "\n\(story.wordCount) words · average sentence \(String(format: "%.1f", story.averageSentenceLength)) words · uses \(story.usedWords.count)/\(glossary.count) target words"
        if !story.missingWords.isEmpty { footer += " · missing: \(story.missingWords.joined(separator: ", "))" }
        lines.append(footer)
        return lines.joined(separator: "\n")
    }

    /// Wraps highlighted spans in bold (terminal) or *asterisks* (plain text).
    static func marked(_ text: String, _ spans: [StoryHighlight], bold: Bool) -> String {
        let mutable = NSMutableString(string: text)
        for span in spans.sorted(by: { $0.location > $1.location }) {
            let range = NSRange(location: span.location, length: span.length)
            guard range.location + range.length <= mutable.length else { continue }
            let word = mutable.substring(with: range)
            mutable.replaceCharacters(in: range, with: bold ? "\u{1B}[1m\(word)\u{1B}[0m" : "*\(word)*")
        }
        return mutable as String
    }

    // MARK: - Placement

    static func placementPrompts() -> String {
        var lines = ["PLACEMENT · answer each question in your own words"]
        lines += PlacementPrompts.standard.map { "\($0.id). \($0.text)  (about \($0.suggestedSentences) sentences)" }
        lines.append("\nAim for at least \(PlacementPrompts.minimumWords) words in total.")
        lines.append("Then run: wordwell-ai placement --interactive   or   --answer \"…\" --answer \"…\" --answer \"…\"")
        return lines.joined(separator: "\n")
    }

    static func placement(_ result: PlacementResult) -> String {
        var lines = ["Suggested starting level: \(result.startingLevel.rawValue)  ·  confidence: \(result.confidence.rawValue)"]
        if result.cappedByConfidence {
            lines.append("Capped at \(result.startingLevel.rawValue): the sample was too short to place you higher. Write more for a better estimate.")
        }
        lines.append("")
        lines.append(ExamRenderer.assessment(result.assessment))
        return lines.joined(separator: "\n")
    }

    // MARK: - Patterns

    static func title(_ pattern: MistakePattern) -> String {
        switch pattern {
        case .articles: "Articles"
        case .prepositions: "Prepositions"
        case .verbForms: "Verb tenses and forms"
        case .agreement: "Subject-verb agreement"
        case .plurals: "Singular and plural"
        case .wordOrder: "Word order"
        case .spelling: "Spelling"
        case .wordChoice: "Word choice"
        case .collocation: "Collocations"
        case .register: "Formal and informal"
        case .other: "Other"
        }
    }

    static func report(_ stats: [PatternStat], analyzer: MistakePatternAnalyzer) -> String {
        guard !stats.isEmpty else { return "No mistakes in the last \(analyzer.windowDays) days." }
        let total = stats.reduce(0) { $0 + $1.total }
        let candidate = analyzer.lessonCandidate(in: stats)?.pattern
        var lines = ["Mistake patterns · last \(analyzer.windowDays) days · \(total) mistakes", ""]
        lines.append(pad("Pattern", 26) + pad("Total", 7) + pad("7d", 5) + pad("Share", 7) + "Example")
        for stat in stats {
            let share = Int((Double(stat.total) / Double(total) * 100).rounded())
            let example = stat.examples.first.map { "\($0.wrong) → \($0.right)" } ?? ""
            let name = (stat.pattern == candidate ? "★ " : "  ") + title(stat.pattern)
            lines.append(pad(name, 26) + pad("\(stat.total)", 7) + pad("\(stat.recent)", 5) + pad("\(share)%", 7) + example)
        }
        if let candidate {
            lines.append("\n★ Next lesson: \(title(candidate)). Run: wordwell-ai patterns lesson")
        } else {
            lines.append("\nNo pattern has \(analyzer.minOccurrences)+ classified mistakes yet.")
        }
        return lines.joined(separator: "\n")
    }

    static func records(_ records: [MistakeRecord]) -> String {
        guard !records.isEmpty else { return "The notebook is empty. Try: wordwell-ai patterns seed" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return records.sorted { $0.date > $1.date }.map {
            "\(formatter.string(from: $0.date))  \(pad(title($0.pattern), 24)) \($0.wrong) → \($0.right)"
        }.joined(separator: "\n")
    }

    static func lesson(_ lesson: WeeklyMistakeLesson, showAnswers: Bool) -> String {
        var lines = ["MINI-LESSON · \(title(lesson.pattern))", lesson.content.title, "", lesson.content.rule]
        if let tip = lesson.content.tip { lines.append("Tip: \(tip)") }
        lines.append("\nYour mistakes (\(lesson.stat.total) in the notebook)")
        for record in lesson.yourMistakes {
            lines.append("  ✗ \(record.wrong)")
            lines.append("  ✓ \(record.right)")
        }
        lines.append("\nPractice: fix each sentence")
        for (index, exercise) in lesson.content.exercises.enumerated() {
            lines.append("  \(index + 1). \(exercise.incorrect)")
            if showAnswers { lines.append("     → \(exercise.correct)") }
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Input

    /// Reads lines until a line containing only '.'.
    static func readMultiline() -> String {
        var lines: [String] = []
        while let line = readLine(), line != "." { lines.append(line) }
        return lines.joined(separator: "\n")
    }

    private static func pad(_ text: String, _ width: Int) -> String {
        text.count >= width ? text + " " : text.padding(toLength: width, withPad: " ", startingAt: 0)
    }
}
