import SwiftUI
import PhotosUI
import CoreLocation

struct AddSightingView: View {
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var selectedSpecies: BirdSpecies?
    @State private var showingSpeciesPicker = false
    @State private var sightingDate = Date()
    @State private var locationName = ""
    @State private var latitude: Double = 0
    @State private var longitude: Double = 0
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingLocationSearch = false

    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                // Species selection
                Section {
                    Button {
                        showingSpeciesPicker = true
                    } label: {
                        HStack {
                            if let species = selectedSpecies {
                                ZStack {
                                    Circle()
                                        .fill(Theme.forestGreen.opacity(0.15))
                                        .frame(width: 40, height: 40)

                                    Image(systemName: "bird.fill")
                                        .foregroundColor(Theme.forestGreen)
                                }

                                VStack(alignment: .leading) {
                                    Text(species.commonName)
                                        .font(.body)
                                        .foregroundColor(Theme.textPrimary)
                                    Text(species.scientificName)
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(Theme.textSecondary)
                                }
                            } else {
                                Image(systemName: "bird.fill")
                                    .foregroundColor(Theme.textSecondary)

                                Text("Select Species")
                                    .foregroundColor(Theme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                } header: {
                    Text("Species")
                }

                // Date & Time
                Section {
                    DatePicker("Date & Time", selection: $sightingDate, displayedComponents: [.date, .hourAndMinute])
                        .tint(Theme.forestGreen)
                } header: {
                    Text("When")
                }

                // Location
                Section {
                    TextField("Location Name", text: $locationName)
                        .foregroundColor(Theme.textPrimary)

                    HStack {
                        Text("Latitude")
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        TextField("0.0", value: $latitude, format: .number.precision(.fractionLength(6)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Theme.textPrimary)
                    }

                    HStack {
                        Text("Longitude")
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        TextField("0.0", value: $longitude, format: .number.precision(.fractionLength(6)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(Theme.textPrimary)
                    }

                    Button {
                        useCurrentLocation()
                    } label: {
                        Label("Use Current Location", systemImage: "location.fill")
                            .foregroundColor(Theme.forestGreen)
                    }
                } header: {
                    Text("Location")
                }

                // Photo
                Section {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            if let photoData, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(Theme.textSecondary)

                                Text("Add Photo")
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                            }
                        }
                    }
                } header: {
                    Text("Photo (Optional)")
                }

                // Notes
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundColor(Theme.textPrimary)
                } header: {
                    Text("Notes (Optional)")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cream)
            .navigationTitle("New Sighting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSighting()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.forestGreen)
                    .disabled(selectedSpecies == nil)
                }
            }
            .sheet(isPresented: $showingSpeciesPicker) {
                SpeciesPickerView(selectedSpecies: $selectedSpecies)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func useCurrentLocation() {
        locationManager.requestLocation()
    }

    private func saveSighting() {
        guard let species = selectedSpecies else {
            errorMessage = "Please select a species"
            showingError = true
            return
        }

        let location = Location(
            name: locationName.isEmpty ? "Unknown Location" : locationName,
            latitude: latitude,
            longitude: longitude
        )

        let sighting = Sighting(
            id: UUID(),
            speciesId: species.id,
            date: sightingDate,
            location: location,
            notes: notes,
            photoData: photoData
        )

        sightingsViewModel.addSighting(sighting)
        dismiss()
    }
}

struct SpeciesPickerView: View {
    @Binding var selectedSpecies: BirdSpecies?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SpeciesViewModel()
    @State private var searchText = ""

    private var filteredSpecies: [BirdSpecies] {
        if searchText.isEmpty {
            return viewModel.species
        }
        return viewModel.species.filter {
            $0.commonName.localizedCaseInsensitiveContains(searchText) ||
            $0.scientificName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedSpecies: [String: [BirdSpecies]] {
        Dictionary(grouping: filteredSpecies) { $0.family }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedSpecies.keys.sorted(), id: \.self) { family in
                    Section(family) {
                        ForEach(groupedSpecies[family] ?? []) { species in
                            Button {
                                selectedSpecies = species
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(species.commonName)
                                            .font(.body)
                                            .foregroundColor(Theme.textPrimary)
                                        Text(species.scientificName)
                                            .font(.caption)
                                            .italic()
                                            .foregroundColor(Theme.textSecondary)
                                    }

                                    Spacer()

                                    if selectedSpecies?.id == species.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Theme.forestGreen)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search species...")
            .navigationTitle("Select Species")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.forestGreen)
                }
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var locationName: String = ""

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        reverseGeocode(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            if let placemark = placemarks?.first {
                var components: [String] = []
                if let name = placemark.name { components.append(name) }
                if let locality = placemark.locality { components.append(locality) }
                if let administrativeArea = placemark.administrativeArea { components.append(administrativeArea) }
                self?.locationName = components.joined(separator: ", ")
            }
        }
    }
}

#Preview {
    AddSightingView()
        .environmentObject(SightingsViewModel())
}
