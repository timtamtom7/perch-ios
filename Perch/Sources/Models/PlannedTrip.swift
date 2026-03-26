import Foundation
import SQLite

/// A planned/scheduled trip — stored separately from completed/active trips.
/// Users can create a planned trip to see a countdown and get weather at destinations.
struct PlannedTrip: Identifiable, Equatable, Codable {
    let id: Int64
    var name: String
    var startDate: Date
    var endDate: Date
    var destinations: [PlannedDestination]
    var transportMode: String
    var notes: String
    var createdAt: Date

    var daysUntilStart: Int {
        let diff = startDate.timeIntervalSince(Date())
        return max(0, Int(diff / 86400))
    }

    var isUpcoming: Bool {
        startDate > Date()
    }

    var isOngoing: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }

    var formattedStart: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: startDate)
    }

    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) – \(end)"
    }

    var totalDays: Int {
        Int(endDate.timeIntervalSince(startDate) / 86400)
    }

    static func == (lhs: PlannedTrip, rhs: PlannedTrip) -> Bool {
        lhs.id == rhs.id
    }
}

struct PlannedDestination: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var city: String
    var country: String?
    var latitude: Double?
    var longitude: Double?
    var arrivalDate: Date?
    var departureDate: Date?
    var order: Int

    var displayName: String {
        if let country = country {
            return "\(city), \(country)"
        }
        return city
    }
}

// MARK: - PlannedTripStore

import os.log

@MainActor
final class PlannedTripStore: ObservableObject {
    private var db: Connection?
    private let plannedTripsTable = Table("planned_trips")
    private let plannedDestinationsTable = Table("planned_destinations")

    private let tripId = Expression<Int64>("id")
    private let tripName = Expression<String>("name")
    private let tripStartDate = Expression<Date>("start_date")
    private let tripEndDate = Expression<Date>("end_date")
    private let tripTransportMode = Expression<String>("transport_mode")
    private let tripNotes = Expression<String>("notes")
    private let tripCreatedAt = Expression<Date>("created_at")

    private let destId = Expression<Int64>("id")
    private let destTripId = Expression<Int64>("trip_id")
    private let destCity = Expression<String>("city")
    private let destCountry = Expression<String?>("country")
    private let destLatitude = Expression<Double?>("latitude")
    private let destLongitude = Expression<Double?>("longitude")
    private let destArrivalDate = Expression<Date?>("arrival_date")
    private let destDepartureDate = Expression<Date?>("departure_date")
    private let destOrder = Expression<Int>("order")

    private let logger = Logger(subsystem: "com.perch.ios", category: "PlannedTripStore")

    @Published var plannedTrips: [PlannedTrip] = []

    init() {
        setupDatabase()
        loadTrips()
    }

    private func setupDatabase() {
        do {
            guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
                logger.error("PlannedTripStore: Could not find documents directory")
                return
            }
            db = try Connection("\(path)/perch.sqlite3")
            try createTables()
            logger.info("PlannedTripStore: Database initialized")
        } catch {
            logger.error("PlannedTripStore: Setup error: \(error.localizedDescription)")
        }
    }

    private func createTables() throws {
        try db?.run(plannedTripsTable.create(ifNotExists: true) { t in
            t.column(tripId, primaryKey: .autoincrement)
            t.column(tripName)
            t.column(tripStartDate)
            t.column(tripEndDate)
            t.column(tripTransportMode, defaultValue: "flight")
            t.column(tripNotes, defaultValue: "")
            t.column(tripCreatedAt)
        })

        try db?.run(plannedDestinationsTable.create(ifNotExists: true) { t in
            t.column(destId, primaryKey: .autoincrement)
            t.column(destTripId)
            t.column(destCity)
            t.column(destCountry)
            t.column(destLatitude)
            t.column(destLongitude)
            t.column(destArrivalDate)
            t.column(destDepartureDate)
            t.column(destOrder)
        })
    }

    private func loadTrips() {
        guard let db = db else { return }
        do {
            var loaded: [PlannedTrip] = []
            for row in try db.prepare(plannedTripsTable.order(tripStartDate.asc)) {
                let id = row[tripId]
                let destinations = loadDestinations(forTripId: id)
                let planned = PlannedTrip(
                    id: id,
                    name: row[tripName],
                    startDate: row[tripStartDate],
                    endDate: row[tripEndDate],
                    destinations: destinations,
                    transportMode: row[tripTransportMode],
                    notes: row[tripNotes],
                    createdAt: row[tripCreatedAt]
                )
                loaded.append(planned)
            }
            plannedTrips = loaded
            logger.info("PlannedTripStore: Loaded \(self.plannedTrips.count) planned trips")
        } catch {
            logger.error("PlannedTripStore: Load error: \(error.localizedDescription)")
        }
    }

    private func loadDestinations(forTripId id: Int64) -> [PlannedDestination] {
        guard let db = db else { return [] }
        var destinations: [PlannedDestination] = []
        do {
            let query = plannedDestinationsTable.filter(destTripId == id).order(destOrder.asc)
            for row in try db.prepare(query) {
                let dest = PlannedDestination(
                    id: UUID(),
                    city: row[destCity],
                    country: row[destCountry],
                    latitude: row[destLatitude],
                    longitude: row[destLongitude],
                    arrivalDate: row[destArrivalDate],
                    departureDate: row[destDepartureDate],
                    order: row[destOrder]
                )
                destinations.append(dest)
            }
        } catch {
            logger.error("PlannedTripStore: Load destinations error: \(error.localizedDescription)")
        }
        return destinations
    }

    @discardableResult
    func createPlannedTrip(
        name: String,
        startDate: Date,
        endDate: Date,
        destinations: [PlannedDestination] = [],
        transportMode: String = "flight",
        notes: String = ""
    ) -> PlannedTrip? {
        guard let db = db else { return nil }
        do {
            let insert = plannedTripsTable.insert(
                tripName <- name,
                tripStartDate <- startDate,
                tripEndDate <- endDate,
                tripTransportMode <- transportMode,
                tripNotes <- notes,
                tripCreatedAt <- Date()
            )
            let newId = try db.run(insert)

            for dest in destinations {
                try db.run(plannedDestinationsTable.insert(
                    destTripId <- newId,
                    destCity <- dest.city,
                    destCountry <- dest.country,
                    destLatitude <- dest.latitude,
                    destLongitude <- dest.longitude,
                    destArrivalDate <- dest.arrivalDate,
                    destDepartureDate <- dest.departureDate,
                    destOrder <- dest.order
                ))
            }

            let planned = PlannedTrip(
                id: newId,
                name: name,
                startDate: startDate,
                endDate: endDate,
                destinations: destinations,
                transportMode: transportMode,
                notes: notes,
                createdAt: Date()
            )
            plannedTrips.append(planned)
            plannedTrips.sort { $0.startDate < $1.startDate }
            logger.info("PlannedTripStore: Created planned trip '\(name)'")
            return planned
        } catch {
            logger.error("PlannedTripStore: Create error: \(error.localizedDescription)")
            return nil
        }
    }

    func deletePlannedTrip(_ trip: PlannedTrip) {
        guard let db = db else { return }
        do {
            let dests = plannedDestinationsTable.filter(destTripId == trip.id)
            try db.run(dests.delete())
            let row = plannedTripsTable.filter(tripId == trip.id)
            try db.run(row.delete())
            plannedTrips.removeAll { $0.id == trip.id }
            logger.info("PlannedTripStore: Deleted planned trip '\(trip.name)'")
        } catch {
            logger.error("PlannedTripStore: Delete error: \(error.localizedDescription)")
        }
    }

    var nextTrip: PlannedTrip? {
        plannedTrips.first { $0.isUpcoming }
    }

    var ongoingTrip: PlannedTrip? {
        plannedTrips.first { $0.isOngoing }
    }
}
