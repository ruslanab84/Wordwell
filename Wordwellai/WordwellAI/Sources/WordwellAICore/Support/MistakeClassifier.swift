import Foundation

/// Rule-based, offline classification of a learner mistake from a (wrong, right) sentence pair.
///
/// Deterministic on purpose: it costs no tokens, gives the same answer every time and is unit-tested.
/// Structural patterns (articles, prepositions, word order, verb forms, agreement, plurals) are decided by rules.
/// Word-level patterns (word choice, collocation, register, spelling) use the caller's `hint`, then an
/// edit-distance check. Anything ambiguous is `.other`; it is never guessed.
public enum MistakeClassifier {
    public static func classify(wrong: String, right: String, hint: SentenceIssue.Kind? = nil) -> MistakePattern {
        let old = tokens(wrong)
        let new = tokens(right)
        guard !old.isEmpty, !new.isEmpty, old != new else { return .other }

        if old.sorted() == new.sorted() { return .wordOrder }

        var removed: [(offset: Int, word: String)] = []
        var inserted: [(offset: Int, word: String)] = []
        for change in new.difference(from: old) {
            switch change {
            case let .remove(offset, element, _): removed.append((offset, element))
            case let .insert(offset, element, _): inserted.append((offset, element))
            }
        }
        removed.sort { $0.offset < $1.offset }
        inserted.sort { $0.offset < $1.offset }

        let changed = removed.map(\.word) + inserted.map(\.word)
        guard !changed.isEmpty else { return .other }

        if changed.allSatisfy({ articles.contains($0) }) { return .articles }

        if changed.allSatisfy({ articles.contains($0) || prepositions.contains($0) }),
           changed.contains(where: { prepositions.contains($0) }) {
            return isVerbPatternTo(removed: removed, inserted: inserted, old: old, new: new) ? .verbForms : .prepositions
        }

        // Only added/removed tokens: "I am agree" → "I agree", "She can to swim" → "She can swim".
        if removed.isEmpty || inserted.isEmpty {
            if changed.allSatisfy({ auxiliaries.contains($0) || $0 == "to" }) { return .verbForms }
            return mapped(hint) ?? .other
        }

        guard removed.count == inserted.count else { return mapped(hint) ?? .other }

        let patterns = zip(removed, inserted).map { pairPattern(old: $0.word, new: $1.word, oldTokens: old, offset: $0.offset) }
        if let first = patterns.first, let value = first, patterns.allSatisfy({ $0 == value }) { return value }

        if let value = mapped(hint) { return value }

        if removed.count == 1, isSpellingVariant(removed[0].word, inserted[0].word) { return .spelling }
        return .other
    }

    // MARK: - Pair analysis

    private static func pairPattern(old: String, new: String, oldTokens: [String], offset: Int) -> MistakePattern? {
        if agreementPairs.contains(Set([old, new])) { return .agreement }
        if auxiliaries.contains(old), auxiliaries.contains(new) { return .verbForms }

        switch inflection(old, new) {
        case .suffixS:
            // Same surface change for "he go → goes" and "two book → books": decide by the words just before.
            let window = Set(oldTokens[max(0, offset - 2)..<offset])
            if !window.isDisjoint(with: quantifiers) || window.contains(where: { $0.allSatisfy(\.isNumber) }) { return .plurals }
            if !window.isDisjoint(with: thirdPerson) { return .agreement }
            return nil
        case .suffixEdOrIng:
            return .verbForms
        case nil:
            if let family = verbFamilyIndex[old], family == verbFamilyIndex[new] { return .verbForms }
            return nil
        }
    }

    private enum Inflection { case suffixS, suffixEdOrIng }

    private static func inflection(_ a: String, _ b: String) -> Inflection? {
        let (short, long) = a.count <= b.count ? (a, b) : (b, a)
        guard short.count >= 2, short != long, let last = short.last else { return nil }
        let stem = String(short.dropLast())

        if long == short + "s" || long == short + "es" { return .suffixS }
        if short.hasSuffix("y"), long == stem + "ies" { return .suffixS }

        if long == short + "ed" || long == short + "d" || long == short + String(last) + "ed" { return .suffixEdOrIng }
        if short.hasSuffix("y"), long == stem + "ied" { return .suffixEdOrIng }
        if long == short + "ing" || long == short + String(last) + "ing" { return .suffixEdOrIng }
        if short.hasSuffix("e"), long == stem + "ing" { return .suffixEdOrIng }
        return nil
    }

    /// "to" is a verb-pattern error after modals and desire verbs ("can to swim", "want go"), otherwise a preposition slip.
    private static func isVerbPatternTo(removed: [(offset: Int, word: String)], inserted: [(offset: Int, word: String)],
                                        old: [String], new: [String]) -> Bool {
        var contexts: [(word: String, previous: String?)] = []
        for item in removed where prepositions.contains(item.word) {
            contexts.append((item.word, item.offset > 0 ? old[item.offset - 1] : nil))
        }
        for item in inserted where prepositions.contains(item.word) {
            contexts.append((item.word, item.offset > 0 ? new[item.offset - 1] : nil))
        }
        return !contexts.isEmpty && contexts.allSatisfy { $0.word == "to" && toVerbTriggers.contains($0.previous ?? "") }
    }

    private static func mapped(_ hint: SentenceIssue.Kind?) -> MistakePattern? {
        guard let hint else { return nil }
        switch hint {
        case .spelling: return .spelling
        case .wordChoice: return .wordChoice
        case .collocation: return .collocation
        case .register: return .register
        case .grammar, .other: return nil
        }
    }

    private static func isSpellingVariant(_ a: String, _ b: String) -> Bool {
        guard a.count >= 3, b.count >= 3 else { return false }
        let distance = editDistance(Array(a), Array(b))
        return distance <= 2 && distance * 3 <= max(a.count, b.count)
    }

    static func editDistance(_ a: [Character], _ b: [Character]) -> Int {
        var previous = Array(0...b.count)
        for (i, x) in a.enumerated() {
            var current = [i + 1]
            for (j, y) in b.enumerated() {
                current.append(min(previous[j + 1] + 1, current[j] + 1, previous[j] + (x == y ? 0 : 1)))
            }
            previous = current
        }
        return previous[b.count]
    }

    // MARK: - Tokens

    static func tokens(_ text: String) -> [String] {
        text.lowercased()
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .split(whereSeparator: { !($0.isLetter || $0.isNumber || $0 == "'") })
            .map { String($0).trimmingCharacters(in: CharacterSet(charactersIn: "'")) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Word lists

    private static let articles: Set<String> = ["a", "an", "the"]

    private static let prepositions: Set<String> = [
        "in", "on", "at", "to", "for", "of", "with", "by", "from", "about", "into", "over", "under", "between",
        "through", "during", "since", "until", "among", "within", "without", "against", "across", "after",
        "before", "around", "toward", "towards", "onto",
    ]

    private static let auxiliaries: Set<String> = [
        "will", "would", "have", "has", "had", "was", "were", "been", "being", "did", "do", "does", "am", "is", "are",
        "be", "can", "could", "shall", "should", "must", "may", "might", "doesn't", "don't", "didn't", "haven't",
        "hasn't", "isn't", "aren't", "wasn't", "weren't",
    ]

    private static let agreementPairs: Set<Set<String>> = [
        ["has", "have"], ["is", "are"], ["was", "were"], ["am", "is"], ["am", "are"], ["does", "do"],
        ["doesn't", "don't"], ["hasn't", "haven't"], ["isn't", "aren't"], ["wasn't", "weren't"],
    ]

    private static let thirdPerson: Set<String> = ["he", "she", "it", "who", "everyone", "everybody", "someone", "nobody", "this", "that"]

    private static let quantifiers: Set<String> = [
        "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "many", "several", "few",
        "these", "those", "both", "some", "lots", "hundreds", "thousands",
    ]

    private static let toVerbTriggers: Set<String> = [
        "can", "could", "will", "would", "should", "must", "may", "might", "shall", "let", "want", "wants", "wanted",
        "need", "needs", "needed", "like", "likes", "liked", "love", "hope", "plan", "decide", "decided", "try",
        "tried", "start", "begin", "learn", "forget", "remember", "promise", "refuse", "manage",
    ]

    private static let verbFamilyIndex: [String: Int] = {
        let families: [[String]] = [
            ["go", "goes", "went", "gone", "going"], ["have", "has", "had", "having"], ["do", "does", "did", "done", "doing"],
            ["say", "says", "said"], ["make", "makes", "made", "making"], ["take", "takes", "took", "taken", "taking"],
            ["come", "comes", "came", "coming"], ["see", "sees", "saw", "seen", "seeing"], ["know", "knows", "knew", "known"],
            ["get", "gets", "got", "gotten", "getting"], ["give", "gives", "gave", "given", "giving"],
            ["find", "finds", "found"], ["think", "thinks", "thought"], ["tell", "tells", "told"],
            ["become", "becomes", "became"], ["leave", "leaves", "left", "leaving"], ["feel", "feels", "felt"],
            ["bring", "brings", "brought"], ["begin", "begins", "began", "begun", "beginning"], ["keep", "keeps", "kept"],
            ["write", "writes", "wrote", "written", "writing"], ["buy", "buys", "bought"],
            ["eat", "eats", "ate", "eaten", "eating"], ["drink", "drinks", "drank", "drunk"],
            ["speak", "speaks", "spoke", "spoken"], ["run", "runs", "ran", "running"], ["sit", "sits", "sat", "sitting"],
            ["lose", "loses", "lost", "losing"], ["meet", "meets", "met"], ["pay", "pays", "paid"], ["send", "sends", "sent"],
            ["build", "builds", "built"], ["choose", "chooses", "chose", "chosen", "choosing"],
            ["forget", "forgets", "forgot", "forgotten"], ["teach", "teaches", "taught"], ["catch", "catches", "caught"],
            ["sleep", "sleeps", "slept"], ["fly", "flies", "flew", "flown"], ["swim", "swims", "swam", "swum"],
            ["win", "wins", "won"], ["lend", "lends", "lent"], ["wear", "wears", "wore", "worn"],
            ["break", "breaks", "broke", "broken"], ["drive", "drives", "drove", "driven"], ["ride", "rides", "rode", "ridden"],
            ["sing", "sings", "sang", "sung"], ["stand", "stands", "stood"], ["understand", "understands", "understood"],
            ["hear", "hears", "heard"],
        ]
        var index: [String: Int] = [:]
        for (family, words) in families.enumerated() {
            for word in words { index[word] = family }
        }
        return index
    }()
}
