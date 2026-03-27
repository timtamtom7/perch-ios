import SwiftUI

// MARK: - Planned Trips View

struct PlannedTripsView: View {
    @EnvironmentObject var plannedTripStore: PlannedTripStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewPlannedTrip = false
    @State private var selectedTrip: PlannedTrip?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if plannedTripStore.plannedTrips.isEmpty {
                    emptyState
                } else {
                    listContent
                }
            }
            .navigationTitle("Planned Trips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewPlannedTrip = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.terracotta)
                    }
                }
            }
            .sheet(isPresented: $showingNewPlannedTrip) {
                NewPlannedTripSheet()
            }
            .sheet(item: $selectedTrip) { trip in
                PlannedTripDetailView(trip: trip)
            }
        }
    }

    private var listContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Countdown card for next trip
                if let next = plannedTripStore.nextTrip {
                    TripCountdownCard(trip: next) {
                        selectedTrip = next
                    }
                }

                // All planned trips
                ForEach(plannedTripStore.plannedTrips) { trip in
                    PlannedTripRow(trip: trip) {
                        selectedTrip = trip
                    } onDelete: {
                        plannedTripStore.deletePlannedTrip(trip)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 56))
                .foregroundColor(Theme.textSecondary.opacity(0.4))

            VStack(spacing: 6) {
                Text("No Planned Trips")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Plan your upcoming trips to see countdowns and weather forecasts for your destinations.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showingNewPlannedTrip = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Plan a Trip")
                }
            }
            .buttonStyle(PerchButtonStyle())
            .frame(width: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Trip Countdown Card

struct TripCountdownCard: View {
    let trip: PlannedTrip
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Trip")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text(trip.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Countdown
                    VStack(spacing: 2) {
                        Text("\(trip.daysUntilStart)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.terracotta)
                            .minimumScaleFactor(0.7)
                        Text("days")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                HStack {
                    // Dates
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(trip.formattedDateRange)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Theme.textSecondary)

                    Spacer()

                    // Destinations
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                        Text(destinationsText)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Theme.textSecondary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Theme.terracotta.opacity(0.15), Theme.surface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(Theme.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(Theme.terracotta.opacity(0.3), lineWidth: 1)
            )
        }
        .accessibilityLabel("Next trip to \(trip.name), \(trip.daysUntilStart) days away")
    }

    private var destinationsText: String {
        let cities = trip.destinations.prefix(2).map { $0.city }
        let suffix = trip.destinations.count > 2 ? " +\(trip.destinations.count - 2)" : ""
        return cities.joined(separator: " → ") + suffix
    }
}

// MARK: - Planned Trip Row

struct PlannedTripRow: View {
    let trip: PlannedTrip
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteAlert = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status badge
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: statusIcon)
                        .font(.system(size: 16))
                        .foregroundColor(statusColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(trip.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(trip.formattedDateRange)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)

                        Text("·")
                            .foregroundColor(Theme.textSecondary)

                        Text("\(trip.totalDays) days")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)

                        if !trip.destinations.isEmpty {
                            Text("·")
                                .foregroundColor(Theme.textSecondary)
                            Text("\(trip.destinations.count) city\(trip.destinations.count == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }

                Spacer()

                if trip.isUpcoming {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(trip.daysUntilStart)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.terracotta)
                        Text("days")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(14)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Planned Trip?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Delete \"\(trip.name)\"? This cannot be undone.")
        }
    }

    private var statusIcon: String {
        if trip.isOngoing { return "airplane.circle.fill" }
        if trip.isUpcoming { return "calendar.badge.clock" }
        return "checkmark.circle.fill"
    }

    private var statusColor: Color {
        if trip.isOngoing { return Theme.terracotta }
        if trip.isUpcoming { return Theme.sage }
        return Theme.textSecondary
    }
}

// MARK: - Planned Trip Detail View

struct PlannedTripDetailView: View {
    let trip: PlannedTrip
    @EnvironmentObject var plannedTripStore: PlannedTripStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingWeather = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Countdown hero
                    countdownHero

                    // Trip details
                    tripDetailsCard

                    // Destinations
                    if !trip.destinations.isEmpty {
                        destinationsCard
                    }

                    // Weather preview
                    if !trip.destinations.isEmpty {
                        weatherPreview
                    }

                    // Notes
                    if !trip.notes.isEmpty {
                        notesCard
                    }

                    Spacer(minLength: 40)
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

    private var countdownHero: some View {
        VStack(spacing: 12) {
            if trip.isOngoing {
                Label("Currently traveling!", systemImage: "airplane.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.terracotta)
            } else if trip.isUpcoming {
                Text("Starts in")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)

                Text("\(trip.daysUntilStart)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.terracotta)
                    .minimumScaleFactor(0.5)

                Text("days")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.textSecondary)

                Text(trip.formattedStart)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
            } else {
                Text("Trip completed")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.sage)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [Theme.terracotta.opacity(0.12), Theme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(Theme.cornerRadiusLarge)
    }

    private var tripDetailsCard: some View {
        VStack(spacing: 0) {
            detailRow(icon: "calendar", label: "Dates", value: trip.formattedDateRange)
            Divider().background(Theme.divider)
            detailRow(icon: "clock", label: "Duration", value: "\(trip.totalDays) days")
            Divider().background(Theme.divider)
            detailRow(icon: transportIcon, label: "Transport", value: trip.transportMode.capitalized)
            if !trip.destinations.isEmpty {
                Divider().background(Theme.divider)
                detailRow(icon: "mappin", label: "Destinations", value: "\(trip.destinations.count) cities")
            }
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }

    private var destinationsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Destinations")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            ForEach(trip.destinations.sorted { $0.order < $1.order }) { dest in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Theme.terracotta)
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(dest.city)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        if let country = dest.country {
                            Text(country)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }

                    Spacer()

                    if let arrival = dest.arrivalDate {
                        Text(formatDate(arrival))
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(14)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }

    private var weatherPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weather Preview")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            Text("Tap to see weather forecasts for each destination during your trip.")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)

            Button {
                showingWeather = true
            } label: {
                HStack {
                    Image(systemName: "cloud.sun.fill")
                        .foregroundColor(Theme.sage)
                    Text("View Weather")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Theme.textSecondary)
                }
                .foregroundColor(Theme.textPrimary)
                .padding(14)
                .background(Theme.surface)
                .cornerRadius(Theme.cornerRadiusMedium)
            }
            .sheet(isPresented: $showingWeather) {
                PlannedTripWeatherView(trip: trip)
            }
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                Text("Notes")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
            }

            Text(trip.notes)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
                .lineSpacing(4)
        }
        .padding(14)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.terracotta)
                .frame(width: 20)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Theme.textPrimary)
        }
        .padding(14)
    }

    private var transportIcon: String {
        switch trip.transportMode {
        case "car": return "car.fill"
        case "train": return "tram.fill"
        case "bus": return "bus.fill"
        default: return "airplane"
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Planned Trip Weather View

struct PlannedTripWeatherView: View {
    let trip: PlannedTrip
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(trip.destinations.sorted { $0.order < $1.order }) { dest in
                        if dest.latitude != nil && dest.longitude != nil {
                            DestinationWeatherCard(destination: dest, trip: trip)
                        } else {
                            DestinationWeatherPlaceholder(destination: dest)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Weather")
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

struct DestinationWeatherCard: View {
    let destination: PlannedDestination
    let trip: PlannedTrip
    @State private var weather: WeatherForecast?
    @State private var isLoading = true
    @State private var loadError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.terracotta)

                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.city)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    if let country = destination.country {
                        Text(country)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .tint(Theme.terracotta)
                        .scaleEffect(0.8)
                }
            }

            if let weather = weather {
                weatherContent(weather)
            } else if let error = loadError {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
        .task {
            await loadWeather()
        }
    }

    @MainActor
    private func loadWeather() async {
        guard let lat = destination.latitude, let lon = destination.longitude else { return }
        isLoading = true
        do {
            weather = try await WeatherService.shared.fetchForecast(latitude: lat, longitude: lon)
            isLoading = false
        } catch {
            loadError = "Could not load weather"
            isLoading = false
        }
    }

    private func weatherContent(_ weather: WeatherForecast) -> some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weather.daily.prefix(7)) { day in
                        WeatherDayCell(day: day)
                    }
                }
            }

            // Summary
            if let first = weather.daily.first {
                HStack {
                    Label(first.conditionDescription, systemImage: first.conditionIcon)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text("H: \(Int(first.highTemp))° L: \(Int(first.lowTemp))°")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
}

struct DestinationWeatherPlaceholder: View {
    let destination: PlannedDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.city)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    if let country = destination.country {
                        Text(country)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }

                Spacer()
            }

            Text("Location coordinates not available. Weather requires GPS coordinates for the destination city.")
                .font(.system(size: 13))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(16)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusMedium)
    }
}

struct WeatherDayCell: View {
    let day: WeatherDay

    var body: some View {
        VStack(spacing: 4) {
            Text(day.dayName)
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)

            Image(systemName: day.conditionIcon)
                .font(.system(size: 20))
                .foregroundColor(Theme.sage)
                .frame(height: 24)

            Text("\(Int(day.highTemp))°")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.textPrimary)

            Text("\(Int(day.lowTemp))°")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(width: 50)
    }
}

// MARK: - Weather Service

struct WeatherForecast {
    let daily: [WeatherDay]
}

struct WeatherDay: Identifiable {
    let id = UUID()
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: String
    let conditionIcon: String
    let conditionDescription: String

    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

actor WeatherService {
    static let shared = WeatherService()

    private init() {}

    func fetchForecast(latitude: Double, longitude: Double) async throws -> WeatherForecast {
        // Use Open-Meteo free API - no API key required
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto"

        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherError.networkError
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenMeteoResponse.self, from: data)

        let days = zip(result.daily.time, result.daily.temperature_2m_max).enumerated().map { index, pair in
            let (dateStr, high) = pair
            let low = result.daily.temperature_2m_min[index]
            let code = result.daily.weathercode[index]

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withFullDate]
            let date = formatter.date(from: dateStr) ?? Date()

            let (icon, description) = weatherCodeToCondition(code)

            return WeatherDay(
                date: date,
                highTemp: high,
                lowTemp: low,
                condition: "\(code)",
                conditionIcon: icon,
                conditionDescription: description
            )
        }

        return WeatherForecast(daily: days)
    }

    private func weatherCodeToCondition(_ code: Int) -> (icon: String, description: String) {
        switch code {
        case 0: return ("sun.max.fill", "Clear sky")
        case 1, 2, 3: return ("cloud.sun.fill", "Partly cloudy")
        case 45, 48: return ("cloud.fog.fill", "Foggy")
        case 51, 53, 55: return ("cloud.drizzle.fill", "Drizzle")
        case 61, 63, 65: return ("cloud.rain.fill", "Rain")
        case 71, 73, 75: return ("cloud.snow.fill", "Snow")
        case 77: return ("cloud.snow.fill", "Snow grains")
        case 80, 81, 82: return ("cloud.heavyrain.fill", "Rain showers")
        case 85, 86: return ("cloud.snow.fill", "Snow showers")
        case 95: return ("cloud.bolt.rain.fill", "Thunderstorm")
        case 96, 99: return ("cloud.bolt.fill", "Thunderstorm with hail")
        default: return ("cloud.fill", "Unknown")
        }
    }
}

struct OpenMeteoResponse: Codable {
    let daily: OpenMeteoDaily
}

struct OpenMeteoDaily: Codable {
    let time: [String]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let weathercode: [Int]
}

enum WeatherError: Error {
    case invalidURL
    case networkError
    case decodingError
}

extension WeatherError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid weather URL"
        case .networkError: return "Network error loading weather"
        case .decodingError: return "Could not parse weather data"
        }
    }
}

// MARK: - New Planned Trip Sheet

struct NewPlannedTripSheet: View {
    @EnvironmentObject var plannedTripStore: PlannedTripStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var startDate = Date().addingTimeInterval(86400 * 7) // 1 week from now
    @State private var endDate = Date().addingTimeInterval(86400 * 10) // 10 days from now
    @State private var destinationCity = ""
    @State private var destinationCountry = ""
    @State private var destinations: [PlannedDestination] = []
    @State private var transportMode = "flight"
    @State private var notes = ""
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Trip name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Name")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g. Summer in Portugal", text: $name)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                            .focused($isNameFocused)
                    }

                    // Dates
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dates")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(Theme.terracotta)
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)

                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .tint(Theme.terracotta)
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)

                        Text("Duration: \(totalDays) days")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }

                    // Destinations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Destinations")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        ForEach(destinations) { dest in
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(Theme.terracotta)
                                Text(dest.displayName)
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Button {
                                    destinations.removeAll { $0.id == dest.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                        }

                        HStack(spacing: 8) {
                            TextField("City", text: $destinationCity)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textPrimary)
                                .padding(10)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(Theme.cornerRadiusSmall)

                            TextField("Country (optional)", text: $destinationCountry)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.textPrimary)
                                .padding(10)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(Theme.cornerRadiusSmall)

                            Button {
                                addDestination()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(destinationCity.isEmpty ? Theme.textSecondary.opacity(0.3) : Theme.terracotta)
                            }
                            .disabled(destinationCity.isEmpty)
                        }
                    }

                    // Transport mode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Transport")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        HStack(spacing: 12) {
                            ForEach([
                                ("flight", "airplane", "Flight"),
                                ("train", "tram.fill", "Train"),
                                ("car", "car.fill", "Car"),
                                ("bus", "bus.fill", "Bus")
                            ], id: \.0) { mode, icon, label in
                                Button {
                                    transportMode = mode
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                        Text(label)
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(transportMode == mode ? Theme.background : Theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(transportMode == mode ? Theme.terracotta : Theme.surfaceElevated)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                }
                            }
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("Reminders, plans, things to pack…", text: $notes, axis: .vertical)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(3...5)
                            .padding(10)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Plan a Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        createTrip()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(name.isEmpty ? Theme.textSecondary : Theme.terracotta)
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var totalDays: Int {
        max(1, Int(endDate.timeIntervalSince(startDate) / 86400))
    }

    private func addDestination() {
        guard !destinationCity.isEmpty else { return }
        let dest = PlannedDestination(
            city: destinationCity,
            country: destinationCountry.isEmpty ? nil : destinationCountry,
            latitude: nil,
            longitude: nil,
            arrivalDate: nil,
            departureDate: nil,
            order: destinations.count
        )
        destinations.append(dest)
        destinationCity = ""
        destinationCountry = ""
    }

    private func createTrip() {
        guard !name.isEmpty else { return }
        plannedTripStore.createPlannedTrip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            destinations: destinations,
            transportMode: transportMode,
            notes: notes
        )
        dismiss()
    }
}
