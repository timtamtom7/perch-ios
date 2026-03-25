import Foundation
import CoreLocation

/// R7: Deep AI analysis for travel patterns, CO2 insights, destination recommendations
@MainActor
final class DeepTravelAnalysisService: ObservableObject {
    static let shared = DeepTravelAnalysisService()

    @Published private(set) var isAnalyzing = false
    @Published private(set) var analysisProgress: Double = 0
    @Published private(set) var travelPatterns: [TravelPattern] = []
    @Published private(set) var co2Insights: [CO2Insight] = []
    @Published private(set) var recommendations: [DestinationRecommendation] = []

    struct TravelPattern: Identifiable {
        let id = UUID()
        let type: PatternType
        let title: String
        let description: String
        let frequency: Int
        let co2Saved: Double

        enum PatternType {
            case frequentFlyer
            case roadTrip
            case weekendGetaway
            case ecoTraveler
        }
    }

    struct CO2Insight: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let value: String
        let comparison: String
        let trend: Trend

        enum Trend {
            case up, down, neutral
        }
    }

    struct DestinationRecommendation: Identifiable {
        let id = UUID()
        let destination: String
        let country: String
        let reason: String
        let ecoScore: Int
        let imageSystemName: String
    }

    private let userDefaults = UserDefaults.standard

    private init() {}

    // MARK: - Analyze All Trips

    func analyzeAll(trips: [Trip]) async {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        analysisProgress = 0

        // Simulate analysis
        try? await Task.sleep(nanoseconds: 500_000_000)

        generateTravelPatterns(from: trips)
        analysisProgress = 0.5

        generateCO2Insights(from: trips)
        analysisProgress = 0.75

        generateRecommendations(from: trips)
        analysisProgress = 1.0

        isAnalyzing = false
    }

    private func generateTravelPatterns(from trips: [Trip]) {
        var patterns: [TravelPattern] = []

        let totalTrips = trips.count
        if totalTrips > 20 {
            patterns.append(TravelPattern(
                type: .frequentFlyer,
                title: "Frequent Traveler",
                description: "You've taken \(totalTrips) trips! You're a seasoned traveler.",
                frequency: totalTrips,
                co2Saved: 0
            ))
        }

        let carTrips = trips.filter { $0.transportMode == "car" }
        if !carTrips.isEmpty && Double(carTrips.count) / Double(max(1, totalTrips)) > 0.5 {
            patterns.append(TravelPattern(
                type: .roadTrip,
                title: "Road Trip Enthusiast",
                description: "Over half your trips are by car. Consider trains for shorter routes!",
                frequency: carTrips.count,
                co2Saved: 0
            ))
        }

        let shortTrips = trips.filter { $0.totalDistanceKm < 500 }
        if shortTrips.count > 5 {
            patterns.append(TravelPattern(
                type: .weekendGetaway,
                title: "Weekend Wanderer",
                description: "You love short getaways! \(shortTrips.count) trips under 500km.",
                frequency: shortTrips.count,
                co2Saved: 0
            ))
        }

        let trainTrips = trips.filter { $0.transportMode == "train" }
        if !trainTrips.isEmpty && Double(trainTrips.count) / Double(max(1, totalTrips)) > 0.3 {
            let co2Saved = calculateCo2Saved(byReplacingCarWithTrain: trainTrips.count)
            patterns.append(TravelPattern(
                type: .ecoTraveler,
                title: "Eco-conscious Explorer",
                description: "Trains for \(Int(Double(trainTrips.count)/Double(totalTrips)*100))% of trips. Great for the planet!",
                frequency: trainTrips.count,
                co2Saved: co2Saved
            ))
        }

        travelPatterns = patterns
    }

    private func generateCO2Insights(from trips: [Trip]) {
        let totalCO2 = trips.reduce(0) { $0 + $1.co2Estimate }
        let avgCO2PerTrip = trips.isEmpty ? 0 : totalCO2 / Double(trips.count)
        let totalDistance = trips.reduce(0) { $0 + $1.totalDistanceKm }

        var insights: [CO2Insight] = []

        insights.append(CO2Insight(
            icon: "cloud.fill",
            title: "Total CO2",
            value: String(format: "%.1f kg", totalCO2),
            comparison: "Avg \(String(format: "%.1f", avgCO2PerTrip)) kg/trip",
            trend: totalCO2 > 1000 ? .up : .down
        ))

        insights.append(CO2Insight(
            icon: "location.fill",
            title: "Distance Traveled",
            value: String(format: "%.0f km", totalDistance),
            comparison: "\(trips.count) trips",
            trend: .neutral
        ))

        let carCO2 = trips.filter { $0.transportMode == "car" }.reduce(0) { $0 + $1.co2Estimate }
        if carCO2 > 0 {
            insights.append(CO2Insight(
                icon: "car.fill",
                title: "Car CO2",
                value: String(format: "%.1f kg", carCO2),
                comparison: "\(Int(carCO2/totalCO2*100))% of total",
                trend: carCO2 > totalCO2 * 0.5 ? .up : .down
            ))
        }

        co2Insights = insights
    }

    private func generateRecommendations(from trips: [Trip]) {
        let visitedCities = Set(trips.flatMap { $0.cities })

        var recs: [DestinationRecommendation] = []

        // Eco-friendly train destinations
        let trainDestinations = [
            ("Zurich", "Switzerland"),
            ("Amsterdam", "Netherlands"),
            ("Barcelona", "Spain"),
            ("Paris", "France"),
            ("Munich", "Germany")
        ]
        for (city, country) in trainDestinations where !visitedCities.contains(city) {
            recs.append(DestinationRecommendation(
                destination: city,
                country: country,
                reason: "Accessible by train from most European cities",
                ecoScore: 90,
                imageSystemName: "tram.fill"
            ))
        }

        // Exotic destinations
        let exoticDestinations = [
            ("Kyoto", "Japan"),
            ("Cape Town", "South Africa"),
            ("Patagonia", "Argentina"),
            ("Iceland", "Iceland")
        ]
        for (city, country) in exoticDestinations where !visitedCities.contains(city) {
            recs.append(DestinationRecommendation(
                destination: city,
                country: country,
                reason: "Unique experiences with low tourism impact",
                ecoScore: 75,
                imageSystemName: "leaf.fill"
            ))
        }

        recommendations = Array(recs.prefix(6))
    }

    private func calculateCo2Saved(byReplacingCarWithTrain count: Int) -> Double {
        let avgTripDistance = 300.0
        let carCO2PerKm = 0.12
        let trainCO2PerKm = 0.03
        let savedPerTrip = avgTripDistance * (carCO2PerKm - trainCO2PerKm)
        return Double(count) * savedPerTrip
    }
}
