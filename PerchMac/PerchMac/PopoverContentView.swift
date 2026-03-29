import SwiftUI

struct PopoverContentView: View {
    @State private var selectedTab: Tab = .recent

    enum Tab: String, CaseIterable {
        case recent = "Recent"
        case lifeList = "Life List"
        case map = "Map"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Tab selector
            tabSelector

            // Content
            TabView(selection: $selectedTab) {
                RecentSightingsView()
                    .tag(Tab.recent)

                LifeListView()
                    .tag(Tab.lifeList)

                MapView()
                    .tag(Tab.map)
            }
            .tabViewStyle(.automatic)
        }
        .frame(width: 380, height: 500)
        .background(Theme.cream)
    }

    private var header: some View {
        HStack {
            Image(systemName: "bird.fill")
                .font(.title2)
                .foregroundStyle(Theme.forestGreen)

            VStack(alignment: .leading, spacing: 2) {
                Text("Perch")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)

                Text("Bird Watching Companion")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Theme.surface)
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: iconFor(tab))
                            .font(.system(size: 14))

                        Text(tab.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(selectedTab == tab ? Theme.forestGreen.opacity(0.1) : Color.clear)
                    .foregroundStyle(selectedTab == tab ? Theme.forestGreen : Theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .background(Theme.surface)
    }

    private func iconFor(_ tab: Tab) -> String {
        switch tab {
        case .recent: return "clock.arrow.circlepath"
        case .lifeList: return "list.bullet.clipboard"
        case .map: return "map"
        }
    }
}

struct RecentSightingsView: View {
    @StateObject private var viewModel = SightingsViewModel()

    var body: some View {
        Group {
            if viewModel.sightings.isEmpty {
                emptyState
            } else {
                sightingsList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bird")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text("No Sightings Yet")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Open the Perch iOS app to log your first bird sighting!")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cream)
    }

    private var sightingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.sightings) { sighting in
                    BirdSightingRow(sighting: sighting)
                }
            }
            .padding()
        }
    }
}

struct BirdSightingRow: View {
    let sighting: Sighting

    var body: some View {
        HStack(spacing: 12) {
            // Photo placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.surface)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "bird.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.textSecondary.opacity(0.3))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(sighting.species?.commonName ?? "Unknown")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                Text(sighting.species?.scientificName ?? "")
                    .font(.system(size: 11)).italic()
                    .foregroundStyle(Theme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.system(size: 9))
                    Text(sighting.location.name)
                        .font(.system(size: 10))
                }
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(sighting.date, style: .date)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)

                Text(sighting.date, style: .time)
                    .font(.system(size: 9))
                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
            }
        }
        .padding(12)
        .cardStyle()
    }
}

#Preview {
    PopoverContentView()
}
