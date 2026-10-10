//
//  WordwellApp.swift
//  Verbalex
//
//  Created by Ruslan Abdulov on 24.09.26.
//

import SwiftUI
import UserNotifications
import WordwellDesign
import WordwellDomain

@main
struct WordwellApp: App {
    private let container = AppContainer.live
    private let notificationDelegate: DailyWordNotificationDelegate

    init() {
        WordwellFonts.register()
        let delegate = DailyWordNotificationDelegate(router: container.router)
        notificationDelegate = delegate
        UNUserNotificationCenter.current().delegate = delegate
    }

    var body: some Scene {
        WindowGroup {
            AppLaunchView(container: container)
        }
    }
}

private struct AppLaunchView: View {
    let container: AppContainer
    @AppStorage("wordwell.onboardingCompleted") private var onboardingCompleted = false
    @State private var checkedExistingProfile = false
    @State private var checkFailed = false

    var body: some View {
        Group {
            if onboardingCompleted {
                ContentView(container: container)
            } else if checkFailed {
                ContentUnavailableView {
                    Label("Setup unavailable", systemImage: "book.closed")
                } description: {
                    Text("Your learning settings could not be loaded.")
                } actions: {
                    Button("Try again") { Task { await checkProfile() } }
                }
            } else if checkedExistingProfile {
                OnboardingScreen(settings: container.settingsRepository,
                                 progress: container.progressRepository,
                                 notifications: DailyWordNotifications(dictionary: container.dictionaryRepository,
                                                                       library: container.libraryRepository)) {
                    onboardingCompleted = true
                }
            } else {
                ProgressView("Loading Verbalex")
            }
        }
        .task { await checkProfile() }
    }

    private func checkProfile() async {
        guard !onboardingCompleted else { return }
        do {
            if try await container.settingsRepository.hasSavedProfile() {
                onboardingCompleted = true
            } else {
                checkedExistingProfile = true
            }
            checkFailed = false
        } catch {
            checkFailed = true
        }
    }
}
