import SwiftUI

/// R9: Anonymous community feed view
struct PerchCommunityView: View {
    @StateObject private var communityService = PerchCommunityService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                if communityService.isLoading {
                    ProgressView()
                        .tint(Theme.sage)
                        .scaleEffect(1.5)
                } else {
                    communityContent
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await communityService.loadPublicFeed()
            }
        }
    }

    private var communityContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(communityService.publicTrips) { trip in
                    tripCard(trip)
                }
            }
            .padding(16)
        }
    }

    private func tripCard(_ trip: PerchCommunityService.PublicTrip) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 11))
                    Text(trip.anonymousId)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Theme.textSecondary)

                Spacer()

                Text(timeAgo(trip.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textTertiary)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.destination)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text(trip.country)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Theme.sage)
            }

            Divider()

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text(trip.transportMode.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                    Text("Transport")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }

                VStack(spacing: 2) {
                    Text("\(String(format: "%.0f", trip.distance)) km")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                    Text("Distance")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }

                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", trip.co2)) kg")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.sage)
                    Text("CO2")
                        .font(.caption2)
                        .foregroundColor(Theme.textTertiary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                    Text("\(trip.likes)")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "ff6b6b"))
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    PerchCommunityView()
}
