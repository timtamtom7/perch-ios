import SwiftUI

struct LifeListView: View {
    @StateObject private var viewModel = LifeListViewModel()
    @State private var selectedSpecies: BirdSpecies?

    var body: some View {
        VStack(spacing: 0) {
            // Progress header
            progressHeader

            // Region selector
            regionSelector

            // Search
            searchBar

            // Species list
            speciesList
        }
        .background(Theme.cream)
        .sheet(item: $selectedSpecies) { species in
            SpeciesDetailView(species: species)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Life List Progress")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(viewModel.spottedCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Theme.forestGreen)

                        Text("of \(viewModel.totalInRegion)")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)

                        Text("species")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Spacer()

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Theme.surface, lineWidth: 6)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: viewModel.progressPercentage)
                        .stroke(Theme.forestGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(viewModel.progressPercentage * 100))%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.forestGreen)
                }
            }

            Text("in \(viewModel.selectedRegion.name)")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.cardBg)
    }

    private var regionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.availableRegions) { region in
                    Button(action: { viewModel.selectedRegion = region }) {
                        Text(region.name)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedRegion.id == region.id ? Theme.forestGreen : Theme.surface)
                            .foregroundStyle(viewModel.selectedRegion.id == region.id ? .white : Theme.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.textSecondary)

            TextField("Search species...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }

    private var speciesList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredSpecies) { species in
                    SpeciesRow(
                        species: species,
                        isSpotted: viewModel.isSpotted(species),
                        onTap: { selectedSpecies = species }
                    )
                }
            }
            .padding()
        }
    }
}

struct SpeciesRow: View {
    let species: BirdSpecies
    let isSpotted: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Status indicator
                Circle()
                    .fill(isSpotted ? Theme.forestGreen : Theme.surface)
                    .frame(width: 10, height: 10)
                    .overlay {
                        if isSpotted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                // Species info
                VStack(alignment: .leading, spacing: 2) {
                    Text(species.commonName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)

                    Text(species.scientificName)
                        .font(.system(size: 11)).italic()
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .padding(12)
            .background(isSpotted ? Theme.forestGreen.opacity(0.05) : Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LifeListView()
        .frame(width: 380, height: 500)
}
