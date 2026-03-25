import Foundation

/// R9: Community and social features service
@MainActor
final class PerchCommunityService: ObservableObject {
    static let shared = PerchCommunityService()

    @Published private(set) var publicTrips: [PublicTrip] = []
    @Published private(set) var isLoading = false

    struct PublicTrip: Identifiable, Codable {
        let id: UUID
        let anonymousId: String
        let destination: String
        let country: String
        let transportMode: String
        let co2: Double
        let distance: Double
        let createdAt: Date
        let likes: Int
    }

    private init() {}

    @MainActor
    func loadPublicFeed() async {
        isLoading = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        publicTrips = [
            PublicTrip(id: UUID(), anonymousId: "traveler_x7k2", destination: "Barcelona", country: "Spain", transportMode: "train", co2: 12.5, distance: 1050, createdAt: Date().addingTimeInterval(-3600), likes: 24),
            PublicTrip(id: UUID(), anonymousId: "eco_adventurer_m3p9", destination: "Amsterdam", country: "Netherlands", transportMode: "train", co2: 8.2, distance: 450, createdAt: Date().addingTimeInterval(-7200), likes: 42),
            PublicTrip(id: UUID(), anonymousId: "wanderer_b5n1", destination: "Munich", country: "Germany", transportMode: "train", co2: 18.7, distance: 780, createdAt: Date().addingTimeInterval(-10800), likes: 18),
            PublicTrip(id: UUID(), anonymousId: "green_traveler_k8r4", destination: "Zurich", country: "Switzerland", transportMode: "train", co2: 5.4, distance: 320, createdAt: Date().addingTimeInterval(-14400), likes: 31),
            PublicTrip(id: UUID(), anonymousId: "nomad_c2t7", destination: "Paris", country: "France", transportMode: "train", co2: 22.1, distance: 950, createdAt: Date().addingTimeInterval(-18000), likes: 56)
        ]

        isLoading = false
    }
}
