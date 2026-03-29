import SwiftUI

struct SpeciesDetailView: View {
    let species: BirdSpecies
    @Environment(\.dismiss) private var dismiss
    @StateObject private var lifeListVM = LifeListViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            header

            ScrollView {
                VStack(spacing: 20) {
                    // Photo placeholder
                    photoSection

                    // Basic info
                    infoSection

                    // Stats
                    statsSection

                    // Details
                    detailsSection
                }
                .padding()
            }
        }
        .background(Theme.cream)
    }

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Theme.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(species.commonName)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            // Placeholder for balance
            Color.clear.frame(width: 28, height: 28)
        }
        .padding()
        .background(Theme.cardBg)
    }

    private var photoSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .frame(height: 180)

            VStack(spacing: 12) {
                Image(systemName: "bird.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.textSecondary.opacity(0.3))

                Text("Botanical Illustration Style")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary.opacity(0.6))
            }
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(species.commonName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            Text(species.scientificName)
                .font(.system(size: 16)).italic()
                .foregroundStyle(Theme.textSecondary)

            Text(species.description)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "eye.fill",
                value: "\(lifeListVM.timesSpotted(for: species))",
                label: "Times Spotted"
            )

            StatCard(
                icon: "calendar",
                value: firstSpottedText,
                label: "First Spotted"
            )

            StatCard(
                icon: "leaf.fill",
                value: species.family,
                label: "Family"
            )
        }
    }

    private var firstSpottedText: String {
        if lifeListVM.isSpotted(species) {
            return "Mar 2024"
        }
        return "—"
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Habitat")

            Text(species.habitat)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)

            SectionHeader(title: "Migration Pattern")

            Text(species.migrationPattern)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)

            SectionHeader(title: "Region")

            Text(species.region)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Theme.forestGreen)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .cardStyle()
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Theme.forestGreen)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

#Preview {
    SpeciesDetailView(species: BirdSpecies.sample)
        .frame(width: 400, height: 700)
}
