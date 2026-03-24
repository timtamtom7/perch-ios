import Foundation
import SQLite

final class TripStore: ObservableObject {
    private var db: Connection?
    private let tripsTable = Table("trips")
    private let visitsTable = Table("visits")

    // Trip columns
    private let tripId = Expression<Int64>("id")
    private let tripName = Expression<String>("name")
    private let tripStartDate = Expression<Date>("start_date")
    private let tripEndDate = Expression<Date?>("end_date")
    private let tripIsActive = Expression<Bool>("is_active")

    // Visit columns
    private let visitId = Expression<Int64>("id")
    private let visitTripId = Expression<Int64>("trip_id")
    private let visitCity = Expression<String?>("city")
    private let visitCountry = Expression<String?>("country")
    private let visitLatitude = Expression<Double>("latitude")
    private let visitLongitude = Expression<Double>("longitude")
    private let visitArrivalDate = Expression<Date>("arrival_date")
    private let visitDepartureDate = Expression<Date?>("departure_date")
    private let visitOrder = Expression<Int>("visit_order")

    @Published var trips: [Trip] = []
    @Published var activeTrip: Trip?

    init() {
        setupDatabase()
        loadTrips()
    }

    private func setupDatabase() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/perch.sqlite3")
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(tripsTable.create(ifNotExists: true) { t in
            t.column(tripId, primaryKey: .autoincrement)
            t.column(tripName)
            t.column(tripStartDate)
            t.column(tripEndDate)
            t.column(tripIsActive)
        })

        try db?.run(visitsTable.create(ifNotExists: true) { t in
            t.column(visitId, primaryKey: .autoincrement)
            t.column(visitTripId)
            t.column(visitCity)
            t.column(visitCountry)
            t.column(visitLatitude)
            t.column(visitLongitude)
            t.column(visitArrivalDate)
            t.column(visitDepartureDate)
            t.column(visitOrder)
        })
    }

    func loadTrips() {
        guard let db = db else { return }
        do {
            var loadedTrips: [Trip] = []
            for row in try db.prepare(tripsTable.order(tripStartDate.desc)) {
                let id = row[tripId]
                let visits = loadVisits(forTripId: id)
                let trip = Trip(
                    id: id,
                    name: row[tripName],
                    startDate: row[tripStartDate],
                    endDate: row[tripEndDate],
                    isActive: row[tripIsActive],
                    visits: visits
                )
                loadedTrips.append(trip)
                if trip.isActive {
                    activeTrip = trip
                }
            }
            trips = loadedTrips
        } catch {
            print("Load trips error: \(error)")
        }
    }

    private func loadVisits(forTripId tripIdValue: Int64) -> [Visit] {
        guard let db = db else { return [] }
        var visits: [Visit] = []
        do {
            let query = visitsTable.filter(visitTripId == tripIdValue).order(visitOrder.asc)
            for row in try db.prepare(query) {
                let visit = Visit(
                    id: row[visitId],
                    tripId: row[visitTripId],
                    city: row[visitCity],
                    country: row[visitCountry],
                    latitude: row[visitLatitude],
                    longitude: row[visitLongitude],
                    arrivalDate: row[visitArrivalDate],
                    departureDate: row[visitDepartureDate],
                    order: row[visitOrder]
                )
                visits.append(visit)
            }
        } catch {
            print("Load visits error: \(error)")
        }
        return visits
    }

    @discardableResult
    func startTrip() -> Trip? {
        guard let db = db else { return nil }
        // End any currently active trip first
        if activeTrip != nil {
            _ = endTrip()
        }
        do {
            let name = "Trip \(trips.count + 1)"
            let insert = tripsTable.insert(
                tripName <- name,
                tripStartDate <- Date(),
                tripEndDate <- nil,
                tripIsActive <- true
            )
            let newId = try db.run(insert)
            let trip = Trip(id: newId, name: name, startDate: Date(), endDate: nil, isActive: true, visits: [])
            trips.insert(trip, at: 0)
            activeTrip = trip
            return trip
        } catch {
            print("Start trip error: \(error)")
            return nil
        }
    }

    @discardableResult
    func endTrip() -> Trip? {
        guard let db = db, var current = activeTrip else { return nil }
        do {
            let trip = tripsTable.filter(tripId == current.id)
            try db.run(trip.update(
                tripEndDate <- Date(),
                tripIsActive <- false
            ))
            // Update all visits' departure dates
            let visits = visitsTable.filter(visitTripId == current.id)
            try db.run(visits.update(visitDepartureDate <- Date()))

            if let idx = trips.firstIndex(where: { $0.id == current.id }) {
                trips[idx].isActive = false
                trips[idx].endDate = Date()
            }
            activeTrip = nil
            loadTrips()
            return trips.first { $0.id == current.id }
        } catch {
            print("End trip error: \(error)")
            return nil
        }
    }

    @discardableResult
    func addVisit(latitude: Double, longitude: Double, city: String?, country: String?) -> Visit? {
        guard let db = db, let current = activeTrip else { return nil }
        do {
            let maxOrder = try db.scalar(visitsTable.filter(visitTripId == current.id).select(visitOrder.max)) ?? -1
            let insert = visitsTable.insert(
                visitTripId <- current.id,
                visitCity <- city,
                visitCountry <- country,
                visitLatitude <- latitude,
                visitLongitude <- longitude,
                visitArrivalDate <- Date(),
                visitDepartureDate <- nil,
                visitOrder <- maxOrder + 1
            )
            let newId = try db.run(insert)
            let visit = Visit(
                id: newId,
                tripId: current.id,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                arrivalDate: Date(),
                departureDate: nil,
                order: maxOrder + 1
            )
            if var active = activeTrip {
                active.visits.append(visit)
                activeTrip = active
            }
            if let idx = trips.firstIndex(where: { $0.id == current.id }) {
                trips[idx].visits.append(visit)
            }
            return visit
        } catch {
            print("Add visit error: \(error)")
            return nil
        }
    }

    func deleteTrip(_ trip: Trip) {
        guard let db = db else { return }
        do {
            let visitsToDelete = visitsTable.filter(visitTripId == trip.id)
            try db.run(visitsToDelete.delete())
            let tripToDelete = tripsTable.filter(tripId == trip.id)
            try db.run(tripToDelete.delete())
            trips.removeAll { $0.id == trip.id }
            if activeTrip?.id == trip.id {
                activeTrip = nil
            }
        } catch {
            print("Delete trip error: \(error)")
        }
    }

    func travelStats(for year: Int) -> TravelStats {
        let calendar = Calendar.current
        let yearTrips = trips.filter { calendar.component(.year, from: $0.startDate) == year && !$0.isActive }

        var countries = Set<String>()
        var citySet = Set<String>()
        var totalDistance: Double = 0
        var totalCO2: Double = 0

        for trip in yearTrips {
            countries.formUnion(trip.countries)
            for city in trip.cities {
                citySet.insert(city)
            }
            totalDistance += trip.totalDistance
            totalCO2 += trip.co2Estimate
        }

        return TravelStats(
            countriesVisited: countries.count,
            citiesVisited: citySet.count,
            totalDistanceKm: totalDistance / 1000,
            totalCO2Kg: totalCO2
        )
    }
}
