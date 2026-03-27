import SwiftUI

struct TripTemplatesView: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var templateStore: TemplateStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewTemplate = false
    @State private var showingSaveFromTrip = false
    @State private var selectedTemplateForUse: TripTemplate?
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Pre-built templates
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Pre-built Templates")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            Spacer()

                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.terracotta)
                        }

                        ForEach(preBuiltTemplates) { template in
                            TripTemplateCardView(template: template, isCompact: false) {
                                selectedTemplateForUse = template
                            }
                        }
                    }

                    // Your templates
                    if !userTemplates.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Templates")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1)

                            ForEach(userTemplates) { template in
                                HStack(alignment: .top, spacing: 0) {
                                    TripTemplateCardView(template: template, isCompact: true) {
                                        selectedTemplateForUse = template
                                    }
                                    .frame(maxWidth: .infinity)

                                    Button {
                                        templateStore.deleteTemplate(template)
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 13))
                                            .foregroundColor(Theme.textSecondary)
                                            .padding(12)
                                    }
                                }
                            }
                        }
                    }

                    // Save from past trip
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Save a Trip as Template")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        if pastTrips.isEmpty {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                    .foregroundColor(Theme.textSecondary.opacity(0.5))
                                Text("Complete a trip first to save it as a template")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Theme.surface)
                            .cornerRadius(Theme.cornerRadiusMedium)
                        } else {
                            ForEach(pastTrips.prefix(3)) { trip in
                                SaveTripAsTemplateRow(trip: trip) { success in
                                    if success {
                                        showingSaveFromTrip = false
                                    } else {
                                        errorMessage = "Failed to save template. Please try again."
                                        showingError = true
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Trip Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
            .sheet(item: $selectedTemplateForUse) { template in
                UseTemplateSheet(template: template) {
                    dismiss()
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var preBuiltTemplates: [TripTemplate] {
        templateStore.templates.filter { $0.id < 0 }
    }

    private var userTemplates: [TripTemplate] {
        templateStore.templates.filter { $0.id > 0 }
    }

    private var pastTrips: [Trip] {
        tripStore.trips.filter { !$0.isActive }
    }
}

struct SaveTripAsTemplateRow: View {
    let trip: Trip
    let onSave: (Bool) -> Void
    @State private var showingSheet = false

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tripPrimaryLabel)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(tripSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.terracotta)
            }
            .padding(14)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
        .sheet(isPresented: $showingSheet) {
            SaveTemplateSheet(trip: trip, onSave: onSave)
        }
    }

    private var tripPrimaryLabel: String {
        trip.templateName ?? trip.cities.first ?? trip.name
    }

    private var tripSubtitle: String {
        "\(trip.formattedDuration) · \(trip.cities.count) city\(trip.cities.count == 1 ? "" : "s")"
    }
}

struct SaveTemplateSheet: View {
    let trip: Trip
    let onSave: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var templateStore: TemplateStore
    @State private var templateName: String = ""
    @State private var expectedDays: Int = 1
    @State private var transportMode: String = "flight"
    @State private var tripType: TripType = .short
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var saveFailed = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Template Name")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("e.g. Weekend in Paris", text: $templateName)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Expected Duration")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        HStack {
                            Text("\(expectedDays) day\(expectedDays == 1 ? "" : "s")")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textPrimary)

                            Slider(value: Binding(
                                get: { Double(expectedDays) },
                                set: { expectedDays = Int($0) }
                            ), in: 1...30, step: 1)
                            .tint(Theme.terracotta)
                        }
                        .padding(12)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(Theme.cornerRadiusSmall)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Type")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(TripType.allCases, id: \.self) { type in
                                Button {
                                    tripType = type
                                } label: {
                                    HStack {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 12))
                                        Text(type.displayName)
                                            .font(.system(size: 13))
                                    }
                                    .foregroundColor(tripType == type ? Theme.background : Theme.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(tripType == type ? Theme.terracotta : Theme.surfaceElevated)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Transport")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        HStack(spacing: 12) {
                            ForEach([
                                ("flight", "Airplane", "airplane"),
                                ("train", "Train", "tram.fill"),
                                ("car", "Car", "car.fill"),
                                ("bus", "Bus", "bus.fill")
                            ], id: \.0) { mode, label, icon in
                                Button {
                                    transportMode = mode
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                        Text(label)
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(transportMode == mode ? Theme.background : Theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(transportMode == mode ? Theme.terracotta : Theme.surfaceElevated)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField("Tips, reminders, what makes this trip special…", text: $notes, axis: .vertical)
                            .font(.system(size: 14))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(3...5)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveTemplate()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(Theme.terracotta)
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.terracotta)
                        }
                    }
                    .disabled(templateName.isEmpty || isSaving)
                }
            }
            .alert("Save Failed", isPresented: $saveFailed) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Failed to save template. Please try again.")
            }
        }
    }

    private func saveTemplate() {
        guard !templateName.isEmpty else { return }
        isSaving = true

        let destinations = trip.visits.enumerated().compactMap { index, visit -> TemplateDestination? in
            guard let city = visit.city else { return nil }
            return TemplateDestination(
                city: city,
                country: visit.country,
                latitude: visit.latitude,
                longitude: visit.longitude,
                order: index
            )
        }

        let template = TripTemplate(
            id: 0,
            name: templateName,
            destinations: destinations,
            expectedDurationDays: expectedDays,
            transportMode: transportMode,
            tripType: tripType,
            notes: notes,
            createdAt: Date()
        )

        let success = templateStore.saveTemplate(template)
        isSaving = false

        if success {
            onSave(true)
            dismiss()
        } else {
            saveFailed = true
            onSave(false)
        }
    }
}

struct UseTemplateSheet: View {
    let template: TripTemplate
    let onUse: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @State private var customName: String = ""
    @State private var isStarting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TripTemplateCardView(template: template, isCompact: false)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Trip Name")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        TextField(template.name, text: $customName)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textPrimary)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(Theme.cornerRadiusSmall)
                    }

                    VStack(spacing: 12) {
                        Button {
                            startFromTemplate()
                        } label: {
                            HStack {
                                if isStarting {
                                    ProgressView()
                                        .tint(Theme.background)
                                } else {
                                    Image(systemName: "airplane.departure")
                                    Text("Start Trip")
                                }
                            }
                        }
                        .buttonStyle(PerchButtonStyle())
                        .disabled(isStarting)

                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Use Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }

    private func startFromTemplate() {
        isStarting = true
        let name = customName.isEmpty ? template.name : customName
        _ = tripStore.startTrip(
            name: name,
            templateId: template.id,
            templateName: template.name,
            transportMode: template.transportMode
        )
        locationService.startMonitoring()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isStarting = false
            onUse()
            dismiss()
        }
    }
}
