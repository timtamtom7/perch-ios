import Foundation
import Combine

@MainActor
class LifeListViewModel: ObservableObject {
    @Published var spottedSpecies: Set<String> = []
    @Published var selectedRegion: Region = .northAmerica
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    var availableRegions: [Region] = [.northAmerica, .europe, .world]

    var allSpecies: [BirdSpecies] {
        SpeciesDataService.shared.species
    }

    var filteredSpecies: [BirdSpecies] {
        var species = allSpecies.filter { $0.region == selectedRegion.name || selectedRegion == .world }

        if !searchText.isEmpty {
            species = species.filter {
                $0.commonName.localizedCaseInsensitiveContains(searchText) ||
                $0.scientificName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return species
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

    var sortedFamilies: [String] {
        groupedByFamily.keys.sorted()
    }

    init() {
        loadSpottedSpecies()
    }

    func loadSpottedSpecies() {
        if let saved = UserDefaults.standard.array(forKey: "perchSpottedSpecies") as? [String] {
            spottedSpecies = Set(saved)
        } else {
            // Sample spotted species
            spottedSpecies = ["mallard", "american-robin", "red-tailed-hawk", "bald-eagle", "northern-cardinal"]
            saveSpottedSpecies()
        }
    }

    func saveSpottedSpecies() {
        UserDefaults.standard.set(Array(spottedSpecies), forKey: "perchSpottedSpecies")
    }

    func toggleSpotted(_ species: BirdSpecies) {
        if spottedSpecies.contains(species.id) {
            spottedSpecies.remove(species.id)
        } else {
            spottedSpecies.insert(species.id)
        }
        saveSpottedSpecies()
    }

    func isSpotted(_ species: BirdSpecies) -> Bool {
        spottedSpecies.contains(species.id)
    }

    func timesSpotted(for species: BirdSpecies) -> Int {
        guard isSpotted(species) else { return 0 }
        return Int.random(in: 1...50)
    }
}
