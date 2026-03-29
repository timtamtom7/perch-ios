import Foundation
import CoreLocation
import CryptoKit

// MARK: - Community Models

struct CommunitySighting: Identifiable, Codable {
    let id: UUID
    let cellId: String
    let speciesIds: [String]
    let weekOfYear: Int
    let year: Int
    let totalSightings: Int
    let lastUpdated: Date

    var coordinate: CLLocationCoordinate2D? {
        // Decode cell ID back to coordinates (approximate center of cell)
        let parts = cellId.split(separator: "_")
        guard parts.count >= 2,
              let lat = Double(parts[0]),
              let lng = Double(parts[1]) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}

struct CommunityPost: Identifiable, Codable {
    let id: UUID
    let authorName: String
    let speciesId: String
    let content: String
    let timestamp: Date
    let locationName: String
    let isAnonymous: Bool
    let likes: Int

    var species: BirdSpecies? {
        SpeciesDataService.shared.species.first { $0.id == speciesId }
    }
}

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let organizer: String
    let eventType: EventType
    let startDate: Date
    let endDate: Date
    let location: Location
    let speciesHighlight: [String]
    let registrationUrl: String?
    let imageUrl: String?

    enum EventType: String, Codable, CaseIterable {
        case audubonWalk = "Audubon Walk"
        case christmasBirdCount = "Christmas Bird Count"
        case photographyTour = "Photography Tour"
        case conservationDay = "Conservation Day"
        case expertFieldTrip = "Expert Field Trip"
        case workshop = "Workshop"
        case festival = "Festival"

        var icon: String {
            switch self {
            case .audubonWalk: return "figure.walk"
            case .christmasBirdCount: return "snowflake"
            case .photographyTour: return "camera"
            case .conservationDay: return "leaf"
            case .expertFieldTrip: return "binoculars"
            case .workshop: return "person.3"
            case .festival: return "music.note"
            }
        }
    }
}

// MARK: - Expert Guide Models

struct ExpertGuide: Identifiable, Codable {
    let id: String
    let speciesId: String
    let author: String
    let authorTitle: String
    let lastUpdated: Date
    let sections: [GuideSection]
    let tips: [String]
    let similarSpecies: [String]
    let bestLocations: [BestLocation]

    var species: BirdSpecies? {
        SpeciesDataService.shared.species.first { $0.id == speciesId }
    }
}

struct GuideSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let imageAssetNames: [String]

    init(title: String, content: String, imageAssetNames: [String] = []) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.imageAssetNames = imageAssetNames
    }
}

struct BestLocation: Codable, Hashable {
    let name: String
    let state: String
    let bestSeason: String
    let coordinates: Location
}

// MARK: - Community Service

final class CommunityService: @unchecked Sendable {
    static let shared = CommunityService()

    private let lock = NSLock()
    private var cachedSightings: [CommunitySighting] = []
    private var cachedPosts: [CommunityPost] = []
    private var lastSyncDate: Date?

    private init() {
        loadCachedData()
    }

    // MARK: - Grid Cell Hashing

    /// Generate a grid cell ID from coordinates (1km x 1km cells)
    /// Cell ID format: "lat_lng" (e.g., "40.78_-73.96")
    private func generateCellId(from coordinate: CLLocationCoordinate2D) -> String {
        // Round to ~1km precision (3 decimal places)
        let latRounded = (coordinate.latitude * 1000).rounded() / 1000
        let lngRounded = (coordinate.longitude * 1000).rounded() / 1000
        return "\(latRounded)_\(lngRounded)"
    }

    /// Generate a privacy-preserving hash of the cell ID
    private func hashCellId(_ cellId: String) -> String {
        let data = Data(cellId.utf8)
        let hash = SHA256.hash(data: data)
        return hash.prefix(16).map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Post Sighting (Anonymized)

    /// Post a sighting to the community (anonymized)
    /// Only aggregate presence data is shared, never exact location or user identity
    func postSighting(_ sighting: Sighting, anonymously: Bool) {
        let cellId = generateCellId(from: sighting.location.coordinate)
        let hashedCellId = hashCellId(cellId)
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: sighting.date)
        let year = calendar.component(.year, from: sighting.date)

        let communitySighting = CommunitySighting(
            id: UUID(),
            cellId: hashedCellId,
            speciesIds: [sighting.speciesId],
            weekOfYear: weekOfYear,
            year: year,
            totalSightings: 1,
            lastUpdated: Date()
        )

        lock.lock()
        defer { lock.unlock() }

        // Merge with existing data if same cell/week
        if let existingIndex = cachedSightings.firstIndex(where: {
            $0.cellId == hashedCellId && $0.weekOfYear == weekOfYear && $0.year == year
        }) {
            var existing = cachedSightings[existingIndex]
            var combinedSpecies = Set(existing.speciesIds)
            combinedSpecies.insert(sighting.speciesId)

            cachedSightings[existingIndex] = CommunitySighting(
                id: existing.id,
                cellId: existing.cellId,
                speciesIds: Array(combinedSpecies),
                weekOfYear: existing.weekOfYear,
                year: existing.year,
                totalSightings: existing.totalSightings + 1,
                lastUpdated: Date()
            )
        } else {
            cachedSightings.append(communitySighting)
        }

        // Also create a community post if not anonymous
        if !anonymously {
            let post = CommunityPost(
                id: UUID(),
                authorName: "You",
                speciesId: sighting.speciesId,
                content: "Spotted a \(sighting.species?.commonName ?? "bird") at \(sighting.location.name)!",
                timestamp: Date(),
                locationName: sighting.location.name,
                isAnonymous: false,
                likes: 0
            )
            cachedPosts.insert(post, at: 0)
        }

        saveCachedData()
    }

    // MARK: - Get Nearby Sightings

    /// Get community sightings within a radius (in kilometers)
    /// Returns aggregated data only - no individual locations or identities
    func getNearbySightings(radius: Double) -> [CommunitySighting] {
        lock.lock()
        defer { lock.unlock() }

        // For now, return all cached sightings
        // In production, this would query a backend with radius filtering
        return cachedSightings
    }

    /// Get sightings for a specific location
    func getSightingsForLocation(_ location: Location, radius: Double = 10.0) -> [CommunitySighting] {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        return cachedSightings.filter { sighting in
            guard let coordinate = sighting.coordinate else { return false }
            let sightingLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let distanceKm = userLocation.distance(from: sightingLocation) / 1000.0
            return distanceKm <= radius
        }
    }

    // MARK: - Recent Posts

    /// Get recent community posts
    func getRecentPosts() -> [CommunityPost] {
        lock.lock()
        defer { lock.unlock() }

        return cachedPosts.sorted { $0.timestamp > $1.timestamp }
    }

    /// Get posts for a specific species
    func getPostsForSpecies(_ speciesId: String) -> [CommunityPost] {
        return cachedPosts.filter { $0.speciesId == speciesId }
    }

    // MARK: - Events

    /// Get upcoming birding events
    func getUpcomingEvents() -> [Event] {
        return Self.sampleEvents.filter { $0.startDate > Date() }
    }

    /// Get events near a location
    func getEventsNear(_ location: Location, radiusKm: Double = 50.0) -> [Event] {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        return Self.sampleEvents.filter { event in
            let eventLocation = CLLocation(
                latitude: event.location.latitude,
                longitude: event.location.longitude
            )
            let distance = userLocation.distance(from: eventLocation) / 1000.0
            return distance <= radiusKm
        }
    }

    // MARK: - Expert Guides

    /// Get expert guide for a species
    func getExpertGuide(for speciesId: String) -> ExpertGuide? {
        return Self.sampleGuides.first { $0.speciesId == speciesId }
    }

    /// Get all available expert guides
    func getAllExpertGuides() -> [ExpertGuide] {
        return Self.sampleGuides
    }

    // MARK: - Sample Data

    static let sampleEvents: [Event] = [
        Event(
            id: UUID(),
            title: "Spring Migration Bird Walk",
            description: "Join us for an early morning walk to spot migrating warblers, vireos, and thrushes. Expert guides will help identify species by sight and sound.",
            organizer: "Audubon Society",
            eventType: .audubonWalk,
            startDate: Date().addingTimeInterval(86400 * 7),
            endDate: Date().addingTimeInterval(86400 * 7 + 10800),
            location: Location(name: "Central Park, NYC", latitude: 40.7829, longitude: -73.9654),
            speciesHighlight: ["Yellow Warbler", "Red-eyed Vireo", "Wood Thrush"],
            registrationUrl: "https://audubon.org",
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Christmas Bird Count",
            description: "Annual tradition since 1900. Help count birds in your area and contribute to continental conservation data.",
            organizer: "National Audubon Society",
            eventType: .christmasBirdCount,
            startDate: Date().addingTimeInterval(86400 * 300),
            endDate: Date().addingTimeInterval(86400 * 300 + 28800),
            location: Location(name: "Various Locations", latitude: 40.7128, longitude: -74.0060),
            speciesHighlight: ["All Species"],
            registrationUrl: "https://audubon.org/christmas-bird-count",
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Raptor Photography Workshop",
            description: "Learn to photograph hawks, eagles, and owls in flight. Bring your DSLR and telephoto lens.",
            organizer: "Bird Photography Academy",
            eventType: .photographyTour,
            startDate: Date().addingTimeInterval(86400 * 14),
            endDate: Date().addingTimeInterval(86400 * 14 + 14400),
            location: Location(name: "Hawk Ridge, Minnesota", latitude: 47.6062, longitude: -122.3321),
            speciesHighlight: ["Red-tailed Hawk", "Bald Eagle", "Sharp-shinned Hawk"],
            registrationUrl: nil,
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Wetlands Restoration Day",
            description: "Help restore critical habitat for waterfowl and shorebirds. Tools and lunch provided.",
            organizer: "Nature Conservancy",
            eventType: .conservationDay,
            startDate: Date().addingTimeInterval(86400 * 21),
            endDate: Date().addingTimeInterval(86400 * 21 + 21600),
            location: Location(name: "Everglades National Park", latitude: 25.2866, longitude: -80.8987),
            speciesHighlight: ["Great Blue Heron", "White Ibis", "Roseate Spoonbill"],
            registrationUrl: "https://nature.org",
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Expert Field Trip: Birding by Ear",
            description: "Advanced workshop on identifying birds by their songs and calls. Audio equipment provided.",
            organizer: "Cornell Lab of Ornithology",
            eventType: .expertFieldTrip,
            startDate: Date().addingTimeInterval(86400 * 5),
            endDate: Date().addingTimeInterval(86400 * 5 + 18000),
            location: Location(name: "Ithaca, New York", latitude: 42.4440, longitude: -76.5019),
            speciesHighlight: ["Wood Thrush", "Ovenbird", "Scarlet Tanager"],
            registrationUrl: "https://birds.cornell.edu",
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Hummingbird Banding Workshop",
            description: "Watch experts safely capture and band hummingbirds. Learn about migration research.",
            organizer: "Hummingbird Research Institute",
            eventType: .workshop,
            startDate: Date().addingTimeInterval(86400 * 10),
            endDate: Date().addingTimeInterval(86400 * 10 + 14400),
            location: Location(name: "Patuxent Research Refuge", latitude: 39.0402, longitude: -76.8225),
            speciesHighlight: ["Ruby-throated Hummingbird", "Anna's Hummingbird"],
            registrationUrl: nil,
            imageUrl: nil
        ),
        Event(
            id: UUID(),
            title: "Texas Coastal Birding Festival",
            description: "Three days of guided tours, workshops, and presentations celebrating Gulf Coast birds.",
            organizer: "Texas Parks & Wildlife",
            eventType: .festival,
            startDate: Date().addingTimeInterval(86400 * 45),
            endDate: Date().addingTimeInterval(86400 * 47),
            location: Location(name: "Galveston, Texas", latitude: 29.3013, longitude: -94.7977),
            speciesHighlight: ["Spoonbill", "Pelican", "Whooping Crane", "Neotropic Cormorant"],
            registrationUrl: "https://tpwd.texas.gov",
            imageUrl: nil
        )
    ]

    static let sampleGuides: [ExpertGuide] = [
        ExpertGuide(
            id: "guide_amro",
            speciesId: "amro",
            author: "Dr. Sarah Mitchell",
            authorTitle: "Ornithologist, Cornell Lab of Ornithology",
            lastUpdated: Date().addingTimeInterval(-86400 * 30),
            sections: [
                GuideSection(
                    title: "Identification Tips",
                    content: """
                    The American Robin is one of North America's most familiar birds. Adults are gray-brown above with a distinctive orange-red breast.

                    Key Features:
                    • Size: 9-11 inches (larger than a house sparrow)
                    • Gray-brown upperparts
                    • Bright orange-red breast and lower belly
                    • Yellow bill with dark tip
                    • White eye crescents

                    First-year birds show a paler, more spotted breast. Males and females look similar, though females may be slightly paler.
                    """,
                    imageAssetNames: ["amro_id_1", "amro_id_2"]
                ),
                GuideSection(
                    title: "Voice & Calls",
                    content: """
                    The American Robin's song is a familiar sound of spring.

                    Song: A caroled "cheerily, cheer up, cheer up, cheerily, cheer up"

                    Calls:
                    • "Tut-tut-tut" - alarm call when disturbed
                    • "Zeet" - contact call in flight
                    • High-pitched "see" during predator alerts

                    Learn to recognize the song and you'll always know spring has arrived!
                    """,
                    imageAssetNames: ["amro_song_1"]
                ),
                GuideSection(
                    title: "Behavior Notes",
                    content: """
                    American Robins are versatile foragers with distinctive hunting behavior.

                    Feeding:
                    • Earthworms are a primary food source
                    • Also eats berries, fruits, and insects
                    • Terrestrial forager - runs and stops on lawns
                    • Tilts head to locate worms by sight, not sound

                    Nesting:
                    • Cup nest made of grass, twigs, and mud
                    • 3-5 pale blue eggs
                    • 2-3 broods per season
                    • Nests in trees, shrubs, and on buildings

                    Migration:
                    • Partial migrant - northern birds move south
                    • Often first sign of spring migration
                    • Forms large flocks outside breeding season
                    """,
                    imageAssetNames: ["amro_behavior_1"]
                )
            ],
            tips: [
                "Look for them on lawns just after rain - worms are easier to catch!",
                "Robins can eat up to 14 feet of earthworms in a single day.",
                "Their song is one of the first you'll hear at dawn in spring.",
                "A robin with a white eye ring may indicate leucism, not a different species."
            ],
            similarSpecies: ["rthr", "wood-thrush"],
            bestLocations: [
                BestLocation(
                    name: "Central Park, New York",
                    state: "NY",
                    bestSeason: "March-May",
                    coordinates: Location(name: "Central Park", latitude: 40.7829, longitude: -73.9654)
                ),
                BestLocation(
                    name: "Golden Gate Park",
                    state: "CA",
                    bestSeason: "Year-round",
                    coordinates: Location(name: "Golden Gate Park", latitude: 37.7694, longitude: -122.4862)
                )
            ]
        ),
        ExpertGuide(
            id: "guide_carw",
            speciesId: "carw",
            author: "Dr. James Chen",
            authorTitle: "Senior Naturalist, National Audubon Society",
            lastUpdated: Date().addingTimeInterval(-86400 * 60),
            sections: [
                GuideSection(
                    title: "Identification Tips",
                    content: """
                    The Carolina Wren is a small, energetic bird with distinctive markings.

                    Key Features:
                    • Warm brown upperparts
                    • Bold white eyebrow stripe
                    • Buff-orange underparts
                    • Long, curved bill
                    • Fan-shaped tail often cocked upward

                    Males and females look identical. The rich, warm colors distinguish it from the similar House Wren.
                    """,
                    imageAssetNames: ["carw_id_1"]
                ),
                GuideSection(
                    title: "Voice & Calls",
                    content: """
                    Carolina Wrens are vocal birds with a surprisingly loud song.

                    Song: Loud, melodious "tea-kettle tea-kettle tea-kettle"

                    Calls:
                    • Sharp "chick" or "check" sounds
                    • Bubbling trill when agitated
                    • Duet singing between mated pairs

                    These birds sing year-round, even in winter!
                    """,
                    imageAssetNames: ["carw_song_1"]
                ),
                GuideSection(
                    title: "Best Viewing Locations",
                    content: """
                    Carolina Wrens prefer shrubby habitats and edge areas.

                    Habitat:
                    • Dense shrubs and tangles
                    • Woodland edges
                    • suburban gardens
                    • Old fields with scattered trees

                    They often forage low in vegetation, occasionally visiting suet feeders in winter.
                    """,
                    imageAssetNames: ["carw_habitat_1"]
                )
            ],
            tips: [
                "Listen for the loud song - it's often the first sign of a Carolina Wren nearby.",
                "They love brush piles! Leave some brush in your yard for nesting habitat.",
                "Carolina Wrens don't migrate - you can find them year-round in the same areas."
            ],
            similarSpecies: ["houwr", "bewwr"],
            bestLocations: [
                BestLocation(
                    name: "Great Smoky Mountains NP",
                    state: "TN/NC",
                    bestSeason: "Year-round",
                    coordinates: Location(name: "Great Smoky Mountains", latitude: 35.6532, longitude: -83.5070)
                )
            ]
        )
    ]

    // MARK: - Persistence

    private func loadCachedData() {
        lock.lock()
        defer { lock.unlock() }

        if let sightingsData = UserDefaults.standard.data(forKey: "communitySightings"),
           let sightings = try? JSONDecoder().decode([CommunitySighting].self, from: sightingsData) {
            cachedSightings = sightings
        }

        if let postsData = UserDefaults.standard.data(forKey: "communityPosts"),
           let posts = try? JSONDecoder().decode([CommunityPost].self, from: postsData) {
            cachedPosts = posts
        }
    }

    private func saveCachedData() {
        lock.lock()
        defer { lock.unlock() }

        if let sightingsData = try? JSONEncoder().encode(cachedSightings) {
            UserDefaults.standard.set(sightingsData, forKey: "communitySightings")
        }

        if let postsData = try? JSONEncoder().encode(cachedPosts) {
            UserDefaults.standard.set(postsData, forKey: "communityPosts")
        }
    }
}
