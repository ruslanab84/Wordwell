import StoreKit
import SwiftUI
import WordwellDesign
import WordwellDomain

/// Subscription state plus the free tier's daily quotas. One shared instance; the paywall sheet lives in `ContentView`.
@Observable
final class PremiumAccess {
    static let shared = PremiumAccess()
    static let productIDs = ["wordwell.premium.monthly", "wordwell.premium.yearly"]

    enum Quota: String {
        case practice, ai

        var limit: Int {
            switch self {
            case .practice: FreeTier.practiceSessionsPerDay
            case .ai: FreeTier.aiRequestsPerDay
            }
        }
    }

    private(set) var hasSubscription = false
    var paywallPresented = false
    #if DEBUG
    var debugForcePremium = UserDefaults.standard.bool(forKey: "wordwell.debugForcePremium") {
        didSet { UserDefaults.standard.set(debugForcePremium, forKey: "wordwell.debugForcePremium") }
    }
    #endif
    /// Bumped on every consume so views showing `remaining` refresh.
    private var quotaRevision = 0

    var isPremium: Bool {
        #if DEBUG
        if debugForcePremium { return true }
        #endif
        return hasSubscription
    }

    private init() {
        Task { await refresh() }
        Task {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update { await transaction.finish() }
                await refresh()
            }
        }
    }

    func refresh() async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement,
               Self.productIDs.contains(transaction.productID), transaction.revocationDate == nil {
                active = true
            }
        }
        hasSubscription = active
    }

    func showPaywall() { paywallPresented = true }

    func remaining(_ quota: Quota) -> Int {
        _ = quotaRevision
        return isPremium ? .max : stored(quota).remaining(limit: quota.limit)
    }

    /// Uses one free slot; opens the paywall and returns false when today's are gone.
    @discardableResult
    func consume(_ quota: Quota) -> Bool {
        if isPremium { return true }
        var value = stored(quota)
        let allowed = value.consume(limit: quota.limit)
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key(quota))
        }
        quotaRevision += 1
        if !allowed { showPaywall() }
        return allowed
    }

    /// Checks without using a slot (for AI, which is only charged after a successful answer).
    func canUse(_ quota: Quota) -> Bool {
        if remaining(quota) > 0 { return true }
        showPaywall()
        return false
    }

    /// Premium-only feature: true when unlocked, otherwise opens the paywall.
    func unlock() -> Bool {
        if isPremium { return true }
        showPaywall()
        return false
    }

    private func key(_ quota: Quota) -> String { "wordwell.quota.\(quota.rawValue)" }

    private func stored(_ quota: Quota) -> DailyQuota {
        UserDefaults.standard.data(forKey: key(quota))
            .flatMap { try? JSONDecoder().decode(DailyQuota.self, from: $0) } ?? DailyQuota()
    }
}

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let benefits: [(String, String)] = [
        ("photo.on.rectangle", "B1–C1 words with illustrations"),
        ("text.book.closed", "Every grammar lesson and Skills Check results"),
        ("infinity", "Unlimited practice"),
        ("sparkles", "Unlimited on-device AI: conversation, speaking, explain mistakes, compare words, Quiz Me, find by meaning"),
        ("house", "Word for You and topic filter on Home"),
    ]

    var body: some View {
        SubscriptionStoreView(productIDs: PremiumAccess.productIDs) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Wordwell Premium")
                    .font(WordwellType.screenTitle)
                    .foregroundStyle(WordwellColor.ink)
                ForEach(benefits, id: \.1) { icon, text in
                    Label(text, systemImage: icon)
                        .font(WordwellType.body)
                        .foregroundStyle(WordwellColor.ink)
                }
                WordwellBodyText("AI features need a device with Apple Intelligence. Everything else works on any device.",
                                 secondary: true)
            }
            .padding(WordwellLayout.screenPadding)
        }
        .storeButton(.visible, for: .restorePurchases)
        .onInAppPurchaseCompletion { _, _ in
            await PremiumAccess.shared.refresh()
            if PremiumAccess.shared.isPremium { dismiss() }
        }
    }
}

/// Shown in place of locked content; tapping opens the paywall.
struct PremiumLockedCard: View {
    let title: String
    var detail: String = "Included in Wordwell Premium."

    var body: some View {
        Button { PremiumAccess.shared.showPaywall() } label: {
            WordwellCard {
                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundStyle(WordwellColor.ink)
                    WordwellBodyText(title)
                    WordwellBodyText(detail, secondary: true)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens Wordwell Premium")
    }
}
