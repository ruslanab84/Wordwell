import Foundation
import UserNotifications
import WordwellDomain

enum DailyWordNotificationError: Error {
    case permissionDenied
    case insufficientWords
    case schedulingFailed
}

@MainActor
final class DailyWordNotifications {
    private let center = UNUserNotificationCenter.current()
    private let dictionary: any DictionaryRepository
    private let library: any WordLibraryRepository
    private let defaults = UserDefaults.standard
    private let historyKey = "wordwell.notifiedWords"
    private let prefix = "wordwell.dailyWord."

    init(dictionary: any DictionaryRepository, library: any WordLibraryRepository) {
        self.dictionary = dictionary
        self.library = library
    }

    func ensureAuthorization() async throws {
        var status = await center.notificationSettings().authorizationStatus
        if status == .notDetermined {
            _ = try await center.requestAuthorization(options: [.alert, .sound])
            status = await center.notificationSettings().authorizationStatus
        }
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            throw DailyWordNotificationError.permissionDenied
        }
    }

    func refresh(for profile: LearningProfile, reset: Bool = false) async throws {
        let pending = await center.pendingNotificationRequests().filter { $0.identifier.hasPrefix(prefix) }
        guard profile.newWordsPerDay > 0 else {
            try await removePending(pending.map(\.identifier))
            return
        }

        guard profile.newWordsPerDay <= 20 else { throw DailyWordNotificationError.insufficientWords }
        let status = await center.notificationSettings().authorizationStatus
        guard status == .authorized || status == .provisional || status == .ephemeral else {
            throw DailyWordNotificationError.permissionDenied
        }

        let outdated = reset || pending.contains {
            ($0.content.userInfo["count"] as? Int) != profile.newWordsPerDay ||
                ($0.content.userInfo["variant"] as? String) != profile.preferredEnglishVariant.rawValue ||
                ($0.content.userInfo["topic"] as? String) != profile.wordTopicID
        }
        let existing = outdated ? [] : pending
        let existingIDs = Set(existing.map(\.identifier))
        var targets: [(String, DateComponents)] = []
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: .now)!)

        // ponytail: iOS keeps a limited pending queue; refill it when the app becomes active.
        schedule: for day in 0..<60 {
            let date = calendar.date(byAdding: .day, value: day, to: tomorrow)!
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let dayID = String(format: "%04d%02d%02d", components.year!, components.month!, components.day!)
            for slot in 0..<profile.newWordsPerDay {
                let id = "\(prefix)\(dayID).\(slot)"
                if existingIDs.contains(id) { continue }
                if existing.count + targets.count == 60 { break schedule }
                let minuteOfDay = 9 * 60 + slot * 11 * 60 / max(profile.newWordsPerDay - 1, 1)
                var delivery = components
                delivery.hour = minuteOfDay / 60
                delivery.minute = minuteOfDay % 60
                targets.append((id, delivery))
            }
        }
        guard !targets.isEmpty else { return }

        var history = Set(defaults.stringArray(forKey: historyKey) ?? [])
        defer { defaults.set(Array(history), forKey: historyKey) }
        let saved = try await library.allSavedWords()
        history.formUnion(saved.map(\.wordID))
        history.formUnion(existing.compactMap { $0.content.userInfo["wordID"] as? String })
        let topicIDs = VocabularyTopic.all.first { $0.id == profile.wordTopicID }.map { Set($0.wordIDs) }
        var words = try await dictionary.notificationEntries(excluding: history, limit: targets.count, among: topicIDs)
        if let topicIDs, words.count < targets.count {
            // ponytail: a topic has ~40 usable words; once used up they repeat. Widen the topic lists if that annoys.
            let pending = Set(existing.compactMap { $0.content.userInfo["wordID"] as? String })
            let pool = try await dictionary.notificationEntries(excluding: pending, limit: topicIDs.count, among: topicIDs)
            guard !pool.isEmpty else { throw DailyWordNotificationError.insufficientWords }
            words += (0..<targets.count - words.count).map { pool[$0 % pool.count] }
        }
        guard words.count == targets.count else { throw DailyWordNotificationError.insufficientWords }

        if outdated {
            let targetIDs = Set(targets.map(\.0))
            try await removePending(pending.map(\.identifier).filter { !targetIDs.contains($0) })
        }

        for ((id, date), word) in zip(targets, words) {
            let ipa: String
            switch profile.preferredEnglishVariant {
            case .uk: ipa = word.ipaUK ?? word.ipaUS ?? ""
            case .us, .both: ipa = word.ipaUS ?? word.ipaUK ?? ""
            }
            let content = UNMutableNotificationContent()
            content.title = "\(word.word) /\(ipa)/"
            content.body = word.senses.first?.definition ?? "Open Wordwell to learn this word."
            content.sound = .default
            content.threadIdentifier = "wordwell.dailyWords"
            content.userInfo = ["wordID": word.id, "count": profile.newWordsPerDay,
                                "variant": profile.preferredEnglishVariant.rawValue]
            if let topic = profile.wordTopicID { content.userInfo["topic"] = topic }
            try await center.add(UNNotificationRequest(
                identifier: id, content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            ))
            history.insert(word.lemma.lowercased())
        }
        let scheduled = Set(await center.pendingNotificationRequests().map(\.identifier))
        guard Set(targets.map(\.0)).isSubset(of: scheduled) else {
            throw DailyWordNotificationError.schedulingFailed
        }
    }

    private func removePending(_ ids: [String]) async throws {
        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        let removed = Set(ids)
        for _ in 0..<20 {
            if await center.pendingNotificationRequests().allSatisfy({ !removed.contains($0.identifier) }) {
                return
            }
            try await Task.sleep(for: .milliseconds(100))
        }
        throw DailyWordNotificationError.schedulingFailed
    }
}

@MainActor
final class DailyWordNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let router: AppRouter

    init(router: AppRouter) { self.router = router }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
    ) async {
        guard let wordID = response.notification.request.content.userInfo["wordID"] as? String else { return }
        router.selection = .home
        router.openWord(id: wordID)
    }
}
