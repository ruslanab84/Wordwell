import SwiftUI
import WordwellData
import WordwellDesign

struct PhrasalVerbGallery: View {
    @State private var search = ""
    @State private var level = "All levels"

    private var entries: [PhrasalVerbEntry] {
        LocalPhrasalVerbCatalog.all.filter {
            (level == "All levels" || $0.level == level)
                && (search.isEmpty || $0.phrase.localizedStandardContains(search)
                    || $0.meaning.localizedStandardContains(search))
        }
    }

    private var groups: [PhrasalVerbGroup] {
        Dictionary(grouping: entries, by: \.baseVerb)
            .map { PhrasalVerbGroup(verb: $0.key, entries: $0.value) }
            .sorted { $0.entries.count == $1.entries.count
                ? $0.verb < $1.verb : $0.entries.count > $1.entries.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Phrasal verb gallery")
                .font(WordwellType.cardHeadline)
                .foregroundStyle(WordwellColor.ink)
                .accessibilityAddTraits(.isHeader)
            WordwellBodyText("Explore 300 useful expressions by their main verb.", secondary: true)
            TextField("Search expressions or meanings", text: $search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(12)
                .background(WordwellColor.surface, in: RoundedRectangle(cornerRadius: WordwellLayout.cardRadius))
                .overlay(RoundedRectangle(cornerRadius: WordwellLayout.cardRadius).stroke(WordwellColor.border))
                .accessibilityLabel("Search phrasal verbs")
            Picker("Level", selection: $level) {
                ForEach(["All levels", "A1–A2", "B1–B2", "C1"], id: \.self) { level in
                    Text(level).tag(level)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Filter by level")
            Text("\(entries.count) \(entries.count == 1 ? "expression" : "expressions")")
                .font(WordwellType.meta)
                .foregroundStyle(WordwellColor.secondaryText)
                .accessibilityLabel("\(entries.count) \(entries.count == 1 ? "expression" : "expressions") found")
            if groups.isEmpty {
                WordwellBodyText("No expressions found. Try another search or level.", secondary: true)
            } else {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(groups) { group in
                        NavigationLink {
                            PhrasalVerbGroupScreen(group: group)
                        } label: {
                            WordwellListRow(title: group.verb.capitalized, detail: group.detail) {
                                Image(systemName: "textformat.abc")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct PhrasalVerbGroup: Identifiable {
    let verb: String
    let entries: [PhrasalVerbEntry]

    var id: String { verb }
    var detail: String {
        let examples = entries.prefix(2).map(\.phrase).joined(separator: ", ")
        return "\(entries.count) \(entries.count == 1 ? "expression" : "expressions") · \(examples)"
    }
}

private struct PhrasalVerbGroupScreen: View {
    let group: PhrasalVerbGroup
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        FeaturePage(title: group.verb.capitalized, subtitle: group.detail) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: dynamicTypeSize.isAccessibilitySize ? 1 : 2), spacing: 12) {
                ForEach(group.entries) { entry in
                    PhrasalVerbCard(entry: entry)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PhrasalVerbCard: View {
    let entry: PhrasalVerbEntry

    private var band: WordwellCEFRBand {
        switch entry.level {
        case "A1–A2": .beginner
        case "B1–B2": .intermediate
        default: .advanced
        }
    }

    var body: some View {
        WordwellCard {
            VStack(alignment: .leading, spacing: 9) {
                Text(entry.phrase)
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                WordwellCEFRBadge(level: entry.level, band: band)
                Text(entry.meaning)
                    .font(WordwellType.body)
                    .foregroundStyle(WordwellColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                WordwellSVGImage(assetName: entry.imageAsset, isLineArt: true,
                                 altText: entry.imageAlt, isDecorative: false)
                    .frame(height: 112)
                    .frame(maxWidth: .infinity)
                Text(entry.example)
                    .font(WordwellType.meta)
                    .italic()
                    .foregroundStyle(WordwellColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
