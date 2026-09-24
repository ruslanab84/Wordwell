import SwiftUI

public struct WordwellBodyText: View {
    public let text: String
    public let secondary: Bool

    @ScaledMetric(relativeTo: .body) private var lineSpacing: CGFloat = 5

    public init(_ text: String, secondary: Bool = false) {
        self.text = text
        self.secondary = secondary
    }

    public var body: some View {
        Text(text)
            .font(WordwellType.body)
            .lineSpacing(lineSpacing)
            .foregroundStyle(secondary ? WordwellColor.secondaryText : WordwellColor.ink)
    }
}

public struct WordwellCard<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(WordwellLayout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WordwellColor.surface, in: RoundedRectangle(cornerRadius: WordwellLayout.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: WordwellLayout.cardRadius)
                    .strokeBorder(WordwellColor.border, lineWidth: 1)
            }
    }
}

// Wrap this visual row in a NavigationLink or Button at the feature boundary.
public struct WordwellListRow<Icon: View>: View {
    public let title: String
    public let detail: String
    private let icon: Icon

    public init(title: String, detail: String, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.detail = detail
        self.icon = icon()
    }

    public var body: some View {
        HStack(spacing: 12) {
            icon
                .frame(width: 24, height: 24)
                .foregroundStyle(WordwellColor.lineArt)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(WordwellType.body)
                    .foregroundStyle(WordwellColor.ink)
                Text(detail)
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
        .overlay(alignment: .bottom) {
            WordwellColor.border.frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

// Reserve stat boxes for Practice and Profile, as specified in design.md.
public struct WordwellStatBox<Icon: View>: View {
    public let value: String
    public let label: String
    private let icon: Icon

    public init(value: String, label: String, @ViewBuilder icon: () -> Icon) {
        self.value = value
        self.label = label
        self.icon = icon()
    }

    public var body: some View {
        WordwellCard {
            VStack(spacing: 5) {
                icon
                    .frame(width: 24, height: 24)
                    .foregroundStyle(WordwellColor.lineArt)
                    .accessibilityHidden(true)
                Text(value)
                    .font(WordwellType.cardHeadline)
                    .foregroundStyle(WordwellColor.ink)
                Text(label)
                    .font(WordwellType.meta)
                    .foregroundStyle(WordwellColor.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        }
    }
}

public struct WordwellButtonStyle: ButtonStyle {
    public enum Variant {
        case primary
        case secondary
    }

    private let variant: Variant

    public init(_ variant: Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WordwellType.button)
            .foregroundStyle(variant == .primary ? WordwellColor.paper : WordwellColor.ink)
            .padding(.horizontal, 18)
            .frame(minHeight: WordwellLayout.minimumTouchTarget)
            .background(variant == .primary ? WordwellColor.ink : .clear, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(variant == .secondary ? WordwellColor.ink : .clear, lineWidth: 1)
            }
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

public struct WordwellToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer(minLength: 12)
                Capsule()
                    .fill(configuration.isOn ? WordwellColor.ink : WordwellColor.surface)
                    .frame(width: 34, height: 20)
                    .overlay {
                        Capsule()
                            .strokeBorder(configuration.isOn ? .clear : WordwellColor.mutedIcon, lineWidth: 1)
                    }
                    .overlay {
                        Circle()
                            .fill(configuration.isOn ? WordwellColor.paper : WordwellColor.mutedIcon)
                            .frame(width: 14, height: 14)
                            .offset(x: configuration.isOn ? 7 : -7)
                    }
                    .accessibilityHidden(true)
            }
            .frame(minHeight: WordwellLayout.minimumTouchTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
    }
}

public enum WordwellCEFRBand {
    case beginner
    case intermediate
    case advanced

    fileprivate var textColor: Color {
        switch self {
        case .beginner: WordwellColor.CEFR.beginnerText
        case .intermediate: WordwellColor.CEFR.intermediateText
        case .advanced: WordwellColor.CEFR.advancedText
        }
    }

    fileprivate var backgroundColor: Color {
        switch self {
        case .beginner: WordwellColor.CEFR.beginnerBackground
        case .intermediate: WordwellColor.CEFR.intermediateBackground
        case .advanced: WordwellColor.CEFR.advancedBackground
        }
    }
}

public struct WordwellCEFRBadge: View {
    public let level: String
    public let band: WordwellCEFRBand

    public init(level: String, band: WordwellCEFRBand) {
        self.level = level
        self.band = band
    }

    public var body: some View {
        Text(level)
            .font(WordwellType.badge)
            .foregroundStyle(band.textColor)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(band.backgroundColor, in: RoundedRectangle(cornerRadius: WordwellLayout.badgeRadius))
            .accessibilityLabel("CEFR level \(level)")
    }
}

// Show only for AI actions verified to run entirely on device.
public struct WordwellPrivacyCue: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(WordwellColor.privacy)
                .frame(width: 6, height: 6)
                .accessibilityHidden(true)
            Text("On-device · Private & secure")
                .font(WordwellType.badge)
                .foregroundStyle(WordwellColor.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}
