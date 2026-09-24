import Foundation
import Observation
import WordwellDomain

public enum EntryAIAction: Sendable {
    case explainSimply
    case explainInUserLanguage
    case moreExamples
}

public enum EntryAIResult: Equatable, Sendable {
    case simple(SimpleExplanation)
    case localized(LocalizedExplanation)
    case examples([GeneratedExample])
}

public enum EntryAIPhase: Equatable, Sendable {
    case idle
    case loading
    case success(EntryAIResult)
    case unavailable(AIUnavailableReason)
    case failed
}

@MainActor @Observable
public final class EntryAICoach {
    public private(set) var phase: EntryAIPhase = .idle
    private let service: any LanguageAIService
    private var activeID: UUID?

    public init(service: any LanguageAIService) {
        self.service = service
    }

    public func run(_ action: EntryAIAction, entry: WordEntry, senseID: String, context: AIContext) async {
        let id = UUID()
        activeID = id
        phase = .loading
        let language = action == .explainInUserLanguage ? context.profile.explanationLanguage : "en"
        do {
            switch await service.availability(for: language) {
            case .available: break
            case .unavailable(let reason):
                try Task.checkCancellation()
                if activeID == id { phase = .unavailable(reason) }
                return
            }
            let result: EntryAIResult
            switch action {
            case .explainSimply:
                result = .simple(try await service.explainSimply(entry: entry, senseID: senseID, context: context))
            case .explainInUserLanguage:
                result = .localized(try await service.explainInUserLanguage(entry: entry, senseID: senseID, context: context))
            case .moreExamples:
                result = .examples(try await service.generateExamples(entry: entry, senseID: senseID, context: context, count: 2))
            }
            try Task.checkCancellation()
            if activeID == id { phase = .success(result) }
        } catch is CancellationError {
            if activeID == id { phase = .idle }
        } catch let error as AIServiceError {
            guard activeID == id else { return }
            if Task.isCancelled {
                phase = .idle
            } else if case .unavailable(let reason) = error {
                phase = .unavailable(reason)
            } else {
                phase = .failed
            }
        } catch {
            if activeID == id { phase = Task.isCancelled ? .idle : .failed }
        }
    }

    public func clear() {
        activeID = nil
        phase = .idle
    }
}
