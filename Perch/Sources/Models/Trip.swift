import Foundation
import CoreLocation

struct Trip: Identifiable, Equatable {
    let id: Int64
    var name: String
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var visits: [Visit]

    var duration: TimeInterval {
        let end = endDate ?? Date()
        return end.timeIntervalSince(startDate)
    }

    var formattedDuration: String {
        let days = Int(duration / 86400)
        if days == 0 {
            let hours = Int(duration / 3600)
            return hours == 1 ? "1 hour" : "\(hours) hours"
        }
        return days == 1 ? "1 day" : "\(days) days"
    }

    var totalDistance: Double {
        guard visits.count > 1 else { return 0 }
        var total: Double = 0
        for i in 1..<visits.count {
            let from = CLLocation(latitude: visits[i-1].latitude, longitude: visits[i-1].longitude)
            let to = CLLocation(latitude: visits[i].latitude, longitude: visits[i].longitude)
            total += from.distance(from: to)
        }
        return total
    }

    var co2Estimate: Double {
        // Average CO₂ per km for air travel ≈ 0.255 kg/km
        let km = totalDistance / 1000
        return km * 0.255
    }

    var countries: Set<String> {
        Set(visits.compactMap { $0.country })
    }

    var cities: [String] {
        visits.map { $0.city }.compactMap { $0 }
    }

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
}

struct Visit: Identifiable, Equatable {
    let id: Int64
    let tripId: Int64
    var city: String?
    var country: String?
    var latitude: Double
    var longitude: Double
    var arrivalDate: Date
    var departureDate: Date?
    var order: Int

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var displayName: String {
        if let city = city, let country = country {
            return "\(city), \(country)"
        } else if let city = city {
            return city
        } else if let country = country {
            return country
        }
        return "Unknown"
    }

    var duration: TimeInterval? {
        guard let departure = departureDate else { return nil }
        return departure.timeIntervalSince(arrivalDate)
    }

    static func == (lhs: Visit, rhs: Visit) -> Bool {
        lhs.id == rhs.id
    }
}

struct TravelStats {
    var countriesVisited: Int
    var citiesVisited: Int
    var totalDistanceKm: Double
    var totalCO2Kg: Double

    var formattedDistance: String {
        if totalDistanceKm >= 1000 {
            return String(format: "%.0f,%.0f km", floor(totalDistanceKm / 1000), totalDistanceKm.truncatingRemainder(dividingBy: 1000))
        }
        return String(format: "%.0f km", totalDistanceKm)
    }

    var formattedCO2: String {
        if totalCO2Kg >= 1000 {
            return String(format: "%.1ft", totalCO2Kg / 1000)
        }
        return String(format: "%.0f kg", totalCO2Kg)
    }
}
