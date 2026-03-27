import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var packingListStore: PackingListStore
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    @State private var showingDiary = false
    @State private var showingPrivacy = false
    @State private var showingPackingList = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Map
                    TripMapView(visits: trip.visits, region: $region)
                        .frame(height: 280)
                        .cornerRadius(Theme.cornerRadiusLarge)

                    // Stats row
                    TripStatsRow(trip: trip)

                    // Action buttons
                    HStack(spacing: 12) {
                        ActionButton(icon: "book.fill", label: "Diary") {
                            showingDiary = true
                        }

                        ActionButton(icon: "bag.fill", label: "Packing") {
                            showingPackingList = true
                        }

                        ActionButton(icon: trip.isPrivate ? "lock.fill" : "globe", label: trip.isPrivate ? "Private" : "Public") {
                            showingPrivacy = true
                        }

                        ActionButton(icon: "arrow.left.arrow.right", label: "Compare") {
                            // handled by TripComparisonEntryView
                        }
                    }

                    // Trip comparison entry
                    TripComparisonEntryView(trip: trip)

                    // Cities list
                    CitiesListView(visits: trip.visits)

                    // Trip notes
                    if !trip.notes.isEmpty {
                        TripNotesView(notes: trip.notes)
                    }

                    // Template info
                    if let templateName = trip.templateName {
                        TemplateSourceBadge(name: templateName)
                    }
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
            .sheet(isPresented: $showingDiary) {
                TripDiaryView(trip: trip)
            }
            .sheet(isPresented: $showingPrivacy) {
                TripPrivacyView(trip: trip)
            }
            .sheet(isPresented: $showingPackingList) {
                TripPackingListSheet(trip: trip)
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

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundColor(Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusSmall)
        }
    }
}

struct TripNotesView: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                Text("Trip Notes")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }

            Text(notes)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
                .lineSpacing(4)
        }
        .padding(14)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}

struct TemplateSourceBadge: View {
    let name: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.on.doc.fill")
                .font(.system(size: 11))
            Text("Created from \"\(name)\"")
                .font(.system(size: 12))
        }
        .foregroundColor(Theme.sage)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.sage.opacity(0.1))
        .cornerRadius(Theme.cornerRadiusSmall)
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

// MARK: - Trip Packing List Sheet

struct TripPackingListSheet: View {
    let trip: Trip
    @EnvironmentObject var packingListStore: PackingListStore
    @Environment(\.dismiss) private var dismiss
    @State private var targetList: PackingList?

    var body: some View {
        NavigationStack {
            Group {
                if let list = targetList {
                    PackingListView(packingList: list)
                } else {
                    creatingView
                }
            }
            .background(Theme.background)
            .navigationTitle("Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
            .onAppear {
                loadOrCreateList()
            }
        }
    }

    private var creatingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Theme.terracotta)
            Text("Setting up packing list…")
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadOrCreateList() {
        if let existing = packingListStore.list(forTripId: trip.id) {
            targetList = existing
        } else {
            let listName = tripPrimaryLabel.isEmpty ? "Packing List" : "Packing — \(tripPrimaryLabel)"
            if let newList = packingListStore.createList(name: listName, tripId: trip.id, items: nil) {
                targetList = newList
            }
        }
    }

    private var tripPrimaryLabel: String {
        trip.cities.first ?? trip.name
    }
}
