import SwiftUI

struct MostVisitedCitiesView: View {
    let rankings: [TravelInsightsService.CityRanking]
    @State private var selectedCity: TravelInsightsService.CityRanking?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Most Visited Cities")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                if !rankings.isEmpty {
                    Text("\(rankings.count) cities")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            if rankings.isEmpty {
                EmptyCitiesRankingView()
            } else {
                // Top 3 podium
                if rankings.count >= 3 {
                    HStack(spacing: 8) {
                        // 2nd place
                        CityPodiumCard(ranking: rankings[1], size: .small)
                        // 1st place
                        CityPodiumCard(ranking: rankings[0], size: .large)
                        // 3rd place
                        CityPodiumCard(ranking: rankings[2], size: .small)
                    }
                    .padding(.vertical, 4)
                }

                // Rest of the list
                ForEach(rankings.dropFirst(rankings.count >= 3 ? 3 : 0)) { ranking in
                    CityRankingRow(ranking: ranking)
                }
            }
        }
    }
}

struct CityPodiumCard: View {
    let ranking: TravelInsightsService.CityRanking
    let size: PodiumSize

    enum PodiumSize {
        case small, large

        var medalSize: CGFloat { self == .large ? 24 : 18 }
        var fontSize: CGFloat { self == .large ? 15 : 12 }
        var cityFontSize: CGFloat { self == .large ? 13 : 11 }
        var height: CGFloat { self == .large ? 100 : 80 }
        var medalOffset: CGFloat { self == .large ? -8 : -4 }
    }

    var body: some View {
        VStack(spacing: 4) {
            // Medal
            Text(medalEmoji)
                .font(.system(size: size.medalSize))

            Text(ranking.city)
                .font(.system(size: size.cityFontSize, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(ranking.visitCount)×")
                .font(.system(size: size.fontSize, design: .monospaced))
                .foregroundColor(Theme.textSecondary)

            // Podium base
            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(podiumColor)
                .frame(height: podiumHeight)
        }
        .frame(height: size.height)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
        .overlay(
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 4)
                    .fill(podiumColor.opacity(0.6))
                    .frame(height: size == .large ? 6 : 4)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
        )
    }

    private var medalEmoji: String {
        switch ranking.rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    private var podiumColor: Color {
        switch ranking.rank {
        case 1: return Theme.terracotta
        case 2: return Color(hex: "9ca3af")
        case 3: return Color(hex: "b45309").opacity(0.6)
        default: return Theme.surfaceElevated
        }
    }

    private var podiumHeight: CGFloat {
        switch ranking.rank {
        case 1: return 32
        case 2: return 24
        case 3: return 16
        default: return 8
        }
    }
}

struct CityRankingRow: View {
    let ranking: TravelInsightsService.CityRanking
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    // Rank
                    Text("#\(ranking.rank)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(rankColor)
                        .frame(width: 32, alignment: .leading)

                    // City info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ranking.city)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)

                        if let country = ranking.country {
                            Text(country)
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }

                    Spacer()

                    // Stats
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(ranking.visitCount) visits")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Theme.terracotta)
                        Text("\(ranking.totalDays)d total")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.leading, 4)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 16) {
                        InfoPill(icon: "calendar", label: "Last visited", value: formatDate(ranking.lastVisited))
                        InfoPill(icon: "clock", label: "Total days", value: "\(ranking.totalDays)d")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }

    private var rankColor: Color {
        switch ranking.rank {
        case 1: return Theme.terracotta
        case 2: return Color(hex: "9ca3af")
        case 3: return Color(hex: "b45309")
        default: return Theme.textSecondary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

struct InfoPill: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.surfaceElevated)
        .cornerRadius(Theme.cornerRadiusPill)
    }
}

struct EmptyCitiesRankingView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 32))
                .foregroundColor(Theme.textSecondary.opacity(0.5))

            Text("No city data yet")
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)

            Text("Complete your first trip to see your most visited cities here.")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}
