import SwiftUI
import WidgetKit
import WordwellDomain

@main
struct WordwellWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordOfTheDayWidget()
    }
}

struct WordOfTheDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WordOfTheDay", provider: WordOfTheDayProvider()) { entry in
            WordOfTheDayView(word: entry.word)
                .containerBackground(WidgetColor.paper, for: .widget)
        }
        .configurationDisplayName("Word of the day")
        .description("A new English word every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

struct WordOfTheDayEntry: TimelineEntry {
    let date: Date
    let word: DailyWord?
}

/// Reads the schedule the app writes to the App Group; the widget never opens the dictionary itself.
struct WordOfTheDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordOfTheDayEntry {
        WordOfTheDayEntry(date: .now, word: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (WordOfTheDayEntry) -> Void) {
        let word = schedule()?.word(on: .now) ?? (context.isPreview ? .sample : nil)
        completion(WordOfTheDayEntry(date: .now, word: word))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordOfTheDayEntry>) -> Void) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let schedule = schedule()
        var entries = [WordOfTheDayEntry(date: .now, word: schedule?.word(on: .now))]
        for offset in 1... {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            guard let word = schedule?.word(on: day) else {
                // Past the planned days show the empty state; the app reloads timelines when it refills.
                entries.append(WordOfTheDayEntry(date: day, word: nil))
                break
            }
            entries.append(WordOfTheDayEntry(date: day, word: word))
        }
        completion(Timeline(entries: entries, policy: .never))
    }

    private func schedule() -> DailyWordSchedule? {
        UserDefaults(suiteName: DailyWordSchedule.appGroup).flatMap(DailyWordSchedule.load(from:))
    }
}

struct WordOfTheDayView: View {
    @Environment(\.widgetFamily) private var family
    let word: DailyWord?

    var body: some View {
        if let word {
            content(word)
                .widgetURL(Self.url(for: word))
        } else {
            Text("Open Verbalex to get today's word")
                .font(WidgetType.text(13, relativeTo: .footnote))
                .foregroundStyle(family == .accessoryRectangular ? Color.secondary : WidgetColor.secondaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func content(_ word: DailyWord) -> some View {
        switch family {
        case .accessoryRectangular:
            // Lock Screen renders in vibrant mode, so keep system colors instead of paper and ink.
            VStack(alignment: .leading, spacing: 0) {
                Text(word.word)
                    .font(WidgetType.display(17, relativeTo: .headline))
                    .widgetAccentable()
                Text("/\(word.ipa)/")
                    .font(WidgetType.text(12, relativeTo: .caption))
                    .foregroundStyle(.secondary)
                Text(word.definition)
                    .font(WidgetType.text(12, relativeTo: .caption))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemMedium:
            VStack(alignment: .leading, spacing: 6) {
                label
                Spacer(minLength: 0)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    headword(word)
                    details(word)
                }
                Text(word.definition)
                    .font(WidgetType.text(14, relativeTo: .subheadline))
                    .foregroundStyle(WidgetColor.ink)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 4) {
                label
                Spacer(minLength: 0)
                headword(word)
                details(word)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }

    private var label: some View {
        Text("Word of the day")
            .font(WidgetType.text(12, weight: .semibold, relativeTo: .footnote))
            .foregroundStyle(WidgetColor.secondaryText)
    }

    private func headword(_ word: DailyWord) -> some View {
        Text(word.word)
            .font(WidgetType.display(26, relativeTo: .title))
            .foregroundStyle(WidgetColor.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .widgetAccentable()
    }

    private func details(_ word: DailyWord) -> some View {
        Text(word.ipa.isEmpty ? word.partOfSpeech : "/\(word.ipa)/ · \(word.partOfSpeech)")
            .font(WidgetType.text(13, relativeTo: .footnote))
            .foregroundStyle(WidgetColor.secondaryText)
            .lineLimit(1)
    }

    static func url(for word: DailyWord) -> URL? {
        var components = URLComponents()
        components.scheme = "verbalex"
        components.host = "word"
        components.queryItems = [URLQueryItem(name: "id", value: word.wordID)]
        return components.url
    }
}

// ponytail: copies of WordwellType/WordwellColor tokens; the widget skips WordwellDesign so it does not
// embed the 35 MB illustration catalog. Keep in sync with Packages/WordwellKit/Sources/WordwellDesign.
private enum WidgetType {
    static func display(_ size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        .custom("Fraunces", size: size, relativeTo: style).weight(.semibold)
    }

    static func text(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle) -> Font {
        .custom("Work Sans", size: size, relativeTo: style).weight(weight)
    }
}

private enum WidgetColor {
    static let paper = adaptive(light: 0xF7F2E6, dark: 0x211E19)
    static let ink = adaptive(light: 0x211E19, dark: 0xF7F2E6)
    static let secondaryText = adaptive(light: 0x736E64, dark: 0xCDC5B7)

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? uiColor(dark) : uiColor(light) })
    }

    private static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
    }
}

private extension DailyWord {
    static let sample = DailyWord(day: "", wordID: "oewn:lantern:n", word: "lantern", partOfSpeech: "noun",
                                  ipa: "ˈlæn.tɚn", definition: "light in a transparent protective case")
}

#Preview(as: .systemSmall) { WordOfTheDayWidget() } timeline: { WordOfTheDayEntry(date: .now, word: .sample) }
#Preview(as: .systemMedium) { WordOfTheDayWidget() } timeline: { WordOfTheDayEntry(date: .now, word: .sample) }
#Preview(as: .accessoryRectangular) { WordOfTheDayWidget() } timeline: { WordOfTheDayEntry(date: .now, word: .sample) }
