import SwiftUI

struct TripComparisonView: View {
    let comparison: TravelInsightsService.TripComparison
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Trip name
                    Text(comparison.trip.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    // Comparison cards
                    VStack(spacing: 12) {
                        ComparisonCard(
                            icon: "calendar",
                            label: "Duration",
                            yourValue: comparison.trip.formattedDuration,
                            avgValue: formatDuration(comparison.averageDuration),
                            diffLabel: comparison.durationVsAverage,
                            diffValue: comparison.durationDiff,
                            unit: "day",
                            color: Theme.terracotta
                        )

                        ComparisonCard(
                            icon: "airplane",
                            label: "Distance",
                            yourValue: formatDistance(comparison.trip.totalDistance),
                            avgValue: formatDistance(comparison.averageDistance),
                            diffLabel: comparison.distanceVsAverage,
                            diffValue: comparison.distanceDiff,
                            unit: "km",
                            color: Theme.sage
                        )

                        ComparisonCard(
                            icon: "leaf.fill",
                            label: "CO₂ Footprint",
                            yourValue: formatCO2(comparison.trip.co2Estimate),
                            avgValue: formatCO2(comparison.averageCO2),
                            diffLabel: co2Label,
                            diffValue: comparison.co2Diff,
                            unit: "kg",
                            color: Theme.co2Neutral
                        )
                    }

                    // Verdict
                    VerdictCard(comparison: comparison)

                    // Context
                    ContextCard(comparison: comparison)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Trip Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
        }
    }

    private var co2Label: String {
        if abs(comparison.co2Diff) < 10 { return "Average" }
        return comparison.co2Diff > 0 ? "Higher impact" : "Lower impact"
    }

    private func formatDuration(_ seconds: Double) -> String {
        let days = Int(seconds / 86400)
        return days == 1 ? "1 day" : "\(days) days"
    }

    private func formatDistance(_ meters: Double) -> String {
        let km = meters / 1000
        if km >= 1000 {
            return String(format: "%.0fk km", km)
        }
        return String(format: "%.0f km", km)
    }

    private func formatCO2(_ kg: Double) -> String {
        if kg >= 1000 {
            return String(format: "%.1ft", kg / 1000)
        }
        return String(format: "%.0fkg", kg)
    }
}

struct ComparisonCard: View {
    let icon: String
    let label: String
    let yourValue: String
    let avgValue: String
    let diffLabel: String
    let diffValue: Double
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            HStack(spacing: 0) {
                // Your value
                VStack(spacing: 4) {
                    Text("You")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                    Text(yourValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                }
                .frame(maxWidth: .infinity)

                // Diff indicator
                VStack(spacing: 4) {
                    Image(systemName: diffIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(diffColor)

                    Text(diffLabel)
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(width: 60)
                }

                // Average value
                VStack(spacing: 4) {
                    Text("Average")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                    Text(avgValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .perchCard()
    }

    private var diffIcon: String {
        if abs(diffValue) < 0.5 { return "equal" }
        return diffValue > 0 ? "arrow.up" : "arrow.down"
    }

    private var diffColor: Color {
        if abs(diffValue) < 0.5 { return Theme.textSecondary }
        return diffValue > 0 ? Color(hex: "ef4444") : Theme.sage
    }
}

struct VerdictCard: View {
    let comparison: TravelInsightsService.TripComparison

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(verdictColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: verdictIcon)
                    .font(.system(size: 24))
                    .foregroundColor(verdictColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verdictTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text(verdictBody)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(3)
            }

            Spacer()
        }
        .perchCard()
    }

    private var verdictColor: Color {
        let score = verdictScore
        if score > 0.3 { return Theme.terracotta }
        if score > -0.3 { return Color(hex: "f59e0b") }
        return Theme.sage
    }

    private var verdictScore: Double {
        // Compare all three metrics: positive = bigger/longer than average
        let durScore = comparison.durationDiff / max(comparison.averageDuration / 86400, 1)
        let distScore = comparison.distanceDiff / max(comparison.averageDistance / 1000, 1)
        let co2Score = comparison.co2Diff / max(comparison.averageCO2, 1)
        return (durScore + distScore + co2Score) / 3
    }

    private var verdictIcon: String {
        if verdictScore > 0.3 { return "star.fill" }
        if verdictScore < -0.3 { return "leaf.fill" }
        return "scalemass.fill"
    }

    private var verdictTitle: String {
        if verdictScore > 0.5 { return "Ambitious Trip" }
        if verdictScore > 0.2 { return "Above Average" }
        if verdictScore > -0.2 { return "Balanced Trip" }
        if verdictScore > -0.5 { return "Light & Lean" }
        return "Minimalist Trip"
    }

    private var verdictBody: String {
        if verdictScore > 0.5 {
            return "A marathon of a trip. You really immersed yourself in this one."
        } else if verdictScore > 0.2 {
            return "Longer than most trips. You got to really know this place."
        } else if verdictScore > -0.2 {
            return "Right in the sweet spot. Not too short, not too long."
        } else if verdictScore > -0.5 {
            return "Quick but meaningful. You covered ground efficiently."
        }
        return "A brief visit. Sometimes the shortest trips leave the deepest impressions."
    }
}

struct ContextCard: View {
    let comparison: TravelInsightsService.TripComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What this means")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            Text(contextText)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .perchCard()
    }

    private var contextText: String {
        let cities = comparison.trip.cities.count
        let days = comparison.trip.durationDays

        if cities == 0 {
            return "This trip had no recorded city visits. Make sure Perch has location access during your trip."
        }

        if days == 0 {
            return "This was a very short trip — less than a day. Great for day trips or quick stops."
        }

        let cityPerDay = Double(cities) / Double(max(days, 1))

        if cityPerDay > 1.5 {
            return "You averaged \(String(format: "%.1f", cityPerDay)) cities per day. That's fast travel — lots of ground covered."
        } else if cityPerDay > 0.8 {
            return "You averaged \(String(format: "%.1f", cityPerDay)) cities per day. A balanced pace — enough time in each place."
        } else {
            return "You averaged \(String(format: "%.1f", cityPerDay)) cities per day. Deep travel — you really settled into each place."
        }
    }
}

// MARK: - Trip Comparison Entry Point

struct TripComparisonEntryView: View {
    let trip: Trip
    @EnvironmentObject var tripStore: TripStore
    @State private var comparison: TravelInsightsService.TripComparison?
    @State private var showingComparison = false
    @State private var showingError = false

    var body: some View {
        Button {
            performComparison()
        } label: {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14))
                Text("Compare to average")
                    .font(.system(size: 14))
            }
            .foregroundColor(Theme.terracotta)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.terracotta.opacity(0.12))
            .cornerRadius(8)
        }
        .alert("Trip Comparison Failed", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Not enough trip data to generate a comparison. Complete at least one other trip first.")
        }
        .sheet(isPresented: $showingComparison) {
            if let comp = comparison {
                TripComparisonView(comparison: comp)
            }
        }
    }

    private func performComparison() {
        let insights = TravelInsightsService(tripStore: tripStore)
        let completed = tripStore.trips.filter { !$0.isActive }
        if completed.count < 2 {
            showingError = true
            return
        }
        comparison = insights.compareTrip(trip)
        showingComparison = true
    }
}
