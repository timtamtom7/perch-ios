import Foundation

struct TripTemplate: Identifiable, Equatable, Codable {
    let id: Int64
    var name: String
    var destinations: [TemplateDestination]
    var expectedDurationDays: Int
    var transportMode: String
    var tripType: TripType
    var notes: String
    var createdAt: Date

    var destinationsSummary: String {
        if destinations.isEmpty {
            return "No destinations set"
        }
        let names = destinations.map { $0.city }.prefix(3)
        let suffix = destinations.count > 3 ? " +\(destinations.count - 3) more" : ""
        return names.joined(separator: " → ") + suffix
    }

    static func == (lhs: TripTemplate, rhs: TripTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

struct TemplateDestination: Identifiable, Equatable, Codable {
    var id: Int64 { Int64(city.hashValue) }
    let city: String
    let country: String?
    let latitude: Double?
    let longitude: Double?
    let order: Int
}

enum TripType: String, Codable, CaseIterable {
    case weekend = "weekend"
    case short = "short"       // 1-3 days
    case week = "week"         // 4-7 days
    case extended = "extended" // 8-14 days
    case long = "long"         // 15+ days

    var displayName: String {
        switch self {
        case .weekend: return "Weekend"
        case .short: return "Short Trip"
        case .week: return "One Week"
        case .extended: return "Extended"
        case .long: return "Long Stay"
        }
    }

    var icon: String {
        switch self {
        case .weekend: return "calendar.badge.clock"
        case .short: return "sun.max"
        case .week: return "airplane"
        case .extended: return "mappin.and.ellipse"
        case .long: return "globe"
        }
    }
}

extension TripTemplate {
    static let preBuilt: [TripTemplate] = [
        TripTemplate(
            id: -1,
            name: "Weekend City Break",
            destinations: [
                TemplateDestination(city: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, order: 0)
            ],
            expectedDurationDays: 3,
            transportMode: "flight",
            tripType: .weekend,
            notes: "A quick escape to a major European city. Perfect for long weekends.",
            createdAt: Date()
        ),
        TripTemplate(
            id: -2,
            name: "European Capital Tour",
            destinations: [
                TemplateDestination(city: "London", country: "United Kingdom", latitude: 51.5074, longitude: -0.1278, order: 0),
                TemplateDestination(city: "Paris", country: "France", latitude: 48.8566, longitude: 2.3522, order: 1)
            ],
            expectedDurationDays: 7,
            transportMode: "train",
            tripType: .week,
            notes: "Two iconic capitals connected by the Eurostar. Classic and efficient.",
            createdAt: Date()
        ),
        TripTemplate(
            id: -3,
            name: "Japan Discovery",
            destinations: [
                TemplateDestination(city: "Tokyo", country: "Japan", latitude: 35.6762, longitude: 139.6503, order: 0),
                TemplateDestination(city: "Kyoto", country: "Japan", latitude: 35.0116, longitude: 135.7681, order: 1)
            ],
            expectedDurationDays: 10,
            transportMode: "flight",
            tripType: .extended,
            notes: "The classic Japan route — modern Tokyo, then traditional Kyoto.",
            createdAt: Date()
        ),
        TripTemplate(
            id: -4,
            name: "Portugal Road Trip",
            destinations: [
                TemplateDestination(city: "Lisbon", country: "Portugal", latitude: 38.7223, longitude: -9.1393, order: 0),
                TemplateDestination(city: "Porto", country: "Portugal", latitude: 41.1579, longitude: -8.6291, order: 1)
            ],
            expectedDurationDays: 7,
            transportMode: "car",
            tripType: .week,
            notes: "Coastal Portugal — from Lisbon to Porto, with the Atlantic as your companion.",
            createdAt: Date()
        ),
        TripTemplate(
            id: -5,
            name: "New York City",
            destinations: [
                TemplateDestination(city: "New York", country: "United States", latitude: 40.7128, longitude: -74.0060, order: 0)
            ],
            expectedDurationDays: 5,
            transportMode: "flight",
            tripType: .week,
            notes: "The city that never sleeps. Give yourself at least 4-5 days.",
            createdAt: Date()
        ),
        TripTemplate(
            id: -6,
            name: "Southeast Asia Loop",
            destinations: [
                TemplateDestination(city: "Bangkok", country: "Thailand", latitude: 13.7563, longitude: 100.5018, order: 0),
                TemplateDestination(city: "Ho Chi Minh City", country: "Vietnam", latitude: 10.8231, longitude: 106.6297, order: 1)
            ],
            expectedDurationDays: 14,
            transportMode: "flight",
            tripType: .extended,
            notes: "Two cities, two countries, one unforgettable region.",
            createdAt: Date()
        )
    ]
}
