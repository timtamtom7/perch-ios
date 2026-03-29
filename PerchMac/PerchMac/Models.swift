import Foundation
import CoreLocation

struct BirdSpecies: Identifiable, Codable, Hashable {
    let id: String
    let commonName: String
    let scientificName: String
    let family: String
    let description: String
    let habitat: String
    let migrationPattern: String
    let region: String
    let imageName: String

    static let sample = BirdSpecies(
        id: "amro",
        commonName: "American Robin",
        scientificName: "Turdus migratorius",
        family: "Thrushes",
        description: "A familiar sight on lawns across North America, the American Robin is one of the most abundant birds on the continent.",
        habitat: "Lawns, parks, forests, urban areas",
        migrationPattern: "Partial migrant; northern populations move south",
        region: "North America",
        imageName: "bird_placeholder"
    )
}

struct Sighting: Identifiable, Codable {
    let id: UUID
    let speciesId: String
    let date: Date
    let location: Location
    let notes: String
    let photoData: Data?

    var species: BirdSpecies? {
        SpeciesDataService.shared.species.first { $0.id == speciesId }
    }
}

struct Location: Codable, Hashable {
    let name: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let sample = Location(
        name: "Central Park, New York",
        latitude: 40.7829,
        longitude: -73.9654
    )
}

struct Region: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let totalSpecies: Int

    static let northAmerica = Region(id: "na", name: "North America", totalSpecies: 914)
    static let europe = Region(id: "eu", name: "Europe", totalSpecies: 650)
    static let world = Region(id: "world", name: "World", totalSpecies: 10000)
}

enum BirdFamily: String, CaseIterable, Codable {
    case waterfowl = "Waterfowl"
    case hawks = "Hawks & Eagles"
    case herons = "Herons & Bitterns"
    case shorebirds = "Shorebirds"
    case gulls = "Gulls & Terns"
    case doves = "Doves & Pigeons"
    case owls = "Owls"
    case hummingbirds = "Hummingbirds"
    case woodpeckers = "Woodpeckers"
    case thrushes = "Thrushes"
    case sparrows = "Sparrows & Finches"
    case blackbirds = "Blackbirds & Orioles"
}
