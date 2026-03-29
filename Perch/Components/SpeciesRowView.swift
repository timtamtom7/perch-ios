import SwiftUI

struct SpeciesRowView: View {
    let species: BirdSpecies
    let isSpotted: Bool
    var timesSpotted: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail placeholder
            ZStack {
                Circle()
                    .fill(isSpotted ? Theme.forestGreen.opacity(0.2) : Theme.surface)
                    .frame(width: 50, height: 50)

                Image(systemName: "bird.fill")
                    .font(.title3)
                    .foregroundColor(isSpotted ? Theme.forestGreen : Theme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(species.commonName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)

                Text(species.scientificName)
                    .font(.caption)
                    .italic()
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            if isSpotted {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.forestGreen)
                        Text("Spotted")
                            .font(.caption)
                            .foregroundColor(Theme.forestGreen)
                    }

                    if timesSpotted > 0 {
                        Text("\(timesSpotted) sighting\(timesSpotted == 1 ? "" : "s")")
                            .font(.caption2)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "binoculars")
                        .font(.caption)
                    Text("Unspotted")
                        .font(.caption)
                }
                .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 0) {
        SpeciesRowView(
            species: BirdSpecies.sample,
            isSpotted: true,
            timesSpotted: 12
        )
        Divider()
        SpeciesRowView(
            species: BirdSpecies.sample,
            isSpotted: false
        )
    }
    .padding()
    .background(Theme.cardBg)
}
