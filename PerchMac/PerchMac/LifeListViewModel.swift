import Foundation
import Combine

class LifeListViewModel: ObservableObject {
    @Published var spottedSpecies: Set<String> = []
    @Published var selectedRegion: Region = .northAmerica
    @Published var searchText: String = ""

    var availableRegions: [Region] = [.northAmerica, .europe, .world]

    var allSpecies: [BirdSpecies] {
        SpeciesDataService.shared.species
    }

    var filteredSpecies: [BirdSpecies] {
        let species = allSpecies.filter { $0.region == selectedRegion.name || selectedRegion == .world }

        if searchText.isEmpty {
            return species
        }

        return species.filter {
            $0.commonName.localizedCaseInsensitiveContains(searchText) ||
            $0.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var spottedCount: Int {
        spottedSpecies.count
    }

    var totalInRegion: Int {
        allSpecies.filter { $0.region == selectedRegion.name || selectedRegion == .world }.count
    }

    var progressPercentage: Double {
        guard totalInRegion > 0 else { return 0 }
        return Double(spottedCount) / Double(totalInRegion)
    }

    var groupedByFamily: [String: [BirdSpecies]] {
        Dictionary(grouping: filteredSpecies) { $0.family }
    }

    init() {
        // Load some sample spotted species
        spottedSpecies = ["mallard", "american-robin", "red-tailed-hawk", "bald-eagle", "northern-cardinal"]
    }

    func toggleSpotted(_ species: BirdSpecies) {
        if spottedSpecies.contains(species.id) {
            spottedSpecies.remove(species.id)
        } else {
            spottedSpecies.insert(species.id)
        }
    }

    func isSpotted(_ species: BirdSpecies) -> Bool {
        spottedSpecies.contains(species.id)
    }

    func firstSpottedDate(for species: BirdSpecies) -> Date? {
        // In a real app, this would come from sightings data
        return nil
    }

    func timesSpotted(for species: BirdSpecies) -> Int {
        // In a real app, this would count actual sightings
        return isSpotted(species) ? Int.random(in: 1...50) : 0
    }
}
