import SwiftUI

/// R10: Subscriptions page with tier comparison
struct PerchSubscriptionsView: View {
    @State private var selectedPlan: SubscriptionPlan?

    enum SubscriptionPlan: String, CaseIterable {
        case premium = "Premium"
        case pro = "Pro"

        var price: String {
            switch self {
            case .premium: return "$4.99"
            case .pro: return "$9.99"
            }
        }

        var period: String {
            "/month"
        }

        var features: [String] {
            switch self {
            case .premium:
                return [
                    "Unlimited trips",
                    "Advanced CO2 insights",
                    "Export to PDF",
                    "Travel templates",
                    "Priority support"
                ]
            case .pro:
                return [
                    "Everything in Premium",
                    "Team sharing",
                    "API access",
                    "Custom branding",
                    "Dedicated support"
                ]
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        plansSection
                        faqSection
                    }
                    .padding(16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Subscribe")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.terracotta)

            VStack(spacing: 8) {
                Text("Unlock Premium Features")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Get unlimited trips, advanced insights, and export features.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 20)
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            ForEach(SubscriptionPlan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    HStack(spacing: 4) {
                        Text(plan.price)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.sage)
                        Text(plan.period)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Spacer()
            }
            .padding(16)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.sage)

                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .padding(16)

            Button {
                selectedPlan = plan
            } label: {
                Text("Subscribe")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Theme.sage)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("FAQ")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            VStack(spacing: 0) {
                faqRow(question: "Can I cancel anytime?", answer: "Yes, you can cancel your subscription at any time.")
                Divider()
                faqRow(question: "What happens to my data if I cancel?", answer: "Your trip data remains accessible. Premium features revert to free tier limits.")
                Divider()
                faqRow(question: "Is there a free trial?", answer: "Yes, new subscribers get a 7-day free trial.")
            }
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        }
    }

    private func faqRow(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.textPrimary)

            Text(answer)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(14)
    }
}

#Preview {
    PerchSubscriptionsView()
}
