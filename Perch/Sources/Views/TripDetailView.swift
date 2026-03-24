import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Map
                    TripMapView(visits: trip.visits, region: $region)
                        .frame(height: 280)
                        .cornerRadius(16)

                    // Stats row
                    TripStatsRow(trip: trip)

                    // Cities list
                    CitiesListView(visits: trip.visits)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle(tripTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.terracotta)
                }
            }
            .onAppear {
                fitMapToVisits()
            }
        }
    }

    private var tripTitle: String {
        if let firstCity = trip.cities.first {
            return firstCity
        }
        return trip.name
    }

    private func fitMapToVisits() {
        guard !trip.visits.isEmpty else { return }
        let coordinates = trip.visits.map { $0.location }
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }

        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let spanLat = (maxLat - minLat) * 1.4
        let spanLon = (maxLon - minLon) * 1.4

        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(spanLat, 0.5), longitudeDelta: max(spanLon, 0.5))
        )
    }
}

struct TripMapView: View {
    let visits: [Visit]
    @Binding var region: MKCoordinateRegion
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(Array(visits.enumerated()), id: \.element.id) { index, visit in
                Annotation(visit.displayName, coordinate: visit.location) {
                    ZStack {
                        Circle()
                            .fill(Theme.terracotta)
                            .frame(width: 12, height: 12)
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 12, height: 12)
                    }
                }
                .tag(visit.id)
            }

            if visits.count > 1 {
                MapPolyline(coordinates: visits.map { $0.location })
                    .stroke(Theme.terracotta.opacity(0.5), lineWidth: 2)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            if !visits.isEmpty {
                cameraPosition = .region(region)
            }
        }
    }
}

struct TripStatsRow: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 0) {
            TripStatItem(
                icon: "calendar",
                value: trip.formattedDuration,
                label: "Duration"
            )
            Divider().frame(height: 40).background(Theme.divider)
            TripStatItem(
                icon: "mappin",
                value: "\(trip.cities.count)",
                label: "Cities"
            )
            Divider().frame(height: 40).background(Theme.divider)
            TripStatItem(
                icon: "airplane",
                value: formatDistance(trip.totalDistance),
                label: "Distance"
            )
            Divider().frame(height: 40).background(Theme.divider)
            TripStatItem(
                icon: "leaf",
                value: formatCO2(trip.co2Estimate),
                label: "CO₂"
            )
        }
        .perchCard()
    }

    private func formatDistance(_ meters: Double) -> String {
        let km = meters / 1000
        if km >= 1000 {
            return String(format: "%.0fk km", km / 1000)
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

struct TripStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CitiesListView: View {
    let visits: [Visit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cities")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            ForEach(Array(visits.enumerated()), id: \.element.id) { index, visit in
                CityRow(visit: visit, isLast: index == visits.count - 1)
                if index < visits.count - 1 {
                    CityConnector()
                }
            }
        }
    }
}

struct CityRow: View {
    let visit: Visit
    let isLast: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.terracotta)
                    .frame(width: 10, height: 10)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(visit.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
            if let duration = visit.duration {
                Text(formatDuration(duration))
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(Theme.sage)
            }
        }
        .padding(.vertical, 4)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: visit.arrivalDate)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        if hours < 24 {
            return "\(hours)h"
        }
        let days = hours / 24
        return "\(days)d"
    }
}

struct CityConnector: View {
    var body: some View {
        HStack {
            Rectangle()
                .fill(Theme.divider)
                .frame(width: 1, height: 16)
                .padding(.leading, 4)
            Spacer()
        }
    }
}
