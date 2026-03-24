import SwiftUI

@main
struct PerchApp: App {
    @StateObject private var tripStore = TripStore()
    @StateObject private var locationService = LocationService()
    @StateObject private var templateStore = TemplateStore()
    @StateObject private var detectionManager = TravelDetectionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tripStore)
                .environmentObject(locationService)
                .environmentObject(templateStore)
                .environmentObject(detectionManager)
                .preferredColorScheme(.dark)
        }
    }
}
