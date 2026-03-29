import SwiftUI
import Combine

class MenuBarViewModel: ObservableObject {
    @Published var recentSighting: Sighting?
    @Published var lifeListCount: Int = 0
    @Published var lifeListTotal: Int = 0

    private var cancellables = Set<AnyCancellable>()
    private let sightingsVM = SightingsViewModel()
    private let lifeListVM = LifeListViewModel()

    init() {
        setupBindings()
    }

    private func setupBindings() {
        // Get most recent sighting
        if let first = sightingsVM.sightings.first {
            recentSighting = first
        }

        lifeListCount = lifeListVM.spottedCount
        lifeListTotal = lifeListVM.totalInRegion
    }

    var menuBarTitle: String {
        if lifeListCount > 0 {
            return "\(lifeListCount)"
        }
        return ""
    }

    var recentSightingText: String {
        guard let sighting = recentSighting else {
            return "No sightings yet"
        }
        return sighting.species?.commonName ?? "Unknown"
    }

    var todayHighlight: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "🐦 Morning bird walks are best!"
        } else if hour < 17 {
            return "🌅 Perfect time for bird watching"
        } else {
            return "🦉 Listen for evening songbirds"
        }
    }
}
