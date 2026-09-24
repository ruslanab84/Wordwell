import SwiftUI
import WordwellAICore
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
    let ai: any LearningAI
    let notifications: DailyWordNotifications
    @Binding var appearance: AppAppearance

    @State private var profile: LearningProfile?
    @State private var aiAvailable = false
    @State private var loadFailed = false
    @State private var saveFailed = false
    @State private var saving = false
    @State private var notificationFailed = false
    @State private var permissionDenied = false

    private let languages = ["en": "English", "ru": "Russian", "az": "Azerbaijani",
                             "es": "Spanish", "fr": "French", "de": "German"]

    var body: some View {
        FeaturePage(title: "Settings", subtitle: "Make Wordwell work for you") {
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
                Menu {
                    ForEach(languages.keys.sorted(), id: \.self) { code in
                        Button(languages[code] ?? code) { change { $0.explanationLanguage = code } }
                    }
                } label: {
                    WordwellListRow(title: "Explanation language",
                                    detail: languages[profile.explanationLanguage] ?? profile.explanationLanguage) {
                        Image(systemName: "globe")
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
                WordwellBodyText("Starting tomorrow, get a word with its transcription in each notification, between 9 AM and 8 PM. Open Wordwell every few days to keep new words scheduled.", secondary: true)

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

                sectionTitle("On-device AI")
                Toggle("On-device AI (Apple Intelligence)", isOn: Binding(
                    get: { profile.aiEnabled && aiAvailable },
                    set: { enabled in change { $0.aiEnabled = enabled } }
                ))
                .toggleStyle(WordwellToggleStyle())
                .disabled(!aiAvailable || saving)
                WordwellBodyText(aiAvailable
                    ? "Runs entirely on this device. You can turn it off at any time."
                    : "Apple Intelligence is unavailable on this device. Dictionary and practice still work offline.", secondary: true)
            } else {
                ProgressView("Loading settings")
            }
        }
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
            Text("Your choice was saved. Open Wordwell again to retry scheduling notifications.")
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
            profile = loaded
            aiAvailable = await ai.availability(languageCode: "en") == .available
            loadFailed = false
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
                    changed.preferredEnglishVariant != profile?.preferredEnglishVariant
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
