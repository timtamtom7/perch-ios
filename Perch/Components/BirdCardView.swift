import SwiftUI

struct BirdCardView: View {
    let sighting: Sighting
    var showSpecies: Bool = true

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Photo placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.surface)
                    .frame(height: 120)

                Image(systemName: "bird.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.forestGreen.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 4) {
                if let species = sighting.species {
                    Text(species.commonName)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)

                    Text(species.scientificName)
                        .font(.caption)
                        .italic()
                        .foregroundColor(Theme.textSecondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(dateFormatter.string(from: sighting.date))
                        .font(.caption)
                }
                .foregroundColor(Theme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.caption2)
                    Text(sighting.location.name)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(Theme.textSecondary)

                if !sighting.notes.isEmpty {
                    Text(sighting.notes)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
}

#Preview {
    BirdCardView(
        sighting: Sighting(
            id: UUID(),
            speciesId: "mallard",
            date: Date(),
            location: Location(name: "Central Park, New York", latitude: 40.7829, longitude: -73.9654),
            notes: "Spotted near the reservoir. Beautiful male duck.",
            photoData: nil
        )
    )
    .padding()
    .background(Theme.cream)
}
