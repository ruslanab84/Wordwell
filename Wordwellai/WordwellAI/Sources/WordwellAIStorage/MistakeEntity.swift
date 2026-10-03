#if canImport(SwiftData)
import Foundation
import SwiftData
import WordwellAICore

/// Persistent form of `MistakeRecord`. Learner sentences stay on the device.
@available(iOS 17.0, macOS 14.0, *)
@Model
public final class MistakeEntity {
    @Attribute(.unique) public var id: UUID
    public var wrong: String
    public var right: String
    public var hintRaw: String?
    public var explanation: String?
    public var date: Date
    public var sourceRaw: String

    public init(id: UUID, wrong: String, right: String, hintRaw: String?, explanation: String?,
                date: Date, sourceRaw: String) {
        self.id = id
        self.wrong = wrong
        self.right = right
        self.hintRaw = hintRaw
        self.explanation = explanation
        self.date = date
        self.sourceRaw = sourceRaw
    }

    convenience init(_ record: MistakeRecord) {
        self.init(id: record.id, wrong: record.wrong, right: record.right, hintRaw: record.hint?.rawValue,
                  explanation: record.explanation, date: record.date, sourceRaw: record.source.rawValue)
    }

    var record: MistakeRecord {
        MistakeRecord(id: id, wrong: wrong, right: right,
                      hint: hintRaw.flatMap(SentenceIssue.Kind.init(rawValue:)),
                      explanation: explanation, date: date,
                      source: MistakeRecord.Source(rawValue: sourceRaw) ?? .manual)
    }
}
#endif
