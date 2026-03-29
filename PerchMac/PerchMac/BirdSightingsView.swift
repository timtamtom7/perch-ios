import SwiftUI

struct BirdSightingsView: View {
    @StateObject private var viewModel = SightingsViewModel()
    @State private var showingFilters = false
    @State private var selectedSighting: Sighting?

    var body: some View {
        VStack(spacing: 0) {
            // Search and filter header
            header

            // Filter chips
            if showingFilters {
                filterSection
            }

            // Sightings list
            if viewModel.filteredSightings.isEmpty {
                emptyState
            } else {
                sightingsList
            }
        }
        .background(Theme.cream)
        .sheet(item: $selectedSighting) { sighting in
            if let species = sighting.species {
                SpeciesDetailView(species: species)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textSecondary)

                TextField("Search sightings...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))

                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }

                Button(action: { showingFilters.toggle() }) {
                    Image(systemName: showingFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(showingFilters ? Theme.forestGreen : Theme.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            HStack {
                Text("\(viewModel.filteredSightings.count) sightings")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)

                Spacer()
            }
        }
        .padding()
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FILTERS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Species filter
                    Menu {
                        Button("All Species") {
                            viewModel.selectedSpecies = nil
                        }
                        Divider()
                        ForEach(SpeciesDataService.shared.species.prefix(20)) { species in
                            Button(species.commonName) {
                                viewModel.selectedSpecies = species.id
                            }
                        }
                    } label: {
                        FilterChip(
                            title: viewModel.selectedSpecies != nil ?
                                SpeciesDataService.shared.species.first { $0.id == viewModel.selectedSpecies }?.commonName ?? "Species" :
                                "Species",
                            isActive: viewModel.selectedSpecies != nil
                        )
                    }

                    // Date range filter
                    Button(action: {}) {
                        FilterChip(title: "Date Range", isActive: viewModel.dateRange != nil)
                    }
                    .buttonStyle(.plain)

                    // Clear filters
                    if viewModel.selectedSpecies != nil || viewModel.dateRange != nil {
                        Button(action: clearFilters) {
                            Text("Clear All")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.barkBrown)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func clearFilters() {
        viewModel.selectedSpecies = nil
        viewModel.dateRange = nil
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.searchText.isEmpty ? "bird" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text(viewModel.searchText.isEmpty ? "No Sightings Yet" : "No Results")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text(viewModel.searchText.isEmpty ?
                 "Start logging your bird sightings!" :
                 "Try adjusting your search or filters")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sightingsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredSightings) { sighting in
                    BirdSightingCard(sighting: sighting)
                        .onTapGesture {
                            selectedSighting = sighting
                        }
                }
            }
            .padding()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))

            Image(systemName: "chevron.down")
                .font(.system(size: 8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Theme.forestGreen.opacity(0.1) : Theme.surface)
        .foregroundStyle(isActive ? Theme.forestGreen : Theme.textPrimary)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(isActive ? Theme.forestGreen.opacity(0.3) : Color.clear, lineWidth: 1)
        }
    }
}

struct BirdSightingCard: View {
    let sighting: Sighting

    var body: some View {
        HStack(spacing: 16) {
            // Photo placeholder with field journal style
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.surface)

                VStack {
                    Image(systemName: "bird.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.textSecondary.opacity(0.3))

                    // Handwritten-style annotation
                    Text("photo")
                        .font(.system(size: 9, weight: .light, design: .serif))
                        .italic()
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 6) {
                Text(sighting.species?.commonName ?? "Unknown Bird")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(sighting.species?.scientificName ?? "")
                    .font(.system(size: 12)).italic()
                    .foregroundStyle(Theme.textSecondary)

                Divider()
                    .padding(.vertical, 2)

                HStack(spacing: 12) {
                    Label(sighting.location.name, systemImage: "location")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)

                    Spacer()

                    Text(sighting.date, style: .date)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    BirdSightingsView()
        .frame(width: 400, height: 600)
}
