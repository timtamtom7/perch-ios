import SwiftUI

struct LifeListView: View {
    @EnvironmentObject var lifeListViewModel: LifeListViewModel
    @State private var selectedFamily: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filter
                VStack(spacing: 12) {
                    SearchBarView(text: $lifeListViewModel.searchText, placeholder: "Search species...")
                        .padding(.horizontal, 16)

                    // Family filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChipView(
                                title: "All",
                                isSelected: selectedFamily == nil
                            ) {
                                selectedFamily = nil
                            }

                            ForEach(lifeListViewModel.sortedFamilies, id: \.self) { family in
                                FilterChipView(
                                    title: family,
                                    isSelected: selectedFamily == family
                                ) {
                                    selectedFamily = family
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(Theme.cardBg)

                // Progress header
                progressHeader

                // Species list
                speciesList
            }
            .background(Theme.cream)
            .navigationTitle("Life List")
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                ProgressRingView(
                    progress: lifeListViewModel.progressPercentage,
                    lineWidth: 10,
                    primaryColor: Theme.forestGreen
                )
                .frame(width: 70, height: 70)

                VStack(spacing: 0) {
                    Text("\(lifeListViewModel.spottedCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Species Discovered")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text("\(lifeListViewModel.spottedCount) of \(lifeListViewModel.totalInRegion) in \(lifeListViewModel.selectedRegion.name)")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                Text("\(Int(lifeListViewModel.progressPercentage * 100))% complete")
                    .font(.caption)
                    .foregroundColor(Theme.forestGreen)
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.cardBg)
    }

    private var speciesList: some View {
        List {
            ForEach(lifeListViewModel.sortedFamilies, id: \.self) { family in
                // Only show families that match the filter
                if selectedFamily == nil || selectedFamily == family {
                    Section {
                        ForEach(speciesForFamily(family)) { species in
                            NavigationLink {
                                SpeciesDetailView(species: species)
                            } label: {
                                SpeciesRowView(
                                    species: species,
                                    isSpotted: lifeListViewModel.isSpotted(species),
                                    timesSpotted: lifeListViewModel.timesSpotted(for: species)
                                )
                            }
                            .listRowBackground(Theme.cardBg)
                        }
                    } header: {
                        HStack {
                            Text(family)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.textPrimary)

                            Spacer()

                            Text("\(speciesForFamily(family).filter { lifeListViewModel.isSpotted($0) }.count)/\(speciesForFamily(family).count)")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .textCase(nil)
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func speciesForFamily(_ family: String) -> [BirdSpecies] {
        lifeListViewModel.groupedByFamily[family] ?? []
    }
}

#Preview {
    LifeListView()
        .environmentObject(LifeListViewModel())
        .environmentObject(SightingsViewModel())
}
