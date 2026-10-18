import SwiftUI

/// Three-second launch intro: words fall from the top and stack until the screen is full,
/// then the logo and name appear. Tap anywhere to skip.
struct IntroView: View {
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var falling = false
    @State private var logoShown = false

    private static let background = Color(red: 21 / 255, green: 19 / 255, blue: 15 / 255)
    private static let cream = Color(red: 242 / 255, green: 237 / 255, blue: 225 / 255)
    private static let gray = Color(red: 142 / 255, green: 135 / 255, blue: 122 / 255)
    private static let accent = Color(red: 217 / 255, green: 138 / 255, blue: 95 / 255)

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Self.background

                FlowLayout(hSpacing: 14, vSpacing: 10) {
                    ForEach(Self.words(for: proxy.size)) { word in
                        wordView(word)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, proxy.safeAreaInsets.top + 12)
                .accessibilityHidden(true)

                RadialGradient(colors: [Self.background.opacity(0.97), Self.background.opacity(0.92), Self.background.opacity(0.55)],
                               center: .center, startRadius: 0, endRadius: max(proxy.size.width, proxy.size.height) * 0.6)
                    .opacity(logoShown ? 1 : 0)

                VStack(spacing: 20) {
                    Image("IntroLogo")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .clipShape(.rect(cornerRadius: 29, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 29, style: .continuous).stroke(Self.cream.opacity(0.14)))
                    Text(verbatim: "Verbalex")
                        .font(.custom("Fraunces", fixedSize: 46).weight(.bold))
                        .foregroundStyle(Self.cream)
                }
                .scaleEffect(logoShown ? 1 : 0.82)
                .opacity(logoShown ? 1 : 0)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "Verbalex"))
            }
            .ignoresSafeArea()
        }
        .contentShape(.rect)
        .onTapGesture(perform: onFinish)
        .statusBarHidden()
        .task {
            if !reduceMotion { falling = true }
            let logoDelay = reduceMotion ? 0.3 : 2.5
            withAnimation(.spring(duration: 0.5, bounce: 0.3).delay(logoDelay)) { logoShown = true }
            try? await Task.sleep(for: .seconds(logoDelay + 0.8))
            onFinish()
        }
    }

    private func wordView(_ word: IntroWord) -> some View {
        Text(verbatim: word.text)
            .font(.custom("Fraunces", fixedSize: word.size).weight(word.weight))
            .italic(word.italic)
            .foregroundStyle(word.color)
            .fixedSize()
            .keyframeAnimator(initialValue: reduceMotion ? 0 : -1200, trigger: falling) { content, y in
                content.offset(y: y)
            } keyframes: { _ in
                KeyframeTrack {
                    LinearKeyframe(-1200, duration: word.delay)
                    LinearKeyframe(0, duration: 0.5, timingCurve: .easeIn)
                    LinearKeyframe(-9, duration: 0.15, timingCurve: .easeOut)
                    LinearKeyframe(0, duration: 0.15, timingCurve: .easeIn)
                }
            }
    }

    private struct IntroWord: Identifiable {
        let id: Int
        let text: String
        let size: CGFloat
        let weight: Font.Weight
        let italic: Bool
        let color: Color
        let delay: Double
    }

    private static let vocabulary = ["hello", "learn", "word", "speak", "listen", "read", "write", "think", "dream", "say",
                                     "story", "voice", "sound", "meaning", "phrase", "talk", "grow", "remember", "practice",
                                     "daily", "sentence", "fluent", "mind", "language", "new", "every", "day", "one", "more",
                                     "sense", "spell", "focus", "habit", "play", "ask", "answer", "today", "tomorrow", "begin",
                                     "keep", "going", "light", "simple", "clear", "bright", "quick", "steady", "calm", "bold",
                                     "kind", "open", "curious", "brave"]
    private static let sizes: [CGFloat] = [22, 34, 26, 44, 24, 30, 38]
    private static let weights: [Font.Weight] = [.regular, .bold, .black, .bold, .regular, .black, .bold]

    /// Enough words to overfill the screen. Words later in the flow sit lower and land first,
    /// so the screen fills bottom-up and the top row lands at about 2.45s.
    private static func words(for size: CGSize) -> [IntroWord] {
        // ponytail: count estimated from area (~4000 pt² per word incl. gaps); measure rows if fonts change a lot.
        let count = max(60, Int(size.width * size.height / 4000))
        return (0..<count).map { i in
            let jitter = Double((i * 37) % 11) / 11 * 0.25
            return IntroWord(id: i,
                             text: vocabulary[(i * 7) % vocabulary.count],
                             size: sizes[(i * 3) % sizes.count],
                             weight: weights[(i * 5) % weights.count],
                             italic: i % 3 == 1,
                             color: i % 6 == 0 ? accent : (i % 4 == 0 ? gray : cream),
                             delay: Double(count - 1 - i) / Double(count) * 1.7 + jitter)
        }
    }
}

/// Left-aligned wrapping row layout; rows past the bottom edge are placed anyway and simply fall off-screen.
/// No clipping on the intro: the GeometryReader only covers the safe area, so clipping it cut off the edges.
private struct FlowLayout: Layout {
    var hSpacing: CGFloat
    var vSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + vSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
