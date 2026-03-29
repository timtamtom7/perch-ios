import SwiftUI

struct BirdSightingsView: View {
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @State private var showingAddSighting = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                SearchBarView(text: $sightingsViewModel.searchText, placeholder: "Search sightings...")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                // Content
                if sightingsViewModel.isLoading {
                    loadingView
                } else if sightingsViewModel.filteredSightings.isEmpty {
                    emptyStateView
                } else {
                    sightingsList
                }
            }
            .background(Theme.cream)
            .navigationTitle("Sightings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSighting = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.forestGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddSighting) {
                AddSightingView()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bird.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.forestGreen.opacity(0.5))
                .symbolEffect(.pulse)

            Text("Loading sightings...")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "binoculars")
                .font(.system(size: 64))
                .foregroundColor(Theme.textSecondary.opacity(0.5))

            Text("No Sightings Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)

            Text("Start logging your bird sightings to build your collection")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                showingAddSighting = true
            } label: {
                Label("Add Sighting", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.forestGreen)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sightingsList: some View {
        List {
            ForEach(sightingsViewModel.filteredSightings) { sighting in
                NavigationLink {
                    if let species = sighting.species {
                        SpeciesDetailView(species: species)
                    }
                } label: {
                    SightingRow(sighting: sighting)
                }
                .listRowBackground(Theme.cardBg)
                .listRowSeparator(.visible)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let sighting = sightingsViewModel.filteredSightings[index]
                    sightingsViewModel.deleteSighting(sighting)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct SightingRow: View {
    let sighting: Sighting

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.surface)
                    .frame(width: 60, height: 60)

                Image(systemName: "bird.fill")
                    .font(.title2)
                    .foregroundColor(Theme.forestGreen.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(sighting.species?.commonName ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text(sighting.species?.scientificName ?? "")
                    .font(.caption)
                    .italic()
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 12) {
                    Label {
                        Text(sighting.location.name)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "location")
                    }
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                    Label {
                        Text(dateFormatter.string(from: sighting.date))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BirdSightingsView()
        .environmentObject(SightingsViewModel())
}
