import Foundation

/// Deterministic checks for a generated mini-lesson. The classifier verifies exercises for
/// rule-based patterns, so a model that "teaches" the wrong thing is rejected automatically.
public struct MistakeLessonValidator: Sendable {
    public init() {}

    public func validate(_ content: MiniLessonContent, pattern: MistakePattern,
                         examples: [MistakeRecord]) throws -> MiniLessonContent {
        guard let title = content.title.nilIfBlank, let rule = content.rule.nilIfBlank else {
            throw AIError.invalidResponse("empty lesson")
        }
        guard rule.count <= 320 else { throw AIError.invalidResponse("rule too long") }

        // Exercises must be new: never copy the learner's own sentences back at them.
        let own = Set(examples.flatMap { [$0.wrong, $0.right] }.map(\.normalizedForComparison))
        var seen = Set<String>()

        let exercises = content.exercises.filter { exercise in
            guard let incorrect = exercise.incorrect.nilIfBlank, let correct = exercise.correct.nilIfBlank else { return false }
            let wrongKey = incorrect.normalizedForComparison
            let rightKey = correct.normalizedForComparison
            guard wrongKey != rightKey, !own.contains(wrongKey), !own.contains(rightKey),
                  seen.insert(wrongKey).inserted else { return false }
            return !pattern.isRuleVerifiable || MistakeClassifier.classify(wrong: incorrect, right: correct) == pattern
        }
        guard exercises.count >= 2 else { throw AIError.invalidResponse("too few verified exercises") }

        return MiniLessonContent(title: title, rule: rule, tip: content.tip?.nilIfBlank,
                                 exercises: Array(exercises.prefix(4)))
    }
}

/// Mistakes notebook → ranked patterns → one weekly mini-lesson on the most costly pattern.
public struct MistakeCoach: Sendable {
    public let analyzer: MistakePatternAnalyzer
    private let service: any MistakeLessonService
    private let validator = MistakeLessonValidator()
    private let maxAttempts: Int

    public init(service: any MistakeLessonService, analyzer: MistakePatternAnalyzer = MistakePatternAnalyzer(),
                maxAttempts: Int = 2) {
        self.service = service
        self.analyzer = analyzer
        self.maxAttempts = max(1, maxAttempts)
    }

    /// Works fully offline: no model involved.
    public func report(_ records: [MistakeRecord], now: Date = Date()) -> [PatternStat] {
        analyzer.analyze(records, now: now)
    }

    /// Returns nil when nothing qualifies (not enough evidence, or only unclassified mistakes).
    public func weeklyLesson(from records: [MistakeRecord], now: Date = Date(), learner: LearnerProfile,
                             pattern: MistakePattern? = nil) async throws -> WeeklyMistakeLesson? {
        let stats = analyzer.analyze(records, now: now)
        let target: PatternStat?
        if let pattern {
            target = pattern == .other ? nil : stats.first { $0.pattern == pattern }
        } else {
            target = analyzer.lessonCandidate(in: stats)
        }
        guard let stat = target else { return nil }

        var lastError = AIError.invalidResponse("no attempts")
        for _ in 0..<maxAttempts {
            do {
                let raw = try await service.lesson(for: stat.pattern, examples: stat.examples, learner: learner)
                let content = try validator.validate(raw, pattern: stat.pattern, examples: stat.examples)
                return WeeklyMistakeLesson(pattern: stat.pattern, stat: stat, content: content, generatedAt: now)
            } catch AIError.invalidResponse(let reason) {
                lastError = .invalidResponse(reason)
            }
        }
        throw lastError
    }
}
