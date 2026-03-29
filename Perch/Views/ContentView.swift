import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @EnvironmentObject var lifeListViewModel: LifeListViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            BirdSightingsView()
                .tabItem {
                    Label("Sightings", systemImage: "binoculars.fill")
                }

            LifeListView()
                .tabItem {
                    Label("Life List", systemImage: "list.bullet")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
        }
        .tint(Theme.forestGreen)
    }
}

#Preview {
    ContentView()
        .environmentObject(SightingsViewModel())
        .environmentObject(LifeListViewModel())
}
