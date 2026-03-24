import Foundation

struct CO2Estimator {
    // CO₂ per km for different transport modes (kg CO₂/km)
    static let airTravelPerKm: Double = 0.255
    static let carTravelPerKm: Double = 0.192
    static let trainTravelPerKm: Double = 0.041
    static let busTravelPerKm: Double = 0.089

    /// Estimate CO₂ for a given distance in kilometers
    static func estimate(distanceKm: Double, mode: TransportMode = .flight) -> Double {
        return distanceKm * mode.emissionFactor
    }

    /// Format CO₂ for display
    static func format(_ kg: Double) -> String {
        if kg >= 1000 {
            return String(format: "~%.1ft CO₂", kg / 1000)
        } else if kg >= 1 {
            return String(format: "~%.1fkg CO₂", kg)
        } else {
            return String(format: "~%.0fg CO₂", kg * 1000)
        }
    }

    enum TransportMode {
        case flight
        case car
        case train
        case bus

        var emissionFactor: Double {
            switch self {
            case .flight: return airTravelPerKm
            case .car: return carTravelPerKm
            case .train: return trainTravelPerKm
            case .bus: return busTravelPerKm
            }
        }

        var name: String {
            switch self {
            case .flight: return "Flight"
            case .car: return "Car"
            case .train: return "Train"
            case .bus: return "Bus"
            }
        }
    }
}
