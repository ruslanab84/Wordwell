#if canImport(FoundationModels)
import Foundation
import FoundationModels
import WordwellAICore

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GConversationReply {
    @Guide(description: "The partner's next line, one or two short sentences")
    var reply: String
    var objectiveMet: Bool
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GConversationMistake {
    @Guide(description: "Exact fragment copied from a learner line")
    var original: String
    @Guide(description: "Corrected version of that fragment")
    var better: String
    @Guide(description: "One short sentence explaining the error")
    var why: String
}

@available(iOS 26.0, macOS 26.0, *)
@Generable
struct GConversationSummary {
    @Guide(description: "Real errors only; empty if there are none", .maximumCount(4))
    var mistakes: [GConversationMistake]
    @Guide(description: "Useful natural phrases for this situation", .maximumCount(5))
    var expressions: [String]
    @Guide(description: "Single dictionary words in base form", .maximumCount(6))
    var wordsToSave: [String]
    var objectiveMet: Bool
}
#endif
