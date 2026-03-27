import SwiftUI

struct TravelStreaksView: View {
    let streak: TravelInsightsService.TravelStreak
    let frequency: TravelInsightsService.TravelFrequency
    let year: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Travel Activity")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            // Year stats row
            HStack(spacing: 0) {
                StreakStatItem(
                    icon: "airplane.departure",
                    value: "\(frequency.tripsThisYear)",
                    label: "Trips",
                    color: Theme.terracotta
                )
                Divider().frame(height: 40).background(Theme.divider)
                StreakStatItem(
                    icon: "calendar",
                    value: "\(streak.totalMonthsWithTravel)",
                    label: "Active months",
                    color: Theme.sage
                )
                Divider().frame(height: 40).background(Theme.divider)
                StreakStatItem(
                    icon: "trophy.fill",
                    value: "\(streak.consecutiveMonthsWithTravel)",
                    label: "Streak",
                    color: Color(hex: "fbbf24")
                )
            }

            Divider().background(Theme.divider)

            // Monthly heatmap
            MonthlyHeatmapView(monthlyBreakdown: streak.monthlyBreakdown, year: year)

            Divider().background(Theme.divider)

            // Frequency insights
            VStack(spacing: 10) {
                FrequencyInsightRow(
                    icon: "clock",
                    label: "Avg. trip duration",
                    value: String(format: "%.1f days", frequency.averageTripDuration)
                )
                FrequencyInsightRow(
                    icon: "mappin.and.ellipse",
                    label: "Avg. cities per trip",
                    value: String(format: "%.1f", frequency.averageCitiesPerTrip)
                )
                if let mostActive = frequency.mostActiveMonth {
                    FrequencyInsightRow(
                        icon: "flame.fill",
                        label: "Most active month",
                        value: monthName(mostActive),
                        color: Theme.terracotta
                    )
                }
                if streak.longestTripDays > 0 {
                    FrequencyInsightRow(
                        icon: "star.fill",
                        label: "Longest trip",
                        value: "\(streak.longestTripDays) days",
                        color: Color(hex: "fbbf24")
                    )
                }
            }
        }
        .perchCard()
    }
}

struct StreakStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MonthlyHeatmapView: View {
    let monthlyBreakdown: [Int: Int]
    let year: Int

    private let months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Monthly activity")
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)

            HStack(spacing: 4) {
                ForEach(1...12, id: \.self) { month in
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(heatmapColor(for: month))
                            .frame(height: 28)

                        Text(months[month - 1])
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }
    }

    private func heatmapColor(for month: Int) -> Color {
        let count = monthlyBreakdown[month] ?? 0
        if count == 0 { return Theme.surfaceElevated }
        if count == 1 { return Theme.sage.opacity(0.3) }
        if count == 2 { return Theme.sage.opacity(0.6) }
        return Theme.sage
    }
}

struct FrequencyInsightRow: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = Theme.textSecondary

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
        }
    }
}

// MARK: - Total Distance View

struct TotalDistanceView: View {
    let distanceMeters: Double
    let year: Int

    private var km: Double { distanceMeters / 1000 }
    private var miles: Double { km * 0.621371 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Distance")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            HStack(alignment: .bottom, spacing: 8) {
                Text(formattedDistance)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)

                Text("km")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.bottom, 4)
            }

            // Equivalence
            HStack(spacing: 16) {
                EquivalencePill(
                    icon: "globe",
                    text: aroundTheWorldText
                )
            }

            // Mile equivalent
            Text("≈ \(String(format: "%.0f", miles)) miles")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
        }
        .perchCard()
    }

    private var formattedDistance: String {
        if km >= 10000 {
            return String(format: "%.0fk", km / 1000)
        }
        return String(format: "%.0f", km)
    }

    private var aroundTheWorldText: String {
        let earthCircumference = 40075.0  // km
        let times = km / earthCircumference
        if times < 0.5 {
            return "A good start"
        } else if times < 1 {
            return "Almost around the world"
        } else {
            return String(format: "%.1fx around the world", times)
        }
    }
}

private func monthName(_ month: Int) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    var components = DateComponents()
    components.month = month
    if let date = Calendar.current.date(from: components) {
        return formatter.string(from: date)
    }
    return ""
}

struct EquivalencePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundColor(Theme.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.surfaceElevated)
        .cornerRadius(Theme.cornerRadiusPill)
    }
}
