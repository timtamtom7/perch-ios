import Foundation
import CoreLocation
import UserNotifications

final class RareBirdAlertService: @unchecked Sendable {
    static let shared = RareBirdAlertService()

    private let locationManager = CLLocationManager()
    private let lock = NSLock()

    private init() {}

    struct RareBirdAlert: Identifiable, Sendable {
        let id: UUID
        let species: String
        let location: String
        let distance: Double
        let rarityScore: Int
        let timestamp: Date
        let message: String
    }

    struct AlertConfiguration: Sendable {
        var isEnabled: Bool
        var minimumRarityScore: Int
        var alertRadiusKm: Double
        var regionFilter: String?

        static let `default` = AlertConfiguration(
            isEnabled: true,
            minimumRarityScore: 7,
            alertRadiusKm: 50.0,
            regionFilter: nil
        )
    }

    private var configuration: AlertConfiguration = .default

    // MARK: - Rarity Scoring

    /// Calculate rarity score based on sighting frequency
    /// Rarity Score = 10 - log10(totalSightingsInRegion)
    /// Cap at 10, floor at 1
    func calculateRarityScore(for speciesId: String, in region: String, sightingCount: Int) -> Int {
        guard sightingCount > 0 else { return 10 } // Never seen = very rare

        let logSightings = log10(Double(sightingCount))
        let score = 10.0 - logSightings

        return max(1, min(10, Int(score.rounded())))
    }

    func getRarityDescription(for score: Int) -> String {
        switch score {
        case 10: return "Extremely Rare"
        case 8...9: return "Very Rare"
        case 6...7: return "Rare"
        case 4...5: return "Uncommon"
        case 2...3: return "Common"
        default: return "Very Common"
        }
    }

    func getRarityColor(for score: Int) -> String {
        switch score {
        case 10: return "red"
        case 8...9: return "orange"
        case 6...7: return "yellow"
        case 4...5: return "green"
        default: return "blue"
        }
    }

    // MARK: - Alert Generation

    func generateAlert(
        for speciesId: String,
        at location: Location,
        from userLocation: CLLocation,
        sightingCount: Int = 0
    ) -> RareBirdAlert? {
        let rarityScore = calculateRarityScore(
            for: speciesId,
            in: location.name,
            sightingCount: sightingCount
        )

        guard rarityScore >= configuration.minimumRarityScore else {
            return nil
        }

        let distance = calculateDistance(
            from: userLocation,
            to: CLLocation(latitude: location.latitude, longitude: location.longitude)
        )

        // Filter by radius
        guard distance <= configuration.alertRadiusKm else {
            return nil
        }

        let species = SpeciesDataService.shared.species.first { $0.id == speciesId }
        let speciesName = species?.commonName ?? speciesId

        return RareBirdAlert(
            id: UUID(),
            species: speciesName,
            location: location.name,
            distance: distance,
            rarityScore: rarityScore,
            timestamp: Date(),
            message: "A rare \(speciesName) was spotted \(Int(distance)) km from you!"
        )
    }

    // MARK: - Location Helpers

    private func calculateDistance(from: CLLocation, to: CLLocation) -> Double {
        let distanceMeters = from.distance(from: to)
        return distanceMeters / 1000.0 // Convert to km
    }

    func getCurrentLocation() async -> CLLocation? {
        return await withCheckedContinuation { continuation in
            locationManager.requestWhenInUseAuthorization()

            if let location = locationManager.location {
                continuation.resume(returning: location)
            } else {
                // Default to a central US location if no location available
                continuation.resume(returning: CLLocation(latitude: 39.8283, longitude: -98.5795))
            }
        }
    }

    // MARK: - Configuration

    func updateConfiguration(_ config: AlertConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        self.configuration = config
    }

    func getConfiguration() -> AlertConfiguration {
        lock.lock()
        defer { lock.unlock() }
        return configuration
    }

    // MARK: - Predefined Rare Birds Database

    /// Database of rare bird sightings with their typical rarity scores
    static let rareBirdsDatabase: [String: Int] = [
        "snowy-owl": 9,
        "ivory-billed-woodpecker": 10,
        "kirtlands-warbler": 9,
        "california-condor": 10,
        "whooping-crane": 10,
        "attwater's-prairie-chicken": 10,
        "greater-roadrunner": 6,
        "varied-thrush": 5,
        "northern-gannet": 6,
        "frigatebird": 7,
        "albatross": 8,
        "swallow-tailed-kite": 7,
        "white-tailed-kite": 6,
        "ferruginous-hawk": 7,
        "gyrfalcon": 9,
        "peregrine-falcon": 6,
        "Sprague's-pipit": 8,
        "bay-breasted-warbler": 5,
        "blackburnian-warbler": 5,
        "kentucky-warbler": 6,
        " Connecticut-warbler": 7,
        "mourning-warbler": 5,
        "hooded-warbler": 5,
        "golden-winged-warbler": 7,
        "prothonotary-warbler": 6,
        "yellow-nosed-albatross": 10,
        "trumpeter-swan": 7,
        "white-faced-ibis": 6,
        "roseate-spoonbill": 7,
        "wood-stork": 7
    ]

    func getRarityScoreForSpecies(_ speciesId: String) -> Int {
        return Self.rareBirdsDatabase[speciesId] ?? calculateDefaultRarity()
    }

    private func calculateDefaultRarity() -> Int {
        // Use a default curve based on total species count
        let totalSpecies = SpeciesDataService.shared.species.count
        return max(1, min(5, Int(log10(Double(totalSpecies)))))
    }

    // MARK: - Notifications

    func requestNotificationPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func scheduleAlert(_ alert: RareBirdAlert) async {
        let permissionGranted = await requestNotificationPermission()
        guard permissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = "🚨 Rare Bird Alert!"
        content.body = alert.message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}
