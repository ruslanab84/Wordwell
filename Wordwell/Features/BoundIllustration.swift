import SwiftUI
import WordwellDesign
import WordwellDomain

struct BoundIllustration: View {
    let binding: IllustrationBinding

    var body: some View {
        WordwellSVGImage(
            assetName: binding.assetName,
            isLineArt: binding.style == .monochromeLineArt,
            altText: binding.altText,
            isDecorative: binding.isDecorative
        )
    }
}
