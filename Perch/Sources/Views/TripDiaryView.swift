import SwiftUI

struct TripDiaryView: View {
    let trip: Trip
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss
    @State private var tripNotes: String
    @State private var visitNotes: [Int64: String] = [:]
    @State private var isSaving = false
    @State private var showingSaved = false

    init(trip: Trip) {
        self.trip = trip
        _tripNotes = State(initialValue: trip.notes)
        var initial: [Int64: String] = [:]
        for visit in trip.visits {
            initial[visit.id] = visit.notes
        }
        _visitNotes = State(initialValue: initial)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Trip-level notes
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Trip Notes", systemImage: "note.text")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        TextEditor(text: $tripNotes)
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Theme.surfaceElevated)
                            .cornerRadius(12)
                            .overlay(
                                Group {
                                    if tripNotes.isEmpty {
                                        Text("How was this trip? Add memories, highlights, or things to remember…")
                                            .font(.system(size: 15))
                                            .foregroundColor(Theme.textSecondary.opacity(0.5))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }

                    Divider().background(Theme.divider)

                    // City-by-city diary
                    VStack(alignment: .leading, spacing: 12) {
                        Label("City Diary", systemImage: "book.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text("Add notes for each city you visited.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)

                        ForEach(trip.visits) { visit in
                            CityDiaryCard(
                                visit: visit,
                                notes: Binding(
                                    get: { visitNotes[visit.id] ?? "" },
                                    set: { visitNotes[visit.id] = $0 }
                                )
                            )
                        }
                    }

                    Spacer(minLength: 60)
                }
                .padding(16)
            }
            .background(Theme.background)
            .navigationTitle("Trip Diary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Theme.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(Theme.terracotta)
                        } else if showingSaved {
                            Image(systemName: "checkmark")
                                .foregroundColor(Theme.sage)
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.terracotta)
                        }
                    }
                    .disabled(isSaving || showingSaved)
                }
            }
        }
    }

    private func save() {
        isSaving = true
        tripStore.updateTripNotes(trip, notes: tripNotes)
        for (visitId, notes) in visitNotes {
            if let visit = trip.visits.first(where: { $0.id == visitId }) {
                tripStore.updateVisitNotes(visit, notes: notes)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            showingSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingSaved = false
        }
    }
}

struct CityDiaryCard: View {
    let visit: Visit
    @Binding var notes: String
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // City header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.terracotta)
                            .frame(width: 36, height: 36)
                        Text(visit.displayName.prefix(1))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(visit.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)

                        Text(formatDateRange)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                    }

                    Spacer()

                    // Note indicator
                    if !notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.sage)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    TextEditor(text: $notes)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                        .padding(10)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(8)
                        .overlay(
                            Group {
                                if notes.isEmpty {
                                    Text("What did you do in \(visit.city ?? "this city")? Coffee spots, neighborhoods, moments…")
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.textSecondary.opacity(0.5))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 18)
                                        .allowsHitTesting(false)
                                }
                            },
                            alignment: .topLeading
                        )

                    // Quick-add suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quickSuggestions, id: \.self) { suggestion in
                                Button {
                                    if notes.isEmpty {
                                        notes = suggestion
                                    } else {
                                        notes += notes.hasSuffix(" ") || notes.hasSuffix("\n") ? suggestion : " \(suggestion)"
                                    }
                                } label: {
                                    Text(suggestion)
                                        .font(.system(size: 12))
                                        .foregroundColor(Theme.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Theme.surfaceElevated)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Theme.surface)
        .cornerRadius(12)
    }

    private var formatDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: visit.arrivalDate)
        if let end = visit.departureDate {
            let endStr = formatter.string(from: end)
            return start == endStr ? start : "\(start) – \(endStr)"
        }
        return "\(start) – present"
    }

    private var quickSuggestions: [String] {
        ["Great coffee", "Must return", "Food highlight", "Hidden gem", "Local tip", "Off the radar"]
    }
}

// MARK: - Trip Privacy Toggle

struct TripPrivacyView: View {
    let trip: Trip
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(trip.isPrivate ? Color(hex: "fbbf24").opacity(0.15) : Theme.terracotta.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: trip.isPrivate ? "lock.fill" : "globe")
                        .font(.system(size: 40))
                        .foregroundColor(trip.isPrivate ? Color(hex: "fbbf24") : Theme.terracotta)
                }

                VStack(spacing: 8) {
                    Text(trip.isPrivate ? "Private Trip" : "Public Trip")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)

                    Text(trip.isPrivate ? privateDescription : publicDescription)
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 12) {
                    Toggle(isOn: Binding(
                        get: { trip.isPrivate },
                        set: { tripStore.updateTripPrivacy(trip, isPrivate: $0) }
                    )) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(hex: "fbbf24"))
                            Text("Keep this trip private")
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                    .tint(Theme.terracotta)
                    .padding(16)
                    .background(Theme.surface)
                    .cornerRadius(12)

                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                    .buttonStyle(PerchButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Theme.background)
            .navigationTitle("Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Theme.terracotta)
                }
            }
        }
    }

    private var privateDescription: String {
        "This trip is hidden from your travel history and insights. Only you can see it."
    }

    private var publicDescription: String {
        "This trip appears in your travel history, insights, and city rankings."
    }
}
