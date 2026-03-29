import Foundation

@MainActor
class SpeciesViewModel: ObservableObject {
    @Published var species: [BirdSpecies] = []
    @Published var searchText: String = ""
    @Published var selectedFamily: String?
    @Published var isLoading: Bool = false

    var allFamilies: [String] {
        Array(Set(species.map { $0.family })).sorted()
    }

    var filteredSpecies: [BirdSpecies] {
        var result = species

        if !searchText.isEmpty {
            result = result.filter {
                $0.commonName.localizedCaseInsensitiveContains(searchText) ||
                $0.scientificName.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let family = selectedFamily {
            result = result.filter { $0.family == family }
        }

        return result.sorted { $0.commonName < $1.commonName }
    }

    init() {
        loadSpecies()
    }

    func loadSpecies() {
        isLoading = true
        species = SpeciesDataService.shared.species
        isLoading = false
    }

    func species(for id: String) -> BirdSpecies? {
        species.first { $0.id == id }
    }
}
