import SwiftUI

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(Theme.terracotta.opacity(0.08))
                    .frame(width: 180, height: 180)

                // Globe wireframe
                Circle()
                    .trim(from: 0.3, to: 0.7)
                    .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1.5)
                    .frame(width: 120, height: 120)

                // Dotted latitude
                Ellipse()
                    .trim(from: 0.2, to: 0.8)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundColor(Theme.textSecondary.opacity(0.2))
                    .frame(width: 80, height: 40)

                // Center icon
                Image(systemName: "airplane.departure")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.terracotta.opacity(0.6))
            }

            VStack(spacing: 10) {
                Text("Your map awaits")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Start your first trip and Perch will build your personal travel atlas — city by city, memory by memory.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Minimal trip suggestions
            VStack(alignment: .leading, spacing: 12) {
                Text("Where to next?")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                ForEach(sampleDestinations) { destination in
                    HStack(spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(Theme.terracotta)
                            .font(.system(size: 18))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(destination.city)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                            Text(destination.country)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(20)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusLarge)
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

struct SampleDestination: Identifiable {
    let id = UUID()
    let city: String
    let country: String
}

let sampleDestinations: [SampleDestination] = [
    SampleDestination(city: "Tokyo", country: "Japan"),
    SampleDestination(city: "Lisbon", country: "Portugal"),
    SampleDestination(city: "Mexico City", country: "Mexico"),
    SampleDestination(city: "Cape Town", country: "South Africa"),
]

// MARK: - Location Permission Denied View

struct LocationPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Theme.terracotta.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "location.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.terracotta)
            }

            VStack(spacing: 12) {
                Text("Location access needed")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Perch needs location access to record the cities you visit during trips. Without it, Perch can't build your travel map.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // What we need (and don't)
            VStack(spacing: 0) {
                PermissionRow(
                    icon: "checkmark.shield.fill",
                    title: "Only during trips",
                    description: "We never track you unless a trip is active",
                    color: Theme.sage
                )
                Divider().background(Theme.divider)
                PermissionRow(
                    icon: "checkmark.shield.fill",
                    title: "City-level only",
                    description: "We detect cities, not your exact location",
                    color: Theme.sage
                )
                Divider().background(Theme.divider)
                PermissionRow(
                    icon: "checkmark.shield.fill",
                    title: "Never leaves your phone",
                    description: "All data is stored locally. Always.",
                    color: Theme.sage
                )
            }
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusMedium)
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    openSettings()
                } label: {
                    Text("Open Settings")
                }
                .buttonStyle(PerchButtonStyle())

                Text("You can enable location access in Settings > Privacy & Security > Location Services")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
    }
}

// MARK: - No Locations Recorded View

struct NoLocationsRecordedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.sage.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.sage)
            }

            VStack(spacing: 12) {
                Text("Waiting for locations")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Perch is actively monitoring, but no new cities have been detected yet. Keep your trip running — it can take time to detect movement between places.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Tips
            VStack(alignment: .leading, spacing: 12) {
                Text("Tips")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                TipRow(icon: "airplane", text: "Perch detects cities after ~50km of travel")
                TipRow(icon: "clock", text: "It may take 2+ hours to recognize a stop")
                TipRow(icon: "wifi", text: "Strong GPS signal helps accuracy")
            }
            .padding(20)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusMedium)
            .padding(.horizontal, 20)

            Spacer()
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.terracotta)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)

            Spacer()
        }
    }
}

// MARK: - Trip Save Failed View

struct TripSaveFailedView: View {
    let onRetry: () -> Void
    let onDiscard: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color.red.opacity(0.8))
            }

            VStack(spacing: 12) {
                Text("Couldn't save trip")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Something went wrong while saving your trip data. Your trip history is preserved — we just couldn't complete this save.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onRetry()
                } label: {
                    Text("Try Again")
                }
                .buttonStyle(PerchButtonStyle())

                Button {
                    onDiscard()
                } label: {
                    Text("Discard Trip")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - CO₂ Footprint Visual

struct CO2FootprintVisual: View {
    let co2Kg: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Theme.co2Neutral.opacity(0.1))
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: min(co2Progress, 1.0))
                .stroke(
                    co2Gradient,
                    style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 2) {
                Text(co2Label)
                    .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Text("CO₂")
                    .font(.system(size: size * 0.1))
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }

    private var co2Progress: Double {
        // Normalize: 5t = full circle
        min(co2Kg / 5000, 1.0)
    }

    private var co2Gradient: LinearGradient {
        if co2Kg < 500 {
            return LinearGradient(colors: [Theme.sage, Theme.sage], startPoint: .leading, endPoint: .trailing)
        } else if co2Kg < 2000 {
            return LinearGradient(colors: [Color(hex: "f59e0b"), Color(hex: "ef4444")], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [Color(hex: "ef4444"), Color(hex: "b91c1c")], startPoint: .leading, endPoint: .trailing)
        }
    }

    private var co2Label: String {
        if co2Kg >= 1000 {
            return String(format: "%.1ft", co2Kg / 1000)
        }
        return String(format: "%.0fkg", co2Kg)
    }
}

// MARK: - Travel Insights View

struct TravelInsightsView: View {
    let stats: TravelStats

    var body: some View {
        VStack(spacing: 16) {
            InsightCard(
                icon: "globe",
                title: "Countries explored",
                value: "\(stats.countriesVisited)",
                detail: "You're building a worldly perspective one trip at a time.",
                color: Theme.terracotta
            )

            InsightCard(
                icon: "mappin.and.ellipse",
                title: "Cities discovered",
                value: "\(stats.citiesVisited)",
                detail: "Each city leaves its mark. \(stats.citiesVisited) marks and counting.",
                color: Theme.sage
            )

            InsightCard(
                icon: "airplane.departure",
                title: "Distance traveled",
                value: stats.formattedDistance,
                detail: distanceInsight,
                color: Theme.textPrimary
            )

            InsightCard(
                icon: "leaf.fill",
                title: "Carbon footprint",
                value: stats.formattedCO2,
                detail: co2Insight,
                color: Theme.co2Neutral
            )
        }
    }

    private var distanceInsight: String {
        let km = stats.totalDistanceKm
        if km < 5000 {
            return "A modest start. The world's waiting."
        } else if km < 20000 {
            return "You've crossed a few oceans. Keep going."
        } else if km < 50000 {
            return "A serious traveler. The atlas is filling up."
        } else {
            return "You've circled the globe more than once. Impressive."
        }
    }

    private var co2Insight: String {
        let t = stats.totalCO2Kg / 1000
        if t < 0.5 {
            return "Light footprint. Slow travel has its virtues."
        } else if t < 2 {
            return "Average for a frequent traveler. Consider trains when possible."
        } else {
            return "Heavy on flights. Look for overland alternatives on your next trip."
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)

                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
                    .italic()
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}
