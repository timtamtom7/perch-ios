import SwiftUI

@main
struct PerchApp: App {
    @StateObject private var tripStore = TripStore()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tripStore)
                .environmentObject(locationService)
                .preferredColorScheme(.dark)
        }
    }
}
