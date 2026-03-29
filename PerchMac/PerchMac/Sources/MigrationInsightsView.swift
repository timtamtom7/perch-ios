import SwiftUI

struct MigrationInsightsView: View {
    @State private var selectedRegion: Region = .northAmerica
    @State private var selectedSpecies: BirdSpecies?
    @State private var migrationData: [MigrationPrediction] = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            ScrollView {
                VStack(spacing: 24) {
                    // Current Season Status
                    seasonStatusCard

                    // Best Time to See
                    bestTimeSection

                    // Migration Calendar
                    migrationCalendarSection
                }
                .padding()
            }
        }
        .background(Theme.cream)
        .onAppear {
            loadMigrationData()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Migration Insights")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Text("Based on historical sighting data")
                .font(.system(size: 14))
                .foregroundColor(Theme.textSecondary)
        }
        .padding()
    }

    // MARK: - Season Status Card

    private var seasonStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: currentSeasonIcon)
                    .font(.system(size: 32))
                    .foregroundColor(Theme.forestGreen)

                VStack(alignment: .leading, spacing: 4) {
                    Text(currentSeasonTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(currentSeasonDescription)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()
            }

            Divider()

            // Species arriving/departing now
            VStack(alignment: .leading, spacing: 12) {
                Text("Currently Migrating")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                ForEach(migrationData.filter { $0.status == .arriving || $0.status == .departing }.prefix(3)) { prediction in
                    migrationRow(for: prediction)
                }

                if migrationData.filter({ $0.status == .arriving || $0.status == .departing }).isEmpty {
                    Text("No active migration in your region")
                        .font(.system(size: 14))
                        .italic()
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding()
        .background(Theme.cardBg)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Best Time Section

    private var bestTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Best Time to See Species")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(migrationData.filter { $0.status == .peakSeason }.prefix(4)) { prediction in
                    bestTimeCard(for: prediction)
                }
            }

            if migrationData.filter({ $0.status == .peakSeason }).isEmpty {
                Text("No species at peak season right now")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Theme.cardBg)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Migration Calendar Section

    private var migrationCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Seasonal Migration Calendar")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                Menu {
                    Button("North America") { selectedRegion = .northAmerica }
                    Button("Europe") { selectedRegion = .europe }
                    Button("World") { selectedRegion = .world }
                } label: {
                    HStack {
                        Text(selectedRegion.name)
                        Image(systemName: "chevron.down")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Theme.forestGreen)
                }
            }

            // Month labels
            HStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { month in
                    Text(monthAbbreviation(month))
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Migration bars
            ForEach(migrationData.prefix(6)) { prediction in
                migrationCalendarRow(for: prediction)
            }
        }
        .padding()
        .background(Theme.cardBg)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Helper Views

    private func migrationRow(for prediction: MigrationPrediction) -> some View {
        HStack {
            Circle()
                .fill(statusColor(for: prediction.status))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(prediction.speciesName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                Text(statusText(for: prediction.status))
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            Text("~\(Int(prediction.confidence * 100))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.forestGreen)
        }
    }

    private func bestTimeCard(for prediction: MigrationPrediction) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Theme.barkBrown)
                    .font(.system(size: 12))

                Text(prediction.speciesName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
            }

            Text("\(formatDate(prediction.peakStart)) - \(formatDate(prediction.peakEnd))")
                .font(.system(size: 11))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surface)
        .cornerRadius(8)
    }

    private func migrationCalendarRow(for prediction: MigrationPrediction) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(prediction.speciesName)
                .font(.system(size: 11))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Theme.surface)
                        .frame(height: 8)
                        .cornerRadius(4)

                    // Migration period
                    let startX = (CGFloat(prediction.typicalArrival.dayOfYear) / 365.0) * geometry.size.width
                    let endX = (CGFloat(prediction.typicalDeparture.dayOfYear) / 365.0) * geometry.size.width
                    let width = max(0, endX - startX)

                    Rectangle()
                        .fill(statusColor(for: prediction.status))
                        .frame(width: width, height: 8)
                        .cornerRadius(4)
                        .offset(x: startX)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Helper Methods

    private func loadMigrationData() {
        // Generate sample migration data based on species
        migrationData = SpeciesDataService.shared.species.prefix(20).map { species in
            MigrationPrediction(
                speciesId: species.id,
                speciesName: species.commonName,
                typicalArrival: generateArrivalDate(for: species),
                typicalDeparture: generateDepartureDate(for: species),
                peakStart: generatePeakStart(for: species),
                peakEnd: generatePeakEnd(for: species),
                confidence: Double.random(in: 0.65...0.95),
                status: determineStatus(for: species)
            )
        }
    }

    private func generateArrivalDate(for species: BirdSpecies) -> Date {
        // Spring arrival (March-May for most migratory birds)
        let month = Int.random(in: 3...5)
        let day = Int.random(in: 1...28)
        return Calendar.current.date(from: DateComponents(month: month, day: day)) ?? Date()
    }

    private func generateDepartureDate(for species: BirdSpecies) -> Date {
        // Fall departure (September-November)
        let month = Int.random(in: 9...11)
        let day = Int.random(in: 1...28)
        return Calendar.current.date(from: DateComponents(month: month, day: day)) ?? Date()
    }

    private func generatePeakStart(for species: BirdSpecies) -> Date {
        // Peak season (June-August)
        let month = Int.random(in: 6...7)
        let day = Int.random(in: 1...28)
        return Calendar.current.date(from: DateComponents(month: month, day: day)) ?? Date()
    }

    private func generatePeakEnd(for species: BirdSpecies) -> Date {
        // Peak season end (August)
        let month = 8
        let day = Int.random(in: 1...28)
        return Calendar.current.date(from: DateComponents(month: month, day: day)) ?? Date()
    }

    private func determineStatus(for species: BirdSpecies) -> MigrationStatus {
        let month = Calendar.current.component(.month, from: Date())

        if species.migrationPattern.lowercased().contains("resident") {
            return .yearRound
        } else if species.migrationPattern.lowercased().contains("partial") {
            if month >= 4 && month <= 9 {
                return .peakSeason
            } else if month >= 3 && month <= 4 {
                return .arriving
            } else if month >= 9 && month <= 10 {
                return .departing
            }
        }

        // Default based on current month
        switch month {
        case 3...5: return .arriving
        case 6...8: return .peakSeason
        case 9...11: return .departing
        default: return .notExpected
        }
    }

    private func statusColor(for status: MigrationStatus) -> Color {
        switch status {
        case .arriving: return Color.blue
        case .peakSeason: return Color.green
        case .departing: return Color.orange
        case .yearRound: return Color.gray
        case .notExpected: return Color.clear
        }
    }

    private func statusText(for status: MigrationStatus) -> String {
        switch status {
        case .arriving: return "Arriving in region"
        case .peakSeason: return "Peak season"
        case .departing: return "Departing region"
        case .yearRound: return "Year-round resident"
        case .notExpected: return "Not expected"
        }
    }

    private var currentSeasonIcon: String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return "arrow.up.circle.fill"
        case 6...8: return "sun.max.fill"
        case 9...11: return "arrow.down.circle.fill"
        default: return "snowflake"
        }
    }

    private var currentSeasonTitle: String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return "Spring Migration"
        case 6...8: return "Breeding Season"
        case 9...11: return "Fall Migration"
        default: return "Winter Season"
        }
    }

    private var currentSeasonDescription: String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 3...5: return "Birds are returning to breed in your region"
        case 6...8: return "Many species are nesting and raising young"
        case 9...11: return "Birds are heading south for winter"
        default: return "Some birds spend winter in your region"
        }
    }

    private func monthAbbreviation(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - MigrationPrediction Model

struct MigrationPrediction: Identifiable {
    let id = UUID()
    let speciesId: String
    let speciesName: String
    let typicalArrival: Date
    let typicalDeparture: Date
    let peakStart: Date
    let peakEnd: Date
    let confidence: Double
    let status: MigrationStatus
}

enum MigrationStatus {
    case arriving
    case peakSeason
    case departing
    case yearRound
    case notExpected
}

// MARK: - Date Extension

extension Date {
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 0
    }
}

#Preview {
    MigrationInsightsView()
        .frame(width: 600, height: 700)
}
