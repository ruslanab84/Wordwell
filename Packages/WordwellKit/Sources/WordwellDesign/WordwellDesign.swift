import CoreText
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum WordwellColor {
    // Light values follow design.md. Dark values preserve the same warm, ink-and-paper character.
    public static let paper = adaptive(light: 0xF7F2E6, dark: 0x211E19)
    public static let surface = adaptive(light: 0xFFFFFF, dark: 0x2D2923)
    public static let ink = adaptive(light: 0x211E19, dark: 0xF7F2E6)
    public static let muted = adaptive(light: 0x8C877C, dark: 0xAFA79A)
    // The specified muted color is 3.2:1 on paper; use this for readable secondary text.
    public static let secondaryText = adaptive(light: 0x736E64, dark: 0xCDC5B7)
    public static let mutedIcon = adaptive(light: 0xB7AE9C, dark: 0x918A7D)
    public static let border = ink.opacity(0.14)
    public static let privacy = adaptive(light: 0x4F7A4A, dark: 0xA6C69E)
    public static let lineArt = adaptive(light: 0x3A362E, dark: 0xE8DFCF)

    // Specimen plates are illustrations with a fixed parchment palette in either appearance.
    public static let parchment = Color(red: 236 / 255, green: 217 / 255, blue: 175 / 255)
    public static let plateBorder = Color(red: 184 / 255, green: 160 / 255, blue: 107 / 255)
    public static let specimenCaption = Color(red: 110 / 255, green: 90 / 255, blue: 52 / 255)

    public enum CEFR {
        public static let beginnerText = adaptive(light: 0x3E5636, dark: 0xD9E8D5)
        public static let beginnerBackground = adaptive(light: 0xE3EDE0, dark: 0x30422F)
        public static let beginnerAccent = adaptive(light: 0x4F7A4A, dark: 0xA6C69E)
        public static let intermediateText = adaptive(light: 0x6E4712, dark: 0xF0DCB8)
        public static let intermediateBackground = adaptive(light: 0xF5E8CF, dark: 0x51402A)
        public static let intermediateAccent = adaptive(light: 0xB8863A, dark: 0xD6A75C)
        public static let advancedText = adaptive(light: 0x2E4A63, dark: 0xD8E7F0)
        public static let advancedBackground = adaptive(light: 0xDCE6EC, dark: 0x2E4050)
        public static let advancedAccent = advancedText
    }

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            uiColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
        #else
        return Color(nsColor: NSColor(name: nil) { appearance in
            nsColor(appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light)
        })
        #endif
    }

    #if canImport(UIKit)
    private static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
    #else
    private static func nsColor(_ hex: UInt32) -> NSColor {
        NSColor(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
    #endif
}

public enum WordwellType {
    public static let screenTitle = display(32, relativeTo: .largeTitle)
    public static let cardHeadline = display(23, weight: .semibold, relativeTo: .title2)
    public static let headword = display(34, relativeTo: .largeTitle)
    public static let body = workSans(15, relativeTo: .body)
    public static let meta = workSans(13, relativeTo: .subheadline)
    public static let sectionLabel = workSans(12, weight: .semibold, relativeTo: .footnote)
    public static let badge = workSans(11, weight: .bold, relativeTo: .caption2)
    public static let button = workSans(14, weight: .semibold, relativeTo: .callout)
    public static let navLabel = workSans(11, weight: .regular, relativeTo: .caption2)

    public static func display(
        _ size: CGFloat,
        weight: Font.Weight = .bold,
        relativeTo textStyle: Font.TextStyle = .largeTitle
    ) -> Font {
        .custom("Fraunces", size: size, relativeTo: textStyle).weight(weight)
    }

    public static func workSans(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        .custom("Work Sans", size: size, relativeTo: textStyle).weight(weight)
    }
}

public enum WordwellLayout {
    public static let screenPadding: CGFloat = 24
    public static let sectionGap: CGFloat = 18
    public static let cardPadding: CGFloat = 16
    public static let rowPadding: CGFloat = 11
    public static let cardRadius: CGFloat = 12
    public static let badgeRadius: CGFloat = 4
    public static let minimumTouchTarget: CGFloat = 44
}

public enum WordwellFonts {
    public static func register() {
        for name in ["Fraunces", "Fraunces-Italic", "WorkSans", "WorkSans-Italic"] {
            let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts")
            if let url {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}

public struct WordwellSVGImage: View {
    public let assetName: String
    public let isLineArt: Bool
    public let altText: String?
    public let isDecorative: Bool

    public init(assetName: String, isLineArt: Bool, altText: String?, isDecorative: Bool) {
        self.assetName = assetName
        self.isLineArt = isLineArt
        self.altText = altText
        self.isDecorative = isDecorative
    }

    public var body: some View {
        Image(assetName, bundle: .module)
            .resizable()
            .renderingMode(isLineArt ? .template : .original)
            .scaledToFit()
            .foregroundStyle(WordwellColor.lineArt)
            .accessibilityLabel(altText ?? "")
            .accessibilityHidden(isDecorative)
    }
}

public struct ScreenHeader<Illustration: View>: View {
    public let title: String
    public let subtitle: String
    private let illustration: Illustration

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(title: String, subtitle: String, @ViewBuilder illustration: () -> Illustration) {
        self.title = title
        self.subtitle = subtitle
        self.illustration = illustration()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                    .accessibilityAddTraits(.isHeader)
                Text(subtitle)
                    .font(WordwellType.meta)
                    .foregroundStyle(WordwellColor.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !dynamicTypeSize.isAccessibilitySize {
                illustration
                    .frame(maxWidth: 140)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

public extension ScreenHeader where Illustration == EmptyView {
    init(title: String, subtitle: String) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

public struct FeaturePage<Content: View>: View {
    public let title: String
    public let subtitle: String
    private let content: Content

    public init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WordwellLayout.sectionGap) {
                ScreenHeader(title: title, subtitle: subtitle)
                content
            }
            .padding(.horizontal, WordwellLayout.screenPadding)
            .padding(.top, WordwellLayout.screenPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(WordwellColor.paper.ignoresSafeArea())
    }
}
