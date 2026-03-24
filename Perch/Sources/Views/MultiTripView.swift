import SwiftUI
import MapKit

struct MultiTripView: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) private var dismiss
    @State private var showingStartTripInfo = false
    @State private var showingTemplates = false
    @State private var selectedTrip: Trip?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if activeTrips.isEmpty {
                        EmptyMultiTripView(
                            onStartTrip: { showingStartTripInfo = true },
                            onUseTemplate: { showingTemplates = true }
                        )
                    } else {
                        // Active trips header
                        HStack {
                            Text("Active Trips")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            Spacer()

                            Text("\(activeTrips.count) running")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.terracotta)
                        }

                        ForEach(activeTrips) { trip in
                            ActiveTripRow(trip: trip, onTap: { selectedTrip = trip })
                        }

                        // Start new trip
                        HStack(spacing: 12) {
                            Button {
                                showingStartTripInfo = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Trip")
                                }
                            }
                            .buttonStyle(PerchButtonStyle())

                            Button {
                                showingTemplates = true
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("From Template")
                                }
                            }
                            .buttonStyle(PerchButtonStyle(isPrimary: false))
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("My Trips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
            .sheet(isPresented: $showingStartTripInfo) {
                StartTripInfoView()
            }
            .sheet(isPresented: $showingTemplates) {
                TripTemplatesView()
            }
            .sheet(item: $selectedTrip) { trip in
                MultiTripDetailSheet(trip: trip)
            }
        }
    }

    private var activeTrips: [Trip] {
        tripStore.trips.filter { $0.isActive }
    }
}

struct EmptyMultiTripView: View {
    let onStartTrip: () -> Void
    let onUseTemplate: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.terracotta.opacity(0.08))
                    .frame(width: 140, height: 140)

                Image(systemName: "airplane.circle")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.terracotta.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No active trips")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Start a new trip or use a template to begin tracking.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onStartTrip()
                } label: {
                    HStack {
                        Image(systemName: "airplane.departure")
                        Text("Start New Trip")
                    }
                }
                .buttonStyle(PerchButtonStyle())

                Button {
                    onUseTemplate()
                } label: {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Use a Template")
                    }
                }
                .buttonStyle(PerchButtonStyle(isPrimary: false))
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

struct ActiveTripRow: View {
    let trip: Trip
    let onTap: () -> Void
    @EnvironmentObject var tripStore: TripStore
    @State private var duration: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Theme.sage)
                                .frame(width: 8, height: 8)

                            Text(trip.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                        }

                        if let templateName = trip.templateName {
                            Text("from \(templateName)")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formattedDuration)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Theme.sage)

                        Text("\(trip.visits.count) city\(trip.visits.count == 1 ? "" : "s")")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(16)

                // End trip button
                HStack {
                    Button {
                        endTrip()
                    } label: {
                        Text("End Trip")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
                .background(Theme.surfaceElevated)
            }
            .background(Theme.surface)
            .cornerRadius(16)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var formattedDuration: String {
        let total = Int(duration)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        if days > 0 {
            return "\(days)d \(hours)h"
        }
        return "\(hours)h"
    }

    private func startTimer() {
        duration = Date().timeIntervalSince(trip.startDate)
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            duration = Date().timeIntervalSince(trip.startDate)
        }
    }

    private func endTrip() {
        timer?.invalidate()
        // Set this as active trip first
        tripStore.activeTrip = trip
        _ = tripStore.endTrip()
    }
}

struct MultiTripDetailSheet: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripStore: TripStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Trip map
                    if !trip.visits.isEmpty {
                        TripMapPreview(visits: trip.visits)
                            .frame(height: 200)
                            .cornerRadius(16)
                    }

                    // Stats
                    TripStatsRow(trip: trip)

                    // Cities
                    if !trip.visits.isEmpty {
                        CitiesListView(visits: trip.visits)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button {
                            tripStore.activeTrip = trip
                            _ = tripStore.endTrip()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "flag.checkered")
                                Text("End This Trip")
                            }
                        }
                        .buttonStyle(PerchButtonStyle())

                        Button {
                            dismiss()
                        } label: {
                            Text("Keep Running")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle(trip.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
        }
    }
}

struct TripMapPreview: View {
    let visits: [Visit]
    @State private var region = MKCoordinateRegion()

    var body: some View {
        Map {
            ForEach(visits) { visit in
                Annotation(visit.displayName, coordinate: visit.location) {
                    Circle()
                        .fill(Theme.terracotta)
                        .frame(width: 10, height: 10)
                }
            }
            if visits.count > 1 {
                MapPolyline(coordinates: visits.map { $0.location })
                    .stroke(Theme.terracotta.opacity(0.4), lineWidth: 2)
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .onAppear {
            fitToVisits()
        }
    }

    private func fitToVisits() {
        guard !visits.isEmpty else { return }
        let lats = visits.map { $0.latitude }
        let lons = visits.map { $0.longitude }
        let minLat = lats.min()!
        let maxLat = lats.max()!
        let minLon = lons.min()!
        let maxLon = lons.max()!

        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.5, 0.5),
                longitudeDelta: max((maxLon - minLon) * 1.5, 0.5)
            )
        )
    }
}
