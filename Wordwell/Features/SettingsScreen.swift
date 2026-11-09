import SwiftUI
import WordwellAICore
import WordwellAIFoundationModels
import WordwellDesign
import WordwellDomain

enum AppAppearance: String, CaseIterable {
    case system, light, dark

    var title: String { rawValue.capitalized }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct SettingsScreen: View {
    let settings: any LearningSettingsRepository
    let progress: any ProgressRepository
    let notifications: DailyWordNotifications
    @Binding var appearance: AppAppearance

    @Environment(\.aiDeviceStatus) private var aiStatus
    @State private var profile: LearningProfile?
    @State private var loadFailed = false
    @State private var saveFailed = false
    @State private var saving = false
    @State private var premium = PremiumAccess.shared
    @State private var notificationFailed = false
    @State private var permissionDenied = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        FeaturePage(title: "Settings", subtitle: "Make Verbalex work for you") {
            if loadFailed {
                WordwellBodyText("Settings could not be loaded.", secondary: true)
                Button("Try again") { Task { await load() } }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else if let profile {
                sectionTitle("Learning")
                Menu {
                    ForEach(CEFRLevel.allCases, id: \.self) { level in
                        Button(level.rawValue) { change { $0.cefrLevel = level } }
                    }
                } label: {
                    WordwellListRow(title: "English level", detail: profile.cefrLevel.rawValue) {
                        Image(systemName: "text.book.closed")
                    }
                }
                if aiStatus.showsAI {
                    Menu {
                        ForEach(onDeviceSupportedLanguages(SupportedLanguages.all), id: \.code) { language in
                            Button(language.name) { change { $0.explanationLanguage = language.code } }
                        }
                    } label: {
                        WordwellListRow(title: "Explanation language",
                                        detail: SupportedLanguages.name(for: profile.explanationLanguage)) {
                            Image(systemName: "globe")
                        }
                    }
                }
                Menu {
                    Button("UK") { change { $0.preferredEnglishVariant = .uk } }
                    Button("US") { change { $0.preferredEnglishVariant = .us } }
                    Button("Both") { change { $0.preferredEnglishVariant = .both } }
                } label: {
                    WordwellListRow(title: "Pronunciation", detail: profile.preferredEnglishVariant.rawValue.uppercased()) {
                        Image(systemName: "speaker.wave.2")
                    }
                }
                Menu {
                    ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { minutes in
                        Button("\(minutes) minutes") { change { $0.dailyGoalMinutes = minutes } }
                    }
                } label: {
                    WordwellListRow(title: "Daily goal", detail: "\(profile.dailyGoalMinutes) minutes") {
                        Image(systemName: "clock")
                    }
                }
                Menu {
                    ForEach(0...20, id: \.self) { count in
                        Button(count == 0 ? "Off" : "\(count) words") {
                            change { $0.newWordsPerDay = count }
                        }
                    }
                } label: {
                    WordwellListRow(title: "Word notifications per day",
                                    detail: profile.newWordsPerDay == 0 ? "Off" : "\(profile.newWordsPerDay) words") {
                        Image(systemName: "bell")
                    }
                }
                WordwellBodyText("Starting tomorrow, get a word with its transcription in each notification, between 9 AM and 8 PM. Open Verbalex every few days to keep new words scheduled.", secondary: true)
                if premium.isPremium {
                    Menu {
                        Button("All topics") { change { $0.wordTopicID = nil } }
                        ForEach(VocabularyTopic.all) { topic in
                            Button(topic.title, systemImage: topic.symbol) { change { $0.wordTopicID = topic.id } }
                        }
                    } label: {
                        let topic = VocabularyTopic.all.first { $0.id == profile.wordTopicID }
                        WordwellListRow(title: "Word topic", detail: topic?.title ?? "All topics") {
                            Image(systemName: topic?.symbol ?? "square.grid.2x2")
                        }
                    }
                } else {
                    Button { premium.showPaywall() } label: {
                        WordwellListRow(title: "Word topic", detail: "Premium") {
                            Image(systemName: "lock")
                        }
                    }
                    .buttonStyle(.plain)
                }
                WordwellBodyText("Words on Home and in notifications come from this topic.", secondary: true)

                sectionTitle("Appearance")
                Menu {
                    ForEach(AppAppearance.allCases, id: \.self) { option in
                        Button(option.title) { appearance = option }
                    }
                } label: {
                    WordwellListRow(title: "Theme", detail: appearance.title) {
                        Image(systemName: "circle.lefthalf.filled")
                    }
                }

                if aiStatus.showsAI {
                    sectionTitle("On-device AI")
                    Toggle("On-device AI (Apple Intelligence)", isOn: Binding(
                        get: { profile.aiEnabled && aiStatus == .ready },
                        set: { enabled in change { $0.aiEnabled = enabled } }
                    ))
                    .toggleStyle(WordwellToggleStyle())
                    .disabled(aiStatus != .ready || saving)
                    WordwellBodyText(aiStatus == .ready
                        ? "Runs entirely on this device. You can turn it off at any time."
                        : aiStatus.message, secondary: true)
                }

                sectionTitle("Privacy")
                Button { showPrivacyPolicy = true } label: {
                    WordwellListRow(title: "Privacy Policy", detail: "How Verbalex handles your data") {
                        Image(systemName: "hand.raised")
                    }
                }
                .buttonStyle(.plain)
                #if DEBUG
                sectionTitle("Debug")
                Toggle("Force Premium", isOn: $premium.debugForcePremium)
                    .toggleStyle(WordwellToggleStyle())
                #endif
            } else {
                ProgressView("Loading settings")
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) { PrivacyPolicyScreen() }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .alert("Could not save settings", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again. Your previous settings are still in use.")
        }
        .alert("Notifications unavailable", isPresented: $permissionDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Allow notifications in iOS Settings to receive new words.")
        }
        .alert("Could not schedule words", isPresented: $notificationFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your choice was saved. Open Verbalex again to retry scheduling notifications.")
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(WordwellType.cardHeadline)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func load() async {
        do {
            var loaded = try await settings.profile()
            loaded.dailyGoalMinutes = try await progress.dailyGoalMinutes()
            let supported = onDeviceSupportedLanguages(SupportedLanguages.all).map(\.code)
            let needsLanguageReset = !supported.contains(loaded.explanationLanguage)
            profile = loaded
            loadFailed = false
            // The model reports no languages while Apple Intelligence is off; keep the learner's choice.
            if needsLanguageReset, aiStatus == .ready { change { $0.explanationLanguage = "en" } }
        } catch {
            loadFailed = true
        }
    }

    private func change(_ update: @escaping (inout LearningProfile) -> Void) {
        guard var changed = profile, !saving else { return }
        update(&changed)
        saving = true
        Task {
            do {
                let notificationChanged = changed.newWordsPerDay != profile?.newWordsPerDay ||
                    changed.preferredEnglishVariant != profile?.preferredEnglishVariant ||
                    changed.wordTopicID != profile?.wordTopicID
                if notificationChanged && changed.newWordsPerDay > 0 {
                    try await notifications.ensureAuthorization()
                }
                if changed.dailyGoalMinutes != profile?.dailyGoalMinutes {
                    try await progress.setDailyGoalMinutes(changed.dailyGoalMinutes)
                }
                try await settings.save(changed)
                profile = changed
                if notificationChanged {
                    do { try await notifications.refresh(for: changed, reset: true) }
                    catch DailyWordNotificationError.permissionDenied { permissionDenied = true }
                    catch { notificationFailed = true }
                }
            } catch DailyWordNotificationError.permissionDenied {
                permissionDenied = true
            } catch {
                saveFailed = true
                await load()
            }
            saving = false
        }
    }
}

private struct PrivacyPolicyScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let sections: [(String, String)] = [
        ("Summary", "Verbalex has no accounts, advertising, analytics or tracking. The app does not send your data to us or to anyone else."),
        ("Data on your device", "Your level, settings, saved words, search history and practice progress are stored only on this device. Deleting the app deletes them. Device backups you make may include them."),
        ("Microphone and speech", "If you use speaking practice, iOS asks for access to the microphone and speech recognition. Your speech is transcribed on this device and is not sent to us."),
        ("On-device AI", "AI features use Apple Intelligence models that run on this device. Your text is not sent to us or to a third-party AI service."),
        ("Notifications", "Word notifications are scheduled on this device. You can turn them off in Settings."),
        ("Subscriptions", "Apple processes purchases and manages subscriptions under its own privacy policy. We do not receive your payment details."),
        ("Contact", "For privacy questions, use the support link on the Verbalex App Store page."),
    ]

    var body: some View {
        NavigationStack {
            FeaturePage(title: "Privacy Policy", subtitle: "Last updated November 9, 2026") {
                ForEach(sections, id: \.0) { heading, text in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(heading)
                            .font(WordwellType.cardHeadline)
                            .foregroundStyle(WordwellColor.ink)
                            .accessibilityAddTraits(.isHeader)
                        WordwellBodyText(text)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
