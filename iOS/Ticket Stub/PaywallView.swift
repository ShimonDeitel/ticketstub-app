import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.accent)
                    .padding(.top, 32)

                Text("Ticket Stub Pro")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.ink)

                Text("Unlimited stubs and yearly recap timeline")
                    .font(Theme.bodyFont)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.ink.opacity(0.75))
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Label("Unlimited stubs", systemImage: "infinity")
                    Label("Unlimited stubs and yearly recap timeline", systemImage: "sparkles")
                }
                .font(.subheadline)
                .foregroundStyle(Theme.ink.opacity(0.85))

                Spacer()

                if let product = purchases.product {
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text("Unlock for \(product.displayPrice) one-time")
                            .font(Theme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
                    }
                    .accessibilityIdentifier("purchaseButton")
                    .padding(.horizontal)
                } else {
                    ProgressView()
                }

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywallRestoreButton")
                .font(.footnote)

                Button("Not Now") { dismiss() }
                    .accessibilityIdentifier("paywallDismissButton")
                    .font(.footnote)
                    .padding(.bottom, 24)
            }
            .background(Theme.background.ignoresSafeArea())
            .task { await purchases.load() }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
}
