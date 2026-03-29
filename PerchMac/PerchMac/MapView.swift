import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = SightingsViewModel()
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedSighting: Sighting?

    var body: some View {
        ZStack {
            // Map
            Map(position: $position) {
                ForEach(viewModel.sightings) { sighting in
                    Annotation(
                        sighting.species?.commonName ?? "Bird",
                        coordinate: sighting.location.coordinate,
                        anchor: .bottom
                    ) {
                        BirdPin(sighting: sighting, isSelected: selectedSighting?.id == sighting.id)
                            .onTapGesture {
                                withAnimation {
                                    selectedSighting = sighting
                                }
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapCompass()
                MapScaleView()
            }

            // Selected sighting card
            if let sighting = selectedSighting {
                VStack {
                    Spacer()
                    SightingMapCard(sighting: sighting)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // Empty state
            if viewModel.sightings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "map")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.textSecondary.opacity(0.4))

                    Text("No Sighting Locations")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Log sightings with locations to see them here")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.cream.opacity(0.9))
            }
        }
        .background(Theme.cream)
    }
}

struct BirdPin: View {
    let sighting: Sighting
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? Theme.forestGreen : Theme.barkBrown)
                    .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)

                Image(systemName: "bird.fill")
                    .font(.system(size: isSelected ? 16 : 12))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(isSelected ? Theme.forestGreen : Theme.barkBrown)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct SightingMapCard: View {
    let sighting: Sighting

    var body: some View {
        HStack(spacing: 12) {
            // Photo placeholder
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.surface)
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "bird.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.textSecondary.opacity(0.3))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(sighting.species?.commonName ?? "Unknown")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(sighting.species?.scientificName ?? "")
                    .font(.system(size: 12)).italic()
                    .foregroundStyle(Theme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    Text(sighting.location.name)
                        .font(.system(size: 11))
                }
                .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(sighting.date, style: .date)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)

                Text(sighting.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
            }
        }
        .padding(12)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MapView()
        .frame(width: 380, height: 400)
}
