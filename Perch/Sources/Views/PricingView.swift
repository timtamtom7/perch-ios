import SwiftUI

struct PricingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userSubscriptionTier") private var userSubscriptionTier = "free"
    @State private var selectedPlan: String? = nil
    @State private var isPurchasing = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose your plan")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.textPrimary)

                        Text("Start free. Upgrade when you're ready to explore more.")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    // Plan cards
                    VStack(spacing: 12) {
                        FreePlanCard(isCurrent: userSubscriptionTier == "free")
                        WanderPlanCard(
                            isCurrent: userSubscriptionTier == "wander",
                            isSelected: selectedPlan == "wander",
                            onSelect: { selectPlan("wander") }
                        )
                        ExplorerPlanCard(
                            isCurrent: userSubscriptionTier == "explorer",
                            isSelected: selectedPlan == "explorer",
                            onSelect: { selectPlan("explorer") }
                        )
                    }
                    .padding(.horizontal, 16)

                    // Purchase button
                    if let plan = selectedPlan, plan != userSubscriptionTier {
                        Button {
                            purchasePlan(plan)
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(Theme.background)
                                } else {
                                    Text("Continue with \(planName(plan))")
                                }
                            }
                        }
                        .buttonStyle(PerchButtonStyle())
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Footer
                    VStack(spacing: 6) {
                        Text("All plans include on-device storage. No account required.")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)

                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Payments handled by Apple. Cancel anytime.")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Theme.textSecondary.opacity(0.7))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(16)
                }
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedPlan)
    }

    private func planName(_ plan: String) -> String {
        switch plan {
        case "wander": return "Wander"
        case "explorer": return "Explorer"
        default: return "Free"
        }
    }

    private func selectPlan(_ plan: String) {
        if plan == userSubscriptionTier {
            selectedPlan = nil
        } else {
            selectedPlan = plan
        }
    }

    private func purchasePlan(_ plan: String) {
        isPurchasing = true
        // Simulate in-app purchase flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            userSubscriptionTier = plan
            isPurchasing = false
            selectedPlan = nil
        }
    }
}

// MARK: - Free Plan Card

struct FreePlanCard: View {
    let isCurrent: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Free")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("$0 forever")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                if isCurrent {
                    CurrentBadge()
                }
            }
            .padding(20)

            Divider().background(Theme.divider)

            VStack(spacing: 12) {
                PlanFeatureRow(text: "3 trips maximum", included: true)
                PlanFeatureRow(text: "30-day history", included: true)
                PlanFeatureRow(text: "Basic trip stats", included: true)
                PlanFeatureRow(text: "Unlimited trips", included: false)
                PlanFeatureRow(text: "CO₂ tracking", included: false)
                PlanFeatureRow(text: "Travel insights", included: false)
                PlanFeatureRow(text: "Lifetime history", included: false)
            }
            .padding(20)
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(Theme.divider, lineWidth: 1)
        )
    }
}

// MARK: - Wander Plan Card

struct WanderPlanCard: View {
    let isCurrent: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Wander")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.terracotta)
                        PopularBadge()
                    }
                    Text("$4.99 / month")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                if isCurrent {
                    CurrentBadge()
                } else {
                    Button {
                        onSelect()
                    } label: {
                        Text(isSelected ? "Selected" : "Choose")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelected ? Theme.background : Theme.terracotta)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Theme.terracotta : Color.clear)
                            .cornerRadius(Theme.cornerRadiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                    .stroke(Theme.terracotta, lineWidth: isSelected ? 0 : 1.5)
                            )
                    }
                }
            }
            .padding(20)

            Divider().background(Theme.divider)

            VStack(spacing: 12) {
                PlanFeatureRow(text: "Unlimited trips", included: true)
                PlanFeatureRow(text: "90-day history", included: true)
                PlanFeatureRow(text: "CO₂ tracking & footprint", included: true)
                PlanFeatureRow(text: "Basic travel stats", included: true)
                PlanFeatureRow(text: "Travel insights", included: false)
                PlanFeatureRow(text: "Lifetime history", included: false)
                PlanFeatureRow(text: "Map export", included: false)
            }
            .padding(20)
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(isSelected ? Theme.terracotta : Theme.divider, lineWidth: isSelected ? 2 : 1)
        )
    }
}

// MARK: - Explorer Plan Card

struct ExplorerPlanCard: View {
    let isCurrent: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Explorer")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.sage)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "c9a84c"))
                    }
                    Text("$9.99 / month")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                if isCurrent {
                    CurrentBadge()
                } else {
                    Button {
                        onSelect()
                    } label: {
                        Text(isSelected ? "Selected" : "Choose")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isSelected ? Theme.background : Theme.sage)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(isSelected ? Theme.sage : Color.clear)
                            .cornerRadius(Theme.cornerRadiusSmall)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                    .stroke(Theme.sage, lineWidth: isSelected ? 0 : 1.5)
                            )
                    }
                }
            }
            .padding(20)

            Divider().background(Theme.divider)

            VStack(spacing: 12) {
                PlanFeatureRow(text: "Everything in Wander", included: true, highlight: true)
                PlanFeatureRow(text: "Lifetime history", included: true)
                PlanFeatureRow(text: "Travel insights & trends", included: true)
                PlanFeatureRow(text: "Map export (PDF)", included: true)
                PlanFeatureRow(text: "Multiple trips simultaneously", included: true)
                PlanFeatureRow(text: "Priority support", included: true)
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Theme.surface, Theme.surfaceElevated],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(Theme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(isSelected ? Theme.sage : Color(hex: "c9a84c").opacity(0.3), lineWidth: isSelected ? 2 : 1.5)
        )
    }
}

// MARK: - Supporting Views

struct PlanFeatureRow: View {
    let text: String
    let included: Bool
    var highlight: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: included ? "checkmark.circle.fill" : "xmark.circle")
                .font(.system(size: 16))
                .foregroundColor(included ? (highlight ? Theme.sage : Theme.terracotta) : Theme.textSecondary.opacity(0.4))

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(included ? Theme.textPrimary : Theme.textSecondary.opacity(0.5))

            Spacer()
        }
    }
}

struct CurrentBadge: View {
    var body: some View {
        Text("Current")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.divider)
            .cornerRadius(Theme.cornerRadiusXLarge)
    }
}

struct PopularBadge: View {
    var body: some View {
        Text("Popular")
            .font(.caption2)
            .foregroundColor(Theme.background)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Theme.terracotta)
            .cornerRadius(Theme.cornerRadiusSmall)
    }
}
