import SwiftUI
import WordwellDesign
import WordwellDomain

struct ProgressScreen: View {
    let progress: any ProgressRepository

    @State private var tab: Section = .overview
    @State private var snapshot: ProgressSnapshot?
    @State private var summary: PracticeSummary?
    @State private var activity: [DailyActivity] = []
    @State private var insights: [String] = []
    @State private var dailyGoal = 10
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var goalError: String?

    private enum Section: String, CaseIterable {
        case overview = "Overview", statistics = "Statistics", goals = "Goals"
    }

    var body: some View {
        FeaturePage(title: "Progress", subtitle: "Your learning journey") {
            tabs

            if isLoading {
                SwiftUI.ProgressView("Loading progress")
            } else if let errorMessage {
                WordwellBodyText(errorMessage, secondary: true)
                Button("Try again") { Task { await load() } }
                    .buttonStyle(WordwellButtonStyle(.secondary))
            } else {
                switch tab {
                case .overview:
                    weeklyInsights
                    weeklyActivity
                    goalProgress
                    Button { tab = .statistics } label: {
                        WordwellListRow(title: "Statistics", detail: "See your learning totals") {
                            Image(systemName: "chart.bar")
                        }
                    }
                    .buttonStyle(.plain)
                    Button { tab = .goals } label: {
                        WordwellListRow(title: "Learning goals", detail: "Adjust your daily target") {
                            Image(systemName: "target")
                        }
                    }
                    .buttonStyle(.plain)
                case .statistics:
                    statistics
                case .goals:
                    goalProgress
                    goalSelector
                    if let goalError { WordwellBodyText(goalError, secondary: true) }
                }
            }
        }
        .task { await load() }
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            ForEach(Section.allCases, id: \.self) { section in
                Button { tab = section } label: {
                    Text(section.rawValue)
                        .font(WordwellType.button)
                        .foregroundStyle(tab == section ? WordwellColor.ink : WordwellColor.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: WordwellLayout.minimumTouchTarget)
                        .overlay(alignment: .bottom) {
                            (tab == section ? WordwellColor.ink : WordwellColor.border)
                                .frame(height: tab == section ? 2 : 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == section ? .isSelected : [])
            }
        }
    }

    @ViewBuilder private var weeklyInsights: some View {
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                heading("This week")
                ForEach(insights, id: \.self) { WordwellBodyText($0) }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(WordwellColor.border, lineWidth: 1))
            .accessibilityElement(children: .combine)
        }
    }

    private var weeklyActivity: some View {
        VStack(alignment: .leading, spacing: 12) {
            heading("Weekly activity")
            let peak = max(activity.map(\.minutes).max() ?? 0, 1)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(activity, id: \.date) { day in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(WordwellColor.ink)
                            .frame(height: max(CGFloat(day.minutes) / CGFloat(peak) * 100, 2))
                        Text(day.date.formatted(.dateTime.weekday(.abbreviated)))
                            .font(WordwellType.meta)
                            .foregroundStyle(WordwellColor.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(day.date.formatted(date: .complete, time: .omitted)), \(day.minutes) minutes")
                }
            }
            .frame(height: 132, alignment: .bottom)
            WordwellBodyText("Minutes spent reviewing and speaking in the last seven days.", secondary: true)
        }
    }

    private var statistics: some View {
        VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
            heading("Key statistics")
            statRow("Words learned", value: String(snapshot?.wordsLearned ?? 0))
            statRow("Words reviewed", value: String(snapshot?.wordsReviewed ?? 0))
            statRow("Speaking sessions", value: String(snapshot?.speakingSessions ?? 0))
            statRow("Listening time", value: "\(snapshot?.listeningMinutes ?? 0) minutes")
            statRow("Quiz accuracy", value: snapshot?.quizAccuracy.map { $0.formatted(.percent.precision(.fractionLength(0))) } ?? "Unavailable")
            if snapshot?.quizAccuracy == nil {
                WordwellBodyText("Quiz accuracy appears after your first answer.", secondary: true)
            }
        }
    }

    private var goalProgress: some View {
        VStack(alignment: .leading, spacing: 10) {
            heading("Learning goals")
            let minutes = summary?.minutesToday ?? 0
            Text("\(minutes) of \(dailyGoal) minutes today")
                .font(WordwellType.body)
                .foregroundStyle(WordwellColor.ink)
            SwiftUI.ProgressView(value: min(Double(minutes) / Double(dailyGoal), 1))
                .tint(WordwellColor.ink)
                .accessibilityLabel("Daily learning goal")
                .accessibilityValue("\(minutes) of \(dailyGoal) minutes")
        }
    }

    private var goalSelector: some View {
        Menu {
            ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { minutes in
                Button("\(minutes) minutes") { Task { await saveGoal(minutes) } }
            }
        } label: {
            WordwellListRow(title: "Daily goal", detail: "\(dailyGoal) minutes") {
                Image(systemName: "clock")
            }
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text)
            .font(WordwellType.cardHeadline)
            .foregroundStyle(WordwellColor.ink)
            .accessibilityAddTraits(.isHeader)
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(WordwellColor.ink)
            Spacer()
            Text(value).foregroundStyle(WordwellColor.secondaryText)
        }
        .font(WordwellType.body)
        .padding(.vertical, WordwellLayout.rowPadding)
        .overlay(alignment: .bottom) { WordwellColor.border.frame(height: 1) }
        .accessibilityElement(children: .combine)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            snapshot = try await progress.snapshot()
            summary = try await progress.practiceSummary()
            activity = try await progress.weeklyActivity()
            insights = WeeklyInsights.make(from: try await progress.weeklyReport())
            dailyGoal = try await progress.dailyGoalMinutes()
            errorMessage = nil
        } catch {
            errorMessage = "Your progress could not be loaded. Please try again."
        }
    }

    private func saveGoal(_ minutes: Int) async {
        do {
            try await progress.setDailyGoalMinutes(minutes)
            dailyGoal = minutes
            goalError = nil
        } catch {
            goalError = "Your daily goal could not be saved. Please try again."
        }
    }
}
