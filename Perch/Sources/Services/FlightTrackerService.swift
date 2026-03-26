import Foundation
import CoreLocation

// R11: Flight Tracker & World Map for Perch
@MainActor
final class FlightTrackerService: ObservableObject {
    static let shared = FlightTrackerService()

    @Published var trackedFlights: [Flight] = []
    @Published var upcomingBills: [UpcomingBill] = []

    struct Flight: Identifiable, Codable {
        let id: UUID
        let flightNumber: String
        let airline: String
        let departureAirport: String
        let arrivalAirport: String
        let departureTime: Date
        let arrivalTime: Date
        var gate: String?
        var status: FlightStatus
        var delayMinutes: Int

        enum FlightStatus: String, Codable {
            case scheduled, boarding, departed, enRoute, arrived, delayed, cancelled
        }
    }

    struct UpcomingBill: Identifiable {
        let id: UUID
        let company: String
        let amount: Double
        let dueDate: Date
    }

    private init() {}

    // MARK: - Flight Tracking

    func trackFlight(number: String) async throws -> Flight {
        // Mock flight data - real implementation would use aviation API
        let flight = Flight(
            id: UUID(),
            flightNumber: number,
            airline: "United",
            departureAirport: "SFO",
            arrivalAirport: "LAX",
            departureTime: Date().addingTimeInterval(3600 * 3),
            arrivalTime: Date().addingTimeInterval(3600 * 5),
            gate: "B12",
            status: .scheduled,
            delayMinutes: 0
        )
        trackedFlights.append(flight)
        return flight
    }

    func fetchFlightStatus(flight: Flight) async throws -> Flight {
        // Update status from API
        return flight
    }

    func scheduleCheckInReminder(for flight: Flight) {
        // TODO: Schedule local notification 24h before departure
        // let reminderTime = flight.departureTime.addingTimeInterval(-24 * 3600)
    }

    // MARK: - World Map Data

    struct CountryVisit: Identifiable {
        let id = UUID()
        let country: String
        let continent: String
        let visitCount: Int
        let dates: [Date]
        let totalCO2: Double // kg
        let photoCount: Int
    }

    func getWorldMapData(visitedCountries: [CountryVisit]) -> WorldMapData {
        WorldMapData(
            countries: visitedCountries,
            mostVisited: visitedCountries.max(by: { $0.visitCount < $1.visitCount })?.country ?? "—",
            totalCountries: visitedCountries.count,
            totalTrips: visitedCountries.reduce(0) { $0 + $1.visitCount }
        )
    }

    struct WorldMapData {
        let countries: [CountryVisit]
        let mostVisited: String
        let totalCountries: Int
        let totalTrips: Int
    }

    // MARK: - PDF Itinerary

    func generateItineraryPDF(tripName: String, flights: [Flight]) -> Data? {
        // Generate simple text-based PDF
        var content = "ITINERARY: \(tripName)\n\n"

        for flight in flights {
            content += "Flight: \(flight.flightNumber)\n"
            content += "\(flight.departureAirport) → \(flight.arrivalAirport)\n"
            content += "Depart: \(flight.departureTime)\n"
            content += "Arrive: \(flight.arrivalTime)\n\n"
        }

        // Convert to Data (in real impl, would generate actual PDF)
        return content.data(using: .utf8)
    }
}
