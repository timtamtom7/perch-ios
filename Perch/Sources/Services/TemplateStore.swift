import Foundation
import SQLite

final class TemplateStore: ObservableObject {
    private var db: Connection?
    private let templatesTable = Table("templates")
    private let destinationsTable = Table("template_destinations")

    // Template columns
    private let templateId = Expression<Int64>("id")
    private let templateName = Expression<String>("name")
    private let templateExpectedDays = Expression<Int>("expected_days")
    private let templateTransportMode = Expression<String>("transport_mode")
    private let templateTripType = Expression<String>("trip_type")
    private let templateNotes = Expression<String>("notes")
    private let templateCreatedAt = Expression<Date>("created_at")

    // Destination columns
    private let destId = Expression<Int64>("id")
    private let destTemplateId = Expression<Int64>("template_id")
    private let destCity = Expression<String>("city")
    private let destCountry = Expression<String?>("country")
    private let destLatitude = Expression<Double?>("latitude")
    private let destLongitude = Expression<Double?>("longitude")
    private let destOrder = Expression<Int>("order")

    @Published var templates: [TripTemplate] = []

    init() {
        setupDatabase()
        loadTemplates()
    }

    private func setupDatabase() {
        do {
            guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
                print("TemplateStore setup error: Could not find documents directory")
                return
            }
            db = try Connection("\(path)/perch.sqlite3")
            try createTables()
        } catch {
            print("TemplateStore setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(templatesTable.create(ifNotExists: true) { t in
            t.column(templateId, primaryKey: .autoincrement)
            t.column(templateName)
            t.column(templateExpectedDays)
            t.column(templateTransportMode)
            t.column(templateTripType)
            t.column(templateNotes)
            t.column(templateCreatedAt)
        })

        try db?.run(destinationsTable.create(ifNotExists: true) { t in
            t.column(destId, primaryKey: .autoincrement)
            t.column(destTemplateId)
            t.column(destCity)
            t.column(destCountry)
            t.column(destLatitude)
            t.column(destLongitude)
            t.column(destOrder)
        })
    }

    private func loadTemplates() {
        templates = TripTemplate.preBuilt
        loadUserTemplates()
    }

    private func loadUserTemplates() {
        guard let db = db else { return }
        do {
            for row in try db.prepare(templatesTable.order(templateCreatedAt.desc)) {
                let id = row[templateId]
                let destinations = loadDestinations(forTemplateId: id)
                let tripType = TripType(rawValue: row[templateTripType]) ?? .week
                let template = TripTemplate(
                    id: id,
                    name: row[templateName],
                    destinations: destinations,
                    expectedDurationDays: row[templateExpectedDays],
                    transportMode: row[templateTransportMode],
                    tripType: tripType,
                    notes: row[templateNotes],
                    createdAt: row[templateCreatedAt]
                )
                templates.append(template)
            }
        } catch {
            print("Load templates error: \(error)")
        }
    }

    private func loadDestinations(forTemplateId id: Int64) -> [TemplateDestination] {
        guard let db = db else { return [] }
        var destinations: [TemplateDestination] = []
        do {
            let query = destinationsTable.filter(destTemplateId == id).order(destOrder.asc)
            for row in try db.prepare(query) {
                let dest = TemplateDestination(
                    city: row[destCity],
                    country: row[destCountry],
                    latitude: row[destLatitude],
                    longitude: row[destLongitude],
                    order: row[destOrder]
                )
                destinations.append(dest)
            }
        } catch {
            print("Load destinations error: \(error)")
        }
        return destinations
    }

    @discardableResult
    func saveTemplate(_ template: TripTemplate) -> Bool {
        guard let db = db else { return false }
        do {
            let insert = templatesTable.insert(
                templateName <- template.name,
                templateExpectedDays <- template.expectedDurationDays,
                templateTransportMode <- template.transportMode,
                templateTripType <- template.tripType.rawValue,
                templateNotes <- template.notes,
                templateCreatedAt <- template.createdAt
            )
            let newId = try db.run(insert)

            // Save destinations
            for dest in template.destinations {
                try db.run(destinationsTable.insert(
                    destTemplateId <- newId,
                    destCity <- dest.city,
                    destCountry <- dest.country,
                    destLatitude <- dest.latitude,
                    destLongitude <- dest.longitude,
                    destOrder <- dest.order
                ))
            }

            let savedTemplate = TripTemplate(
                id: newId,
                name: template.name,
                destinations: template.destinations,
                expectedDurationDays: template.expectedDurationDays,
                transportMode: template.transportMode,
                tripType: template.tripType,
                notes: template.notes,
                createdAt: template.createdAt
            )
            templates.append(savedTemplate)
            return true
        } catch {
            print("Save template error: \(error)")
            return false
        }
    }

    func deleteTemplate(_ template: TripTemplate) {
        guard let db = db, template.id > 0 else { return }
        do {
            let destinations = destinationsTable.filter(destTemplateId == template.id)
            try db.run(destinations.delete())
            let toDelete = templatesTable.filter(templateId == template.id)
            try db.run(toDelete.delete())
            templates.removeAll { $0.id == template.id }
        } catch {
            print("Delete template error: \(error)")
        }
    }
}
