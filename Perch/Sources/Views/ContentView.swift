import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingSettings = false
    @State private var showingStartTripInfo = false
    @State private var showingPricing = false
    @State private var selectedTrip: Trip?
    @State private var showingOnboarding = false

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    var body: some View {
        NavigationStack {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if pastTrips.isEmpty && tripStore.activeTrip == nil {
                    EmptyStateWithCTA(
                        onStartTrip: { showingStartTripInfo = true },
                        onViewPricing: { showingPricing = true }
                    )
                } else {
                    mainContent
                }
            }
            .background(Theme.background)
            .navigationTitle("Perch")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingPricing = true
                    } label: {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Theme.terracotta)
                            .font(.system(size: 16))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingOnboarding = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(Theme.textSecondary)
                        }

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingStartTripInfo) {
                StartTripInfoView()
            }
            .sheet(isPresented: $showingPricing) {
                PricingView()
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .sheet(item: $selectedTrip) { trip in
                TripDetailView(trip: trip)
            }
        }
        .onAppear {
            checkLocationPermission()
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let active = tripStore.activeTrip {
                    ActiveTripCard(trip: active)
                }

                TravelSummaryCard(stats: tripStore.travelStats(for: currentYear))

                // Travel insights for the year
                if !pastTrips.isEmpty {
                    TravelInsightsSection(stats: tripStore.travelStats(for: currentYear))
                }

                if tripStore.activeTrip == nil {
                    Button {
                        showingStartTripInfo = true
                    } label: {
                        HStack {
                            Image(systemName: "airplane")
                            Text("Start New Trip")
                        }
                    }
                    .buttonStyle(PerchButtonStyle())
                }

                if !pastTrips.isEmpty {
                    PastTripsSection(trips: pastTrips, onSelect: { selectedTrip = $0 })
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private var pastTrips: [Trip] {
        tripStore.trips.filter { !$0.isActive }
    }

    private func checkLocationPermission() {
        if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
            // Show location permission denied state
        }
    }
}

// MARK: - Empty State with CTA

struct EmptyStateWithCTA: View {
    let onStartTrip: () -> Void
    let onViewPricing: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                EmptyStateView()

                // CTAs at bottom
                VStack(spacing: 12) {
                    Button {
                        onStartTrip()
                    } label: {
                        HStack {
                            Image(systemName: "airplane")
                            Text("Start Your First Trip")
                        }
                    }
                    .buttonStyle(PerchButtonStyle())

                    Button {
                        onViewPricing()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "crown")
                            Text("See Pro Features")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Travel Insights Section

struct TravelInsightsSection: View {
    let stats: TravelStats
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Your Year in Perspective")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            if isExpanded {
                TravelInsightsView(stats: stats)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                // Collapsed insight teaser
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Theme.terracotta)
                        .font(.system(size: 14))
                    Text(sampleInsight)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .italic()
                    Spacer()
                }
                .padding(16)
                .background(Theme.surface)
                .cornerRadius(12)
            }
        }
    }

    private var sampleInsight: String {
        if stats.countriesVisited == 0 {
            return "Start your first trip to see your travel insights."
        } else if stats.countriesVisited < 3 {
            return "You've visited \(stats.countriesVisited) country\(stats.countriesVisited == 1 ? "" : "ries") so far. Keep exploring."
        } else if stats.countriesVisited < 6 {
            return "A worldly \(stats.countriesVisited) countries. You're building something meaningful."
        } else {
            return "Impressive. \(stats.countriesVisited) countries and counting. This is what a well-traveled life looks like."
        }
    }
}

// MARK: - Active Trip Card

struct ActiveTripCard: View {
    let trip: Trip
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @State private var duration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showingNoLocationsAlert = false
    @State private var visitsCount: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "airplane.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.terracotta)
                Text("Currently traveling")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()

                if visitsCount == 0 {
                    Text("Detecting…")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(8)
                }
            }
            .padding(.bottom, 12)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Started \(trip.startDate, format: .dateTime.month(.abbreviated).day())")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    Text(formattedDuration)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Theme.sage)
                }
                Spacer()

                Button {
                    endTrip()
                } label: {
                    Text("End Trip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.terracotta)
                        .cornerRadius(8)
                }
            }
        }
        .perchCard()
        .onAppear {
            startTimer()
            observeVisits()
            NotificationCenter.default.addObserver(
                forName: .didRecordNewVisit,
                object: nil,
                queue: .main
            ) { _ in
                Task { @MainActor in
                    visitsCount = trip.visits.count
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("No locations recorded", isPresented: $showingNoLocationsAlert) {
            Button("End Trip Anyway", role: .destructive) {
                endTrip()
            }
            Button("Keep Running", role: .cancel) {}
        } message: {
            Text("Perch hasn't detected any city visits yet. This can happen if GPS signal is weak or you haven't traveled far enough. You can end the trip now or keep it running.")
        }
    }

    private var formattedDuration: String {
        let total = Int(duration)
        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        }
        return "\(hours)h \(minutes)m"
    }

    private func startTimer() {
        duration = Date().timeIntervalSince(trip.startDate)
        visitsCount = trip.visits.count
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            duration = Date().timeIntervalSince(trip.startDate)
        }
    }

    private func observeVisits() {
        // Observe visit count changes
        if let currentTrip = tripStore.activeTrip {
            visitsCount = currentTrip.visits.count
        }
    }

    private func endTrip() {
        if visitsCount == 0 && trip.visits.isEmpty {
            showingNoLocationsAlert = true
        } else {
            timer?.invalidate()
            _ = tripStore.endTrip()
            locationService.stopMonitoring()
        }
    }
}

// MARK: - Travel Summary Card

struct TravelSummaryCard: View {
    let stats: TravelStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("2026 Travel Summary")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            HStack(spacing: 0) {
                StatItem(icon: "globe", value: "\(stats.countriesVisited)", label: "Countries", color: Theme.terracotta)
                Divider().frame(height: 40).background(Theme.divider)
                StatItem(icon: "mappin", value: "\(stats.citiesVisited)", label: "Cities", color: Theme.sage)
                Divider().frame(height: 40).background(Theme.divider)
                StatItem(icon: "airplane", value: stats.formattedDistance, label: "Distance", color: Theme.textPrimary)
                Divider().frame(height: 40).background(Theme.divider)
                StatItem(icon: "leaf", value: stats.formattedCO2, label: "CO₂", color: Theme.co2Neutral)
            }
        }
        .perchCard()
    }
}

struct StatItem: View {
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
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Past Trips Section

struct PastTripsSection: View {
    let trips: [Trip]
    let onSelect: (Trip) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Past Trips")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            ForEach(trips) { trip in
                PastTripRow(trip: trip)
                    .onTapGesture {
                        onSelect(trip)
                    }
            }
        }
    }
}

struct PastTripRow: View {
    let trip: Trip

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tripPrimaryLabel)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(tripSubtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(16)
        .background(Theme.surface)
        .cornerRadius(12)
    }

    private var tripPrimaryLabel: String {
        if let firstCity = trip.cities.first {
            return firstCity
        }
        return trip.name
    }

    private var tripSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: trip.startDate)
        let end = trip.endDate.map { formatter.string(from: $0) } ?? ""
        let dateRange = end.isEmpty ? start : "\(start)–\(end)"
        let uniqueCities = Set(trip.cities).count
        return "\(dateRange) · \(trip.formattedDuration) · \(uniqueCities) city\(uniqueCities == 1 ? "" : "s")"
    }
}
