import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedSighting: Sighting?

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position, selection: $selectedSighting) {
                    ForEach(sightingsViewModel.sightings) { sighting in
                        if let species = sighting.species {
                            Annotation(
                                species.commonName,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: sighting.location.latitude,
                                    longitude: sighting.location.longitude
                                ),
                                anchor: .bottom
                            ) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.forestGreen)
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "bird.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                            .tag(sighting)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }

                // Selected sighting card overlay
                if let sighting = selectedSighting {
                    VStack {
                        Spacer()

                        SightingMapCard(sighting: sighting)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                // Empty state overlay
                if sightingsViewModel.sightings.isEmpty {
                    VStack {
                        Spacer()

                        VStack(spacing: 12) {
                            Image(systemName: "map")
                                .font(.system(size: 48))
                                .foregroundColor(Theme.textSecondary.opacity(0.5))

                            Text("No Sightings to Show")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)

                            Text("Add sightings with locations to see them on the map")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(Theme.cardBg.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(32)
                        .shadow(color: .black.opacity(0.1), radius: 10)

                        Spacer()
                    }
                }
            }
            .navigationTitle("Map")
            .animation(.easeInOut(duration: 0.25), value: selectedSighting)
        }
    }
}

struct SightingMapCard: View {
    let sighting: Sighting
    @Environment(\.dismiss) private var dismiss

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Thumbnail
                ZStack {
                    Circle()
                        .fill(Theme.forestGreen.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "bird.fill")
                        .font(.title3)
                        .foregroundColor(Theme.forestGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(sighting.species?.commonName ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)

                    Text(sighting.species?.scientificName ?? "")
                        .font(.caption)
                        .italic()
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Button {
                    // Dismiss would be handled by parent
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Divider()

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(sighting.location.name)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(Theme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(dateFormatter.string(from: sighting.date))
                        .font(.caption)
                }
                .foregroundColor(Theme.textSecondary)
            }

            if !sighting.notes.isEmpty {
                Text(sighting.notes)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
            }

            // Navigate button
            Button {
                openInMaps()
            } label: {
                HStack {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    Text("Open in Maps")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.forestGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10)
    }

    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(
            latitude: sighting.location.latitude,
            longitude: sighting.location.longitude
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = sighting.location.name
        mapItem.openInMaps(launchOptions: nil)
    }
}

#Preview {
    MapView()
        .environmentObject(SightingsViewModel())
}
