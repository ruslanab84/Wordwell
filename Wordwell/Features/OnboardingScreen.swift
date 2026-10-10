import SwiftUI
import WordwellAIFoundationModels
import WordwellDesign
import WordwellDomain

struct OnboardingScreen: View {
    let settings: any LearningSettingsRepository
    let progress: any ProgressRepository
    let notifications: DailyWordNotifications
    let onComplete: () -> Void

    @State private var step = 0
    @State private var level: CEFRLevel?
    @State private var minutesPerDay = 10
    @State private var explanationLanguage = "en"
    @State private var variant: EnglishVariant = .both
    @State private var wantsNotifications = false
    @State private var saving = false
    @State private var saved = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                Text("Verbalex")
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                Text("Step \(step + 1) of 3")
                    .font(WordwellType.sectionLabel)
                    .foregroundStyle(WordwellColor.secondaryText)
                switch step {
                case 0: levelStep
                case 1: preferencesStep
                default: notificationStep
                }
                if let errorMessage {
                    WordwellBodyText(errorMessage, secondary: true)
                        .accessibilityAddTraits(.updatesFrequently)
                }
            }
            .padding(WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                if step > 0 && !saved {
                    Button("Back") {
                        errorMessage = nil
                        step -= 1
                    }
                    .buttonStyle(WordwellButtonStyle(.secondary))
                }
                Button(saved ? "Continue" : step == 2 ? "Start learning" : "Continue") {
                    if saved {
                        onComplete()
                    } else if step < 2 {
                        errorMessage = nil
                        step += 1
                    } else {
                        Task { await finish() }
                    }
                }
                .buttonStyle(WordwellButtonStyle(.primary))
                .disabled(saving || (step == 0 && level == nil))
                .opacity(saving || (step == 0 && level == nil) ? 0.45 : 1)
                .frame(maxWidth: .infinity)
            }
            .padding(WordwellLayout.screenPadding)
            .background(WordwellColor.paper)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
    }

    private var levelStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            heading("What is your English level?")
            WordwellBodyText("Choose the level that feels closest. You can change it later in Settings.", secondary: true)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(CEFRLevel.allCases, id: \.self) { option in
                    choice(option.rawValue, value: Optional(option), selection: $level)
                }
            }
        }
    }

    private var preferencesStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Make learning yours")
            Picker("Explanation language", selection: $explanationLanguage) {
                ForEach(onDeviceSupportedLanguages(SupportedLanguages.all), id: \.code) { language in
                    Text(language.name).tag(language.code)
                }
            }
            Picker("Pronunciation", selection: $variant) {
                Text("UK").tag(EnglishVariant.uk)
                Text("US").tag(EnglishVariant.us)
                Text("Both").tag(EnglishVariant.both)
            }
            Picker("Minutes per day", selection: $minutesPerDay) {
                ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { minutes in
                    Text("\(minutes) minutes").tag(minutes)
                }
            }
        }
        .font(WordwellType.body)
        .tint(WordwellColor.ink)
    }

    private var notificationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            heading("A word to keep you going")
            WordwellBodyText("Would you like one new word by notification each day? You can change this later in Settings.", secondary: true)
            Toggle("Daily word notification", isOn: $wantsNotifications)
                .toggleStyle(WordwellToggleStyle())
                .disabled(saved)
        }
    }

    private func heading(_ title: String) -> some View {
        Text(title)
            .font(WordwellType.cardHeadline)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func choice<T: Equatable>(_ title: String, value: T, selection: Binding<T>) -> some View {
        Button(title) { selection.wrappedValue = value }
            .buttonStyle(WordwellButtonStyle(selection.wrappedValue == value ? .primary : .secondary))
            .accessibilityAddTraits(selection.wrappedValue == value ? .isSelected : [])
    }

    private func finish() async {
        guard let level, !saving else { return }
        saving = true
        defer { saving = false }
        errorMessage = nil
        if wantsNotifications {
            do {
                try await notifications.ensureAuthorization()
            } catch DailyWordNotificationError.permissionDenied {
                wantsNotifications = false
                errorMessage = "Notifications are off. Tap Start learning again to continue without them."
                return
            } catch {
                errorMessage = "Notification permission could not be checked. Try again or turn notifications off."
                return
            }
        }

        let profile = LearningProfile(cefrLevel: level, explanationLanguage: explanationLanguage,
                                      preferredEnglishVariant: variant, dailyGoalMinutes: minutesPerDay,
                                      newWordsPerDay: wantsNotifications ? 1 : 0)
        do {
            try await progress.setDailyGoalMinutes(minutesPerDay)
            try await settings.save(profile)
        } catch {
            errorMessage = "Your settings could not be saved. Please try again."
            return
        }

        if wantsNotifications {
            do {
                try await notifications.refresh(for: profile, reset: true)
            } catch {
                saved = true
                errorMessage = "Your settings were saved, but the word notification could not be scheduled. You can retry in Settings."
                return
            }
        }
        onComplete()
    }
}
