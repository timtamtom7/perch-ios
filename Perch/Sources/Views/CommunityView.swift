import SwiftUI

/// R9: Anonymous community feed view
struct PerchCommunityView: View {
    @StateObject private var communityService = PerchCommunityService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f8f6f2")
                    .ignoresSafeArea()

                if communityService.isLoading {
                    ProgressView()
                        .tint(Color(hex: "2d7d46"))
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
                .foregroundColor(Color(hex: "6b6b6b"))

                Spacer()

                Text(timeAgo(trip.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "999999"))
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.destination)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "1a1a1a"))

                    Text(trip.country)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b6b6b"))
                }

                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "2d7d46"))
            }

            Divider()

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text(trip.transportMode.capitalized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    Text("Transport")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "999999"))
                }

                VStack(spacing: 2) {
                    Text("\(String(format: "%.0f", trip.distance)) km")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "1a1a1a"))
                    Text("Distance")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "999999"))
                }

                VStack(spacing: 2) {
                    Text("\(String(format: "%.1f", trip.co2)) kg")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "2d7d46"))
                    Text("CO2")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "999999"))
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
