import Foundation
import Combine

class SightingsViewModel: ObservableObject {
    @Published var sightings: [Sighting] = []
    @Published var searchText: String = ""
    @Published var selectedSpecies: String?
    @Published var dateRange: ClosedRange<Date>?

    private var cancellables = Set<AnyCancellable>()

    var filteredSightings: [Sighting] {
        var result = sightings

        if !searchText.isEmpty {
            result = result.filter { sighting in
                sighting.species?.commonName.localizedCaseInsensitiveContains(searchText) == true ||
                sighting.species?.scientificName.localizedCaseInsensitiveContains(searchText) == true ||
                sighting.location.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        if let speciesId = selectedSpecies {
            result = result.filter { $0.speciesId == speciesId }
        }

        if let range = dateRange {
            result = result.filter { range.contains($0.date) }
        }

        return result.sorted { $0.date > $1.date }
    }

    init() {
        // Load sample data
        loadSampleSightings()
    }

    private func loadSampleSightings() {
        let species = SpeciesDataService.shared.species
        guard !species.isEmpty else { return }

        sightings = [
            Sighting(
                id: UUID(),
                speciesId: species[0].id,
                date: Date().addingTimeInterval(-3600 * 24 * 2),
                location: Location(name: "Central Park, New York", latitude: 40.7829, longitude: -73.9654),
                notes: "Spotted near the reservoir",
                photoData: nil
            ),
            Sighting(
                id: UUID(),
                speciesId: species[10].id,
                date: Date().addingTimeInterval(-3600 * 24 * 5),
                location: Location(name: "Bryant Park, New York", latitude: 40.7536, longitude: -73.9832),
                notes: "Hunting in the open lawn",
                photoData: nil
            ),
            Sighting(
                id: UUID(),
                speciesId: species[25].id,
                date: Date().addingTimeInterval(-3600 * 24 * 10),
                location: Location(name: "Prospect Park, Brooklyn", latitude: 40.6602, longitude: -73.9690),
                notes: "Multiple individuals",
                photoData: nil
            ),
            Sighting(
                id: UUID(),
                speciesId: species[35].id,
                date: Date().addingTimeInterval(-3600 * 48),
                location: Location(name: "Hudson River Greenway", latitude: 40.7282, longitude: -74.0116),
                notes: "Group of 5",
                photoData: nil
            ),
        ]
    }

    func addSighting(_ sighting: Sighting) {
        sightings.insert(sighting, at: 0)
    }

    func deleteSighting(_ sighting: Sighting) {
        sightings.removeAll { $0.id == sighting.id }
    }
}
