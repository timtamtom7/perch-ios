import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @EnvironmentObject var templateStore: TemplateStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingSettings = false
    @State private var showingStartTripInfo = false
    @State private var showingPricing = false
    @State private var selectedTrip: Trip?
    @State private var showingOnboarding = false
    @State private var showingTemplates = false
    @State private var showingMultiTrip = false
    @State private var showingInsights = false
    @State private var showingLocationInsufficient = false

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var insights: TravelInsightsService {
        TravelInsightsService(tripStore: tripStore)
    }

    var body: some View {
        NavigationStack {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if tripStore.trips.isEmpty {
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
                        if tripStore.activeTrips.count > 1 {
                            Button {
                                showingMultiTrip = true
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "suitcase.fill")
                                        .foregroundColor(Theme.sage)
                                    Circle()
                                        .fill(Theme.terracotta)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }

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
            .sheet(isPresented: $showingTemplates) {
                TripTemplatesView()
            }
            .sheet(isPresented: $showingMultiTrip) {
                MultiTripView()
            }
            .sheet(isPresented: $showingInsights) {
                TravelInsightsFullView(year: currentYear)
            }
            .sheet(item: $selectedTrip) { trip in
                TripDetailView(trip: trip)
            }
            .alert("Location Data Insufficient", isPresented: $showingLocationInsufficient) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Perch hasn't recorded enough location data for this trip. Make sure location access is enabled and try moving to a new city.")
            }
        }
        .onAppear {
            checkLocationPermission()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didRecordNewVisit)) { notification in
            if let userInfo = notification.userInfo,
               let city = userInfo["city"] as? String, !city.isEmpty {
                // Good visit recorded
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Active trips (if multiple)
                if tripStore.activeTrips.count > 1 {
                    MultipleActiveTripsBanner(
                        count: tripStore.activeTrips.count,
                        onTap: { showingMultiTrip = true }
                    )
                }

                if let active = tripStore.activeTrip {
                    ActiveTripCard(trip: active)
                }

                // Travel summary
                TravelSummaryCard(stats: tripStore.travelStats(for: currentYear))

                // Quick insights teaser
                if !tripStore.trips.filter({ !$0.isActive }).isEmpty {
                    QuickInsightsTeaser(
                        stats: tripStore.travelStats(for: currentYear),
                        onTap: { showingInsights = true }
                    )
                }

                // CO₂ Breakdown (if data available)
                let breakdown = insights.co2Breakdown(year: currentYear)
                if breakdown.total > 0 {
                    CO2BreakdownChartView(breakdown: breakdown, year: currentYear)
                }

                // Trip Templates
                if !tripStore.trips.filter({ !$0.isActive }).isEmpty {
                    TripTemplatesSection(onShowAll: { showingTemplates = true })
                }

                // City Rankings (if data available)
                let cityRankings = insights.cityRankings(year: currentYear)
                if !cityRankings.isEmpty {
                    MostVisitedCitiesView(rankings: cityRankings)
                }

                // Start new trip / Use template
                if tripStore.activeTrip == nil {
                    HStack(spacing: 12) {
                        Button {
                            showingStartTripInfo = true
                        } label: {
                            HStack {
                                Image(systemName: "airplane")
                                Text("Start New Trip")
                            }
                        }
                        .buttonStyle(PerchButtonStyle())

                        Button {
                            showingTemplates = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Templates")
                            }
                        }
                        .buttonStyle(PerchButtonStyle(isPrimary: false))
                    }
                }

                // Past Trips
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
        // Check periodically
    }
}

// MARK: - Multiple Active Trips Banner

struct MultipleActiveTripsBanner: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.sage.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: "suitcase.fill")
                        .foregroundColor(Theme.sage)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(count) trips running")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Tap to manage")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(14)
            .background(Theme.sage.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.sage.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Quick Insights Teaser

struct QuickInsightsTeaser: View {
    let stats: TravelStats
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.terracotta)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Travel Insights")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    Text(insightTeaser)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(14)
            .background(Theme.surface)
            .cornerRadius(12)
        }
    }

    private var insightTeaser: String {
        if stats.countriesVisited == 0 {
            return "Start traveling to see insights"
        } else if stats.countriesVisited < 3 {
            return "\(stats.countriesVisited) country\(stats.countriesVisited == 1 ? "" : "ries") visited"
        } else if stats.countriesVisited < 6 {
            return "\(stats.countriesVisited) countries and counting"
        } else {
            return "You're a seasoned traveler"
        }
    }
}

// MARK: - Trip Templates Section

struct TripTemplatesSection: View {
    let onShowAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Trip Templates")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Spacer()

                Button {
                    onShowAll()
                } label: {
                    Text("See all")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.terracotta)
                }
            }

            HStack(spacing: 12) {
                QuickTemplateCard(
                    name: "Weekend Break",
                    icon: "calendar.badge.clock",
                    duration: "3 days"
                )

                QuickTemplateCard(
                    name: "One Week",
                    icon: "airplane",
                    duration: "7 days"
                )

                QuickTemplateCard(
                    name: "Japan Trip",
                    icon: "globe",
                    duration: "10 days"
                )
            }
        }
    }
}

struct QuickTemplateCard: View {
    let name: String
    let icon: String
    let duration: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.terracotta)

            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)

            Text(duration)
                .font(.system(size: 10))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.surface)
        .cornerRadius(12)
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

// MARK: - Travel Insights Full View

struct TravelInsightsFullView: View {
    let year: Int
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss

    private var insights: TravelInsightsService {
        TravelInsightsService(tripStore: tripStore)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    let stats = tripStore.travelStats(for: year)

                    // CO₂ comparison
                    let comparison = insights.compareToAverage(year: year)
                    CO2ComparisonView(comparison: comparison, year: year)

                    // CO₂ breakdown chart
                    let breakdown = insights.co2Breakdown(year: year)
                    if breakdown.total > 0 {
                        CO2BreakdownChartView(breakdown: breakdown, year: year)
                    }

                    // City rankings
                    let cityRankings = insights.cityRankings(year: year)
                    if !cityRankings.isEmpty {
                        MostVisitedCitiesView(rankings: cityRankings)
                    }

                    // Travel streaks and frequency
                    let streak = insights.travelStreak(year: year)
                    let frequency = insights.travelFrequency(year: year)
                    TravelStreaksView(streak: streak, frequency: frequency, year: year)

                    // Total distance
                    let distance = insights.totalDistanceAllTime
                    if distance > 0 {
                        TotalDistanceView(distanceMeters: distance, year: year)
                    }

                    Spacer(minLength: 40)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Travel Insights")
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
