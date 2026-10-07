import Foundation
import Observation
import WordwellAICore

/// One role-play run. Holds the transcript and guards against stale model results.
@MainActor
@Observable
final class ConversationSession {
    enum Step { case reply, summary }

    enum Phase: Equatable {
        case chatting
        case replying
        case summarizing
        case summary(ConversationSummary)
        case unavailable
        case failed(Step)
    }

    let scenario: ConversationScenario
    let targetWords: [String]
    private(set) var turns: [ConversationTurn]
    private(set) var phase: Phase = .chatting
    private(set) var objectiveMet = false

    private let service: any ConversationService
    private let learner: LearnerProfile
    private var task: Task<Void, Never>?
    private var activeID: UUID?

    init(scenario: ConversationScenario, targetWords: [String], service: any ConversationService, learner: LearnerProfile) {
        self.scenario = scenario
        self.targetWords = targetWords
        self.service = service
        self.learner = learner
        turns = [ConversationTurn(speaker: .partner, text: scenario.openingLine)]
    }

    var learnerTurnCount: Int { turns.filter { $0.speaker == .learner }.count }
    var canSend: Bool { phase == .chatting && learnerTurnCount < ConversationScenario.maxLearnerTurns }
    var canFinish: Bool { phase == .chatting && learnerTurnCount > 0 }

    func send(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canSend, !trimmed.isEmpty else { return }
        turns.append(ConversationTurn(speaker: .learner, text: trimmed))
        requestReply()
    }

    func finish() {
        guard canFinish else { return }
        requestSummary()
    }

    func retry() {
        switch phase {
        case .failed(.reply): requestReply()
        case .failed(.summary): requestSummary()
        default: break
        }
    }

    func cancel() {
        task?.cancel()
        activeID = nil
    }

    // MARK: - Requests

    private func requestReply() {
        phase = .replying
        let (scenario, targetWords, turns, learner, service) = (scenario, targetWords, turns, learner, service)
        run(onFail: .reply) {
            try await service.reply(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner)
        } apply: { [self] reply in
            self.turns.append(ConversationTurn(speaker: .partner, text: reply.text))
            objectiveMet = objectiveMet || reply.objectiveMet
            phase = .chatting
        }
    }

    private func requestSummary() {
        phase = .summarizing
        let (scenario, targetWords, turns, learner, service) = (scenario, targetWords, turns, learner, service)
        run(onFail: .summary) {
            try await service.summary(scenario: scenario, targetWords: targetWords, turns: turns, learner: learner)
        } apply: { [self] summary in
            phase = .summary(summary)
        }
    }

    /// State changes happen only in `apply`, and only if this request is still the active one.
    private func run<T: Sendable>(onFail step: Step,
                                  fetch: @escaping @Sendable () async throws -> T,
                                  apply: @escaping @MainActor (T) -> Void) {
        task?.cancel()
        let id = UUID()
        activeID = id
        task = Task {
            do {
                let value = try await fetch()
                guard !Task.isCancelled, activeID == id else { return }
                apply(value)
            } catch is CancellationError {
                return
            } catch AIError.unavailable, AIError.unsupportedLanguage {
                if activeID == id { phase = .unavailable }
            } catch {
                if activeID == id { phase = .failed(step) }
            }
        }
    }
}
