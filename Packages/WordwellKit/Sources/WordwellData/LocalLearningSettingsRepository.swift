import Foundation
import WordwellDomain

public actor LocalLearningSettingsRepository: LearningSettingsRepository {
    private let defaults: UserDefaults
    private let key = "wordwell.learningProfile"

    public init(suiteName: String? = nil) {
        defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    public func hasSavedProfile() throws -> Bool {
        guard let data = defaults.data(forKey: key) else { return false }
        _ = try JSONDecoder().decode(LearningProfile.self, from: data)
        return true
    }

    public func profile() throws -> LearningProfile {
        if let data = defaults.data(forKey: key) {
            return try JSONDecoder().decode(LearningProfile.self, from: data)
        }
        return LearningProfile(cefrLevel: .b1, explanationLanguage: "en",
                               preferredEnglishVariant: .both, dailyGoalMinutes: 10)
    }

    public func save(_ profile: LearningProfile) throws {
        defaults.set(try JSONEncoder().encode(profile), forKey: key)
    }
}
