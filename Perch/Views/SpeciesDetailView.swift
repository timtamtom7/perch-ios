import SwiftUI

struct SpeciesDetailView: View {
    let species: BirdSpecies
    @EnvironmentObject var lifeListViewModel: LifeListViewModel
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @Environment(\.dismiss) private var dismiss

    private var sightingsOfSpecies: [Sighting] {
        sightingsViewModel.sightings.filter { $0.speciesId == species.id }
    }

    private var timesSpotted: Int {
        sightingsOfSpecies.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero image
                heroSection

                // Species info
                speciesInfoSection

                // Sighting history
                if !sightingsOfSpecies.isEmpty {
                    sightingHistorySection
                }

                // Add to life list button
                addToListButton
            }
            .padding(16)
        }
        .background(Theme.cream)
        .navigationTitle(species.commonName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .frame(height: 200)

            VStack(spacing: 12) {
                Image(systemName: "bird.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.forestGreen.opacity(0.6))

                if lifeListViewModel.isSpotted(species) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("In Your Life List")
                    }
                    .font(.caption)
                    .foregroundColor(Theme.forestGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.forestGreen.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
    }

    private var speciesInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Names
            VStack(alignment: .leading, spacing: 4) {
                Text(species.commonName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text(species.scientificName)
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(Theme.textSecondary)
            }

            Divider()

            // Details grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                InfoItem(icon: "leaf.fill", title: "Family", value: species.family)
                InfoItem(icon: "globe", title: "Region", value: species.region)
                InfoItem(icon: "house.fill", title: "Habitat", value: species.habitat)
                InfoItem(icon: "arrow.triangle.swap", title: "Migration", value: species.migrationPattern)
            }

            Divider()

            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("About")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Text(species.description)
                    .font(.body)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var sightingHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sighting History")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            ForEach(sightingsOfSpecies.prefix(5)) { sighting in
                SightingHistoryRow(sighting: sighting)
                if sighting.id != sightingsOfSpecies.prefix(5).last?.id {
                    Divider()
                }
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var addToListButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                lifeListViewModel.toggleSpotted(species)
            }
        } label: {
            HStack {
                Image(systemName: lifeListViewModel.isSpotted(species) ? "checkmark.circle.fill" : "plus.circle.fill")
                Text(lifeListViewModel.isSpotted(species) ? "In Your Life List" : "Add to Life List")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(lifeListViewModel.isSpotted(species) ? Theme.forestGreen : Theme.barkBrown)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(Theme.forestGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
            }
        }
    }
}

struct SightingHistoryRow: View {
    let sighting: Sighting

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(sighting.location.name)
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)

                Text(dateFormatter.string(from: sighting.date))
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            if !sighting.notes.isEmpty {
                Text(sighting.notes)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SpeciesDetailView(species: BirdSpecies.sample)
            .environmentObject(LifeListViewModel())
            .environmentObject(SightingsViewModel())
    }
}
