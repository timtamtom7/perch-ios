import SwiftUI
import Charts

struct CO2BreakdownChartView: View {
    let breakdown: TravelInsightsService.CO2Breakdown
    let year: Int

    @State private var selectedMode: TransportModeData?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CO₂ Breakdown")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)

                    Text(breakdown.formattedTotal)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                }

                Spacer()

                // Legend
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(chartData.prefix(3), id: \.mode) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            Text(item.label)
                                .font(.system(size: 11))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
            }

            // Pie/Doughnut chart
            ZStack {
                Chart(chartData, id: \.mode) { item in
                    SectorMark(
                        angle: .value("CO₂", item.kg),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.color)
                    .cornerRadius(4)
                }
                .chartLegend(.hidden)
                .frame(height: 180)

                // Center label
                VStack(spacing: 2) {
                    if let selected = selectedMode {
                        Text(selected.label)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text(formatKG(selected.kg))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text("\(Int(selected.percent * 100))%")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    } else {
                        Text("Total")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                        Text(formatKG(breakdown.total))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
            .chartBackground { _ in
                // R6: Reserved for future chart background customization
            }

            // Mode rows
            VStack(spacing: 8) {
                ForEach(chartData, id: \.mode) { item in
                    CO2ModeRow(
                        mode: item.mode,
                        label: item.label,
                        kg: item.kg,
                        percent: item.percent,
                        color: item.color,
                        isSelected: selectedMode?.mode == item.mode
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedMode?.mode == item.mode {
                                selectedMode = nil
                            } else {
                                selectedMode = item
                            }
                        }
                    }
                }
            }
        }
        .perchCard()
    }

    private var chartData: [TransportModeData] {
        [
            TransportModeData(mode: "flight", label: "Flight", kg: breakdown.flightKg, percent: breakdown.flightPercent, color: Theme.terracotta),
            TransportModeData(mode: "car", label: "Car", kg: breakdown.carKg, percent: breakdown.carPercent, color: Color(hex: "f59e0b")),
            TransportModeData(mode: "train", label: "Train", kg: breakdown.trainKg, percent: breakdown.trainPercent, color: Theme.sage),
            TransportModeData(mode: "bus", label: "Bus", kg: breakdown.busKg, percent: breakdown.busPercent, color: Color(hex: "60a5fa"))
        ].filter { $0.kg > 0 }
    }

    private func formatKG(_ kg: Double) -> String {
        if kg >= 1000 {
            return String(format: "%.1ft", kg / 1000)
        }
        return String(format: "%.0fkg", kg)
    }
}

struct TransportModeData: Equatable {
    let mode: String
    let label: String
    let kg: Double
    let percent: Double
    let color: Color
}

struct CO2ModeRow: View {
    let mode: String
    let label: String
    let kg: Double
    let percent: Double
    let color: Color
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)

            Spacer()

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.surfaceElevated)
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * percent, height: 4)
                }
            }
            .frame(width: 60, height: 4)

            Text(formatPercent)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Theme.textSecondary)
                .frame(width: 36, alignment: .trailing)

            Text(formatKG)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.textPrimary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(isSelected ? color.opacity(0.08) : Color.clear)
        .cornerRadius(8)
    }

    private var formatPercent: String {
        "\(Int(percent * 100))%"
    }

    private var formatKG: String {
        if kg >= 1000 {
            return String(format: "%.1ft", kg / 1000)
        }
        return String(format: "%.0fkg", kg)
    }
}

// MARK: - CO₂ Comparison View

struct CO2ComparisonView: View {
    let comparison: TravelInsightsService.TravelerComparison
    let year: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Footprint vs. Average")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            HStack(spacing: 0) {
                CO2ComparisonItem(
                    label: "Your CO₂",
                    value: formatCO2(comparison.yourCO2),
                    sublabel: comparison.co2VersusAverage,
                    color: co2Color
                )

                Divider().frame(height: 50).background(Theme.divider)

                CO2ComparisonItem(
                    label: "Avg. Traveler",
                    value: formatCO2(comparison.avgCO2),
                    sublabel: "per year",
                    color: Theme.textSecondary
                )

                Divider().frame(height: 50).background(Theme.divider)

                CO2ComparisonItem(
                    label: "Countries",
                    value: "\(comparison.yourCountries)",
                    sublabel: comparison.countriesVersusAverage,
                    color: Theme.terracotta
                )
            }

            // CO₂ gauge
            CO2GaugeView(yourCO2: comparison.yourCO2, avgCO2: comparison.avgCO2)
        }
        .perchCard()
    }

    private var co2Color: Color {
        if comparison.yourCO2 < comparison.avgCO2 * 0.7 { return Theme.sage }
        if comparison.yourCO2 < comparison.avgCO2 { return Color(hex: "84cc16") }
        if comparison.yourCO2 <= comparison.avgCO2 * 1.3 { return Color(hex: "f59e0b") }
        return Color(hex: "ef4444")
    }

    private func formatCO2(_ kg: Double) -> String {
        if kg >= 1000 {
            return String(format: "%.1ft", kg / 1000)
        }
        return String(format: "%.0fkg", kg)
    }
}

struct CO2ComparisonItem: View {
    let label: String
    let value: String
    let sublabel: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(sublabel)
                .font(.system(size: 10))
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CO2GaugeView: View {
    let yourCO2: Double
    let avgCO2: Double

    private var gaugeValue: Double {
        // Normalize: 0 = 0kg, 1 = 5000kg (5t)
        min(yourCO2 / 5000, 1.0)
    }

    private var avgValue: Double {
        min(avgCO2 / 5000, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.surfaceElevated)
                        .frame(height: 8)

                    // Average marker
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.textSecondary.opacity(0.5))
                        .frame(width: 2, height: 16)
                        .offset(x: geo.size.width * avgValue - 1)

                    // Your value
                    RoundedRectangle(cornerRadius: 4)
                        .fill(gaugeGradient)
                        .frame(width: max(geo.size.width * gaugeValue, 8), height: 8)
                }
            }
            .frame(height: 16)

            HStack {
                Text("0")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("You")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Theme.terracotta)
                Spacer()
                Text("5t")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
            }

            HStack(spacing: 4) {
                Rectangle()
                    .fill(Theme.textSecondary.opacity(0.5))
                    .frame(width: 2, height: 8)
                Text("Average")
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    private var gaugeGradient: LinearGradient {
        if yourCO2 < avgCO2 * 0.7 {
            return LinearGradient(colors: [Theme.sage, Theme.sage], startPoint: .leading, endPoint: .trailing)
        } else if yourCO2 < avgCO2 {
            return LinearGradient(colors: [Theme.sage, Color(hex: "84cc16")], startPoint: .leading, endPoint: .trailing)
        } else if yourCO2 <= avgCO2 * 1.3 {
            return LinearGradient(colors: [Color(hex: "f59e0b"), Color(hex: "fbbf24")], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color(hex: "ef4444"), Color(hex: "b91c1c")], startPoint: .leading, endPoint: .trailing)
        }
    }
}
