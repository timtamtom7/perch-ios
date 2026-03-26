import Foundation
import Combine

final class TravelInsightsService: ObservableObject {
    private let tripStore: TripStore

    init(tripStore: TripStore) {
        self.tripStore = tripStore
    }

    // MARK: - City Rankings

    struct CityRanking: Identifiable {
        let id = UUID()
        let city: String
        let country: String?
        let visitCount: Int
        let lastVisited: Date
        let totalDays: Int
        let rank: Int
    }

    func cityRankings(year: Int? = nil) -> [CityRanking] {
        let trips = year.map { tripStore.tripsForYear($0) } ?? tripStore.trips.filter { !$0.isActive }

        var cityData: [String: (country: String?, count: Int, lastVisit: Date, days: Int)] = [:]

        for trip in trips {
            for visit in trip.visits {
                guard let city = visit.city else { continue }
                let existing = cityData[city]
                let days = visit.duration.map { Int($0 / 86400) } ?? 0
                cityData[city] = (
                    country: visit.country ?? existing?.country,
                    count: (existing?.count ?? 0) + 1,
                    lastVisit: max(visit.arrivalDate, existing?.lastVisit ?? .distantPast),
                    days: (existing?.days ?? 0) + days
                )
            }
        }

        let sorted = cityData.sorted { $0.value.count > $1.value.count }
        return sorted.enumerated().map { index, entry in
            CityRanking(
                city: entry.key,
                country: entry.value.country,
                visitCount: entry.value.count,
                lastVisited: entry.value.lastVisit,
                totalDays: entry.value.days,
                rank: index + 1
            )
        }
    }

    // MARK: - Country Rankings

    struct CountryRanking: Identifiable {
        let id = UUID()
        let country: String
        let visitCount: Int
        let lastVisited: Date
        let rank: Int
    }

    func countryRankings(year: Int? = nil) -> [CountryRanking] {
        let trips = year.map { tripStore.tripsForYear($0) } ?? tripStore.trips.filter { !$0.isActive }

        var countryData: [String: (count: Int, lastVisit: Date)] = [:]

        for trip in trips {
            for visit in trip.visits {
                guard let country = visit.country else { continue }
                let existing = countryData[country]
                countryData[country] = (
                    count: (existing?.count ?? 0) + 1,
                    lastVisit: max(visit.arrivalDate, existing?.lastVisit ?? .distantPast)
                )
            }
        }

        let sorted = countryData.sorted { $0.value.count > $1.value.count }
        return sorted.enumerated().map { index, entry in
            CountryRanking(
                country: entry.key,
                visitCount: entry.value.count,
                lastVisited: entry.value.lastVisit,
                rank: index + 1
            )
        }
    }

    // MARK: - Travel Streaks

    struct TravelStreak {
        let year: Int
        let consecutiveMonthsWithTravel: Int
        let totalMonthsWithTravel: Int
        let longestTripDays: Int
        let monthlyBreakdown: [Int: Int] // month -> days traveled
    }

    func travelStreak(year: Int) -> TravelStreak {
        let trips = tripStore.tripsForYear(year).filter { !$0.isActive }

        var monthsWithTravel = Set<Int>()
        var monthlyDays: [Int: Int] = [:]
        var longestTrip = 0

        for trip in trips {
            let cal = Calendar.current
            let startMonth = cal.component(.month, from: trip.startDate)
            let endMonth = trip.endDate.map { cal.component(.month, from: $0) } ?? startMonth
            monthsWithTravel.insert(startMonth)
            if startMonth != endMonth {
                monthsWithTravel.insert(endMonth)
            }

            let days = trip.durationDays
            if days > longestTrip { longestTrip = days }

            for month in startMonth...endMonth {
                monthlyDays[month, default: 0] += 1
            }
        }

        // Count consecutive months from start of year
        var consecutive = 0
        for month in 1...12 {
            if monthsWithTravel.contains(month) {
                consecutive += 1
            } else {
                break
            }
        }

        return TravelStreak(
            year: year,
            consecutiveMonthsWithTravel: consecutive,
            totalMonthsWithTravel: monthsWithTravel.count,
            longestTripDays: longestTrip,
            monthlyBreakdown: monthlyDays
        )
    }

    // MARK: - Travel Frequency

    struct TravelFrequency {
        let tripsThisYear: Int
        let tripsLastYear: Int
        let averageTripDuration: Double
        let averageCitiesPerTrip: Double
        let mostActiveMonth: Int?
        let leastActiveMonth: Int?
    }

    func travelFrequency(year: Int) -> TravelFrequency {
        let thisYear = tripStore.tripsForYear(year).filter { !$0.isActive }
        let lastYear = tripStore.tripsForYear(year - 1).filter { !$0.isActive }

        var monthlyTripCount: [Int: Int] = [:]
        for trip in thisYear {
            let month = Calendar.current.component(.month, from: trip.startDate)
            monthlyTripCount[month, default: 0] += 1
        }

        let avgDuration = thisYear.isEmpty ? 0 : Double(thisYear.reduce(0) { $0 + $1.durationDays }) / Double(thisYear.count)
        let avgCities = thisYear.isEmpty ? 0 : Double(thisYear.reduce(0) { $0 + $1.cities.count }) / Double(thisYear.count)

        let sortedMonths = monthlyTripCount.sorted { $0.value > $1.value }

        return TravelFrequency(
            tripsThisYear: thisYear.count,
            tripsLastYear: lastYear.count,
            averageTripDuration: avgDuration,
            averageCitiesPerTrip: avgCities,
            mostActiveMonth: sortedMonths.first?.key,
            leastActiveMonth: sortedMonths.last?.key
        )
    }

    // MARK: - Total Distance All Time

    var totalDistanceAllTime: Double {
        tripStore.trips.filter { !$0.isActive }.reduce(0) { $0 + $1.totalDistance }
    }

    // MARK: - CO₂ Breakdown by Transport Mode

    struct CO2Breakdown {
        let flightKg: Double
        let carKg: Double
        let trainKg: Double
        let busKg: Double

        var total: Double {
            flightKg + carKg + trainKg + busKg
        }

        var flightPercent: Double { total > 0 ? flightKg / total : 0 }
        var carPercent: Double { total > 0 ? carKg / total : 0 }
        var trainPercent: Double { total > 0 ? trainKg / total : 0 }
        var busPercent: Double { total > 0 ? busKg / total : 0 }

        var formattedTotal: String {
            if total >= 1000 {
                return String(format: "~%.1ft CO₂", total / 1000)
            }
            return String(format: "~%.0fkg CO₂", total)
        }
    }

    func co2Breakdown(year: Int? = nil) -> CO2Breakdown {
        let trips = year.map { tripStore.tripsForYear($0) } ?? tripStore.trips.filter { !$0.isActive }

        var flightKm: Double = 0
        var carKm: Double = 0
        var trainKm: Double = 0
        var busKm: Double = 0

        for trip in trips {
            let km = trip.totalDistanceKm
            switch trip.transportMode {
            case "car": carKm += km
            case "train": trainKm += km
            case "bus": busKm += km
            default: flightKm += km
            }
        }

        return CO2Breakdown(
            flightKg: flightKm * CO2Estimator.airTravelPerKm,
            carKg: carKm * CO2Estimator.carTravelPerKm,
            trainKg: trainKm * CO2Estimator.trainTravelPerKm,
            busKg: busKm * CO2Estimator.busTravelPerKm
        )
    }

    // MARK: - Compare to Average Traveler

    struct TravelerComparison {
        let yourCountries: Int
        let avgCountries: Int
        let yourCO2: Double
        let avgCO2: Double
        let yourTrips: Int
        let avgTrips: Double

        var countriesVersusAverage: String {
            let diff = yourCountries - avgCountries
            if diff > 2 { return "Well above average" }
            if diff > 0 { return "Above average" }
            if diff == 0 { return "Average" }
            return "Room to explore"
        }

        var co2VersusAverage: String {
            if yourCO2 < avgCO2 * 0.7 { return "Lower than average" }
            if yourCO2 < avgCO2 { return "Below average" }
            if yourCO2 <= avgCO2 * 1.3 { return "Average" }
            return "Above average"
        }
    }

    func compareToAverage(year: Int) -> TravelerComparison {
        let stats = tripStore.travelStats(for: year)
        let trips = tripStore.tripsForYear(year).filter { !$0.isActive }

        // Global averages per year (rough estimates based on travel surveys):
        // Average traveler: ~6 countries/year (heavily skewed by frequent flyers)
        // Moderate traveler: ~2-3 countries/year
        // Average CO₂: ~1.5t/year for moderate flyers
        // Average trips: ~3-4/year

        let avgCountries = 3
        let avgCO2 = 1500.0  // kg
        let avgTrips = 3.5

        return TravelerComparison(
            yourCountries: stats.countriesVisited,
            avgCountries: avgCountries,
            yourCO2: stats.totalCO2Kg,
            avgCO2: avgCO2,
            yourTrips: trips.count,
            avgTrips: avgTrips
        )
    }

    // MARK: - Trip Comparison

    struct TripComparison {
        let trip: Trip
        let averageDuration: Double
        let averageDistance: Double
        let averageCO2: Double
        let durationDiff: Double      // in days
        let distanceDiff: Double      // in km
        let co2Diff: Double           // in kg
        let durationVsAverage: String
        let distanceVsAverage: String
    }

    func compareTrip(_ trip: Trip) -> TripComparison {
        let completed = tripStore.trips.filter { !$0.isActive }
        guard !completed.isEmpty else {
            return TripComparison(
                trip: trip,
                averageDuration: 0,
                averageDistance: 0,
                averageCO2: 0,
                durationDiff: 0,
                distanceDiff: 0,
                co2Diff: 0,
                durationVsAverage: "No data",
                distanceVsAverage: "No data"
            )
        }

        let avgDuration = completed.reduce(0) { $0 + $1.duration } / Double(completed.count)
        let avgDistance = completed.reduce(0) { $0 + $1.totalDistance } / Double(completed.count)
        let avgCO2 = completed.reduce(0) { $0 + $1.co2Estimate } / Double(completed.count)

        let durationDiff = (trip.duration - avgDuration) / 86400
        let distanceDiff = (trip.totalDistance - avgDistance) / 1000
        let co2Diff = trip.co2Estimate - avgCO2

        return TripComparison(
            trip: trip,
            averageDuration: avgDuration,
            averageDistance: avgDistance,
            averageCO2: avgCO2,
            durationDiff: durationDiff,
            distanceDiff: distanceDiff,
            co2Diff: co2Diff,
            durationVsAverage: formatDiff(durationDiff, unit: "day"),
            distanceVsAverage: formatDiff(distanceDiff, unit: "km")
        )
    }

    private func formatDiff(_ value: Double, unit: String) -> String {
        if abs(value) < 0.5 { return "Average" }
        let absVal = abs(value)
        let rounded = absVal < 10 ? absVal : absVal.rounded()
        let direction = value > 0 ? "longer" : "shorter"
        if unit == "km" && value > 0 { return "+\(Int(rounded)) km more" }
        if unit == "km" && value < 0 { return "\(Int(rounded)) km less" }
        if unit == "day" && value > 0 { return "\(Int(rounded)) day\(absVal >= 2 ? "s" : "") \(direction)" }
        if unit == "day" && value < 0 { return "\(Int(absVal)) day\(absVal >= 2 ? "s" : "") \(direction)" }
        return "Average"
    }
}
