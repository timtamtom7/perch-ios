import SwiftUI

@main
struct PerchApp: App {
    @StateObject private var sightingsViewModel = SightingsViewModel()
    @StateObject private var lifeListViewModel = LifeListViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sightingsViewModel)
                .environmentObject(lifeListViewModel)
                .preferredColorScheme(nil)
        }
    }
}
