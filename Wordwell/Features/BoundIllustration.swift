import SwiftUI
import WordwellDesign
import WordwellDomain

struct BoundIllustration: View {
    let binding: IllustrationBinding

    private var premium = PremiumAccess.shared

    init(binding: IllustrationBinding) {
        self.binding = binding
    }

    var body: some View {
        if premium.isPremium || FreeTier.isIllustrationFree(tags: binding.tags) {
            WordwellSVGImage(
                assetName: binding.assetName,
                isLineArt: binding.style == .monochromeLineArt,
                altText: binding.altText,
                isDecorative: binding.isDecorative
            )
        } else {
            locked
        }
    }

    /// Same footprint as the flat-colour plate (340×200); small thumbnails just show the lock.
    private var locked: some View {
        ViewThatFits {
            Button { premium.showPaywall() } label: {
                VStack(spacing: 6) {
                    Image(systemName: "lock")
                    WordwellBodyText("B1+ illustration · Premium", secondary: true)
                }
                .frame(minWidth: 220, maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens Wordwell Premium")
            Image(systemName: "lock")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Premium illustration")
        }
        .foregroundStyle(WordwellColor.mutedIcon)
        .aspectRatio(340 / 200, contentMode: .fit)
        .overlay {
            RoundedRectangle(cornerRadius: WordwellLayout.cardRadius)
                .strokeBorder(WordwellColor.border, lineWidth: 1)
        }
    }
}
