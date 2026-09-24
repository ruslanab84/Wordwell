import SwiftUI
import WordwellAICore
import WordwellAIFoundationModels
import WordwellData
import WordwellDesign
import WordwellDomain

struct GrammarScreen: View {
    let settings: any LearningSettingsRepository

    var body: some View {
        FeaturePage(title: "Grammar", subtitle: "Clear explanations, examples, and pictures") {
            ForEach(GrammarCategory.allCases) { category in
                NavigationLink {
                    GrammarCategoryScreen(category: category, settings: settings)
                } label: {
                    WordwellListRow(title: category.rawValue,
                                    detail: "\(category.expectedLessonCount) lessons · \(category.summary)") {
                        Image(systemName: category.symbol)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct GrammarCategoryScreen: View {
    let category: GrammarCategory
    let settings: any LearningSettingsRepository
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        FeaturePage(title: category.rawValue, subtitle: category.summary) {
            WordwellCard {
                WordwellBodyText(category.overview)
            }

            Text("Explore the lessons")
                .font(WordwellType.cardHeadline)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)

            ForEach(GrammarCatalog.lessons(in: category)) { lesson in
                NavigationLink {
                    GrammarLessonScreen(lesson: lesson, settings: settings)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: category.symbol)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(WordwellColor.lineArt)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            if dynamicTypeSize.isAccessibilitySize {
                                VStack(alignment: .leading, spacing: 4) { lessonHeading(lesson) }
                            } else {
                                HStack(alignment: .firstTextBaseline, spacing: 8) { lessonHeading(lesson) }
                            }
                            Text(lesson.summary)
                                .font(WordwellType.meta)
                                .foregroundStyle(WordwellColor.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WordwellColor.mutedIcon)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, WordwellLayout.rowPadding)
                    .frame(minHeight: WordwellLayout.minimumTouchTarget)
                    .overlay(alignment: .bottom) { WordwellColor.border.frame(height: 1) }
                    .accessibilityElement(children: .combine)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func lessonHeading(_ lesson: GrammarLesson) -> some View {
        Text(lesson.title)
            .font(WordwellType.body)
            .foregroundStyle(WordwellColor.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
        levelBadge(for: lesson.level)
    }
}

private struct GrammarLessonScreen: View {
    let lesson: GrammarLesson
    let settings: any LearningSettingsRepository
    @State private var aiAccess: AIAccess = .checking
    @State private var aiPhase: AIPhase = .idle
    @State private var aiTask: Task<Void, Never>?

    private enum AIAccess { case checking, ready, disabled, unavailable, failed }
    private enum AIPhase: Equatable { case idle, loading, answer(String), unavailable, failed }

    var body: some View {
        FeaturePage(title: lesson.title, subtitle: lesson.summary) {
            levelBadge(for: lesson.level)

            WordwellCard {
                VStack(alignment: .leading, spacing: 12) {
                    GrammarPicture(diagram: lesson.diagram, caption: lesson.diagramCaption)
                    Text(lesson.diagramCaption)
                        .font(WordwellType.meta)
                        .foregroundStyle(WordwellColor.secondaryText)
                        .accessibilityHidden(true)
                }
            }

            section("When to use it") { WordwellBodyText(lesson.use) }
            section("How to form it") { WordwellBodyText(lesson.form) }
            section("Examples") {
                ForEach(lesson.examples.indices, id: \.self) { index in
                    let example = lesson.examples[index]
                    VStack(alignment: .leading, spacing: 3) {
                        Text(example.sentence)
                            .font(WordwellType.body.weight(.semibold))
                            .foregroundStyle(WordwellColor.ink)
                        Text(example.meaning)
                            .font(WordwellType.meta)
                            .foregroundStyle(WordwellColor.secondaryText)
                    }
                    .padding(.vertical, 5)
                }
            }
            WordwellCard {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Common mistake")
                        .font(WordwellType.sectionLabel)
                        .foregroundStyle(WordwellColor.secondaryText)
                    WordwellBodyText(lesson.commonMistake)
                }
            }
            aiExplanation
            if lesson.id == "phrasal-verbs" {
                PhrasalVerbGallery()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadAIAccess() }
        .onDisappear { stopAI() }
    }

    private var aiExplanation: some View {
        VStack(alignment: .leading, spacing: 12) {
            section("AI explanation") {
                switch aiAccess {
                case .checking:
                    ProgressView("Checking AI availability")
                case .ready:
                    WordwellPrivacyCue()
                    Button(aiPhase == .loading ? "Explaining…" : "Explain with AI") { requestAI() }
                        .buttonStyle(WordwellButtonStyle(.secondary))
                        .disabled(aiPhase == .loading)
                case .disabled:
                    WordwellBodyText("On-device AI is turned off in Settings.", secondary: true)
                case .unavailable:
                    WordwellBodyText("AI is unavailable on this device. The lesson above is still available.", secondary: true)
                case .failed:
                    WordwellBodyText("AI settings could not be loaded.", secondary: true)
                }
            }
            switch aiPhase {
            case .idle: EmptyView()
            case .loading:
                WordwellCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            ProgressView()
                            WordwellBodyText("Preparing an explanation on this device…", secondary: true)
                        }
                        Button("Stop") { stopAI() }
                            .buttonStyle(WordwellButtonStyle(.secondary))
                    }
                }
            case .answer(let answer):
                WordwellCard { WordwellBodyText(answer) }
            case .unavailable:
                WordwellBodyText("AI is unavailable right now. Please try again later.", secondary: true)
            case .failed:
                WordwellBodyText("Could not prepare an AI explanation. Please try again.", secondary: true)
            }
        }
    }

    private func loadAIAccess() async {
        guard let profile = try? await settings.profile() else { aiAccess = .failed; return }
        guard profile.aiEnabled else { aiAccess = .disabled; return }
        aiAccess = GrammarAI.availability().isAvailable ? .ready : .unavailable
    }

    private func requestAI() {
        stopAI()
        aiPhase = .loading
        aiTask = Task {
            await loadAIAccess()
            guard aiAccess == .ready, !Task.isCancelled else { aiPhase = .idle; return }
            let context = GrammarLessonContext(
                id: lesson.id, title: lesson.title, level: lesson.level.label,
                use: lesson.use, form: lesson.form,
                examples: lesson.examples.map { "\($0.sentence) — \($0.meaning)" },
                commonMistake: lesson.commonMistake
            )
            do {
                let answer = try await GrammarAI.explain(context)
                try Task.checkCancellation()
                aiPhase = .answer(answer)
            } catch is CancellationError {
                aiPhase = .idle
            } catch let error as AIError {
                switch error {
                case .unavailable, .unsupportedLanguage: aiPhase = .unavailable
                case .cancelled: aiPhase = .idle
                default: aiPhase = .failed
                }
            } catch {
                aiPhase = .failed
            }
        }
    }

    private func stopAI() {
        aiTask?.cancel()
        aiTask = nil
        aiPhase = .idle
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(WordwellType.sectionLabel)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }
}

private struct GrammarPicture: View {
    let diagram: GrammarDiagram
    let caption: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            switch diagram {
            case .timeline(let moment):
                timeline(moment)
            case .place:
                placePicture
            case .compare(let labels):
                comparison(labels)
            case .flow(let labels):
                flow(labels)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Diagram: \(diagram.labels.joined(separator: ", ")). \(caption)")
    }

    private func timeline(_ moment: GrammarTimeline) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                Text("PAST")
                Spacer()
                Text("NOW")
                Spacer()
                Text("FUTURE")
            }
            .font(WordwellType.badge)
            .foregroundStyle(WordwellColor.secondaryText)

            HStack(spacing: 0) {
                marker(moment == .past || moment == .pastPeriod || moment == .pastToNow || moment == .repeated)
                Rectangle()
                    .fill(moment == .pastToNow ? WordwellColor.ink : WordwellColor.border)
                    .frame(height: moment == .pastToNow ? 5 : 2)
                    .overlay(alignment: .leading) {
                        if moment == .pastPeriod {
                            Capsule().fill(WordwellColor.ink).frame(width: 36, height: 5)
                        }
                    }
                marker(moment == .now || moment == .pastToNow || moment == .repeated)
                Rectangle()
                    .fill(WordwellColor.border)
                    .frame(height: 2)
                marker(moment == .future || moment == .repeated)
            }
        }
        .padding(.vertical, 14)
    }

    private func marker(_ active: Bool) -> some View {
        Circle()
            .fill(active ? WordwellColor.ink : WordwellColor.surface)
            .frame(width: 16, height: 16)
            .overlay { Circle().strokeBorder(WordwellColor.ink, lineWidth: 1.5) }
    }

    private var placePicture: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 14) { placeItems }
            } else {
                HStack(spacing: 10) { placeItems }
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var placeItems: some View {
        placeItem("in", ballOffset: 0)
        placeItem("on", ballOffset: -20)
        placeItem("under", ballOffset: 20)
    }

    private func placeItem(_ label: String, ballOffset: CGFloat) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(WordwellColor.ink, lineWidth: 2)
                    .frame(width: 46, height: 28)
                Circle()
                    .fill(WordwellColor.ink)
                    .frame(width: 12, height: 12)
                    .offset(y: ballOffset)
            }
            .frame(width: 62, height: 80)
            Text(label)
                .font(WordwellType.button)
                .foregroundStyle(WordwellColor.ink)
        }
        .frame(maxWidth: .infinity)
    }

    private func comparison(_ labels: [String]) -> some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 8) { comparisonItems(labels) }
            } else {
                HStack(alignment: .top, spacing: 8) { comparisonItems(labels) }
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func comparisonItems(_ labels: [String]) -> some View {
        ForEach(labels.indices, id: \.self) { index in
            Text(labels[index])
                .font(WordwellType.meta)
                .foregroundStyle(WordwellColor.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 64)
                .padding(.horizontal, 6)
                .background(WordwellColor.paper, in: RoundedRectangle(cornerRadius: 8))
                .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(WordwellColor.border) }
        }
    }

    private func flow(_ labels: [String]) -> some View {
        VStack(spacing: 6) {
            ForEach(labels.indices, id: \.self) { index in
                Text(labels[index])
                    .font(WordwellType.body)
                    .foregroundStyle(WordwellColor.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(WordwellColor.paper, in: RoundedRectangle(cornerRadius: 8))
                if index < labels.count - 1 {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(WordwellColor.secondaryText)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private func levelBadge(for level: GrammarLevel) -> some View {
    let band: WordwellCEFRBand = switch level {
    case .foundation: .beginner
    case .intermediate: .intermediate
    case .advanced: .advanced
    }
    return WordwellCEFRBadge(level: level.label, band: band)
}

#Preview {
    NavigationStack { GrammarScreen(settings: LocalLearningSettingsRepository()) }
}
