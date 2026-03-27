import SwiftUI

/// Prompt shown when Perch detects the user is traveling
struct AreYouTravelingPromptView: View {
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @ObservedObject var detectionManager: TravelDetectionManager
    
    @State private var showingStartTripInfo = false
    @State private var showingTransportMode = false
    @State private var selectedMode: String = "flight"
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Theme.textSecondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Theme.terracotta.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: "airplane.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.terracotta)
                }
                
                // Title and city
                VStack(spacing: 6) {
                    Text("Are you on a trip?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if let city = detectionManager.travelPromptCity {
                        Text("Perch detected you're in \(city)")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textSecondary)
                    } else {
                        Text("Perch detected you're traveling")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                // Transport mode selector
                VStack(spacing: 8) {
                    Text("How are you traveling?")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    HStack(spacing: 12) {
                        ForEach(transportModes, id: \.mode) { tm in
                            TransportModeButton(
                                mode: tm.mode,
                                icon: tm.icon,
                                label: tm.label,
                                isSelected: selectedMode == tm.mode
                            ) {
                                selectedMode = tm.mode
                            }
                        }
                    }
                }
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        startTrip()
                    } label: {
                        HStack {
                            Image(systemName: "airplane.departure")
                            Text("Yes, Start Trip")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.terracotta)
                        .cornerRadius(Theme.cornerRadiusMedium)
                    }
                    
                    HStack(spacing: 12) {
                        Button {
                            detectionManager.snoozeTravelPrompt()
                        } label: {
                            Text("Not Now")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Theme.surfaceElevated)
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                        
                        Button {
                            detectionManager.dismissTravelPrompt()
                        } label: {
                            Text("No, I'm home")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Theme.textSecondary.opacity(0.4))
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Theme.background)
        .sheet(isPresented: $showingStartTripInfo) {
            StartTripInfoSheet(initialTransportMode: selectedMode) {
                detectionManager.dismissTravelPrompt()
            }
        }
    }
    
    private var transportModes: [(mode: String, icon: String, label: String)] {
        [
            ("flight", "airplane", "Flight"),
            ("car", "car.fill", "Car"),
            ("train", "tram.fill", "Train"),
            ("bus", "bus.fill", "Bus")
        ]
    }
    
    private func startTrip() {
        // Create the trip directly
        _ = tripStore.startTrip(transportMode: selectedMode)
        detectionManager.dismissTravelPrompt()
        // Start location monitoring if not already
        if !locationService.isMonitoring {
            locationService.startMonitoring()
        }
    }
}

// MARK: - Transport Mode Button

struct TransportModeButton: View {
    let mode: String
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Theme.terracotta : Theme.surfaceElevated)
            .cornerRadius(Theme.cornerRadiusSmall)
        }
    }
}

// MARK: - Start Trip Info Sheet

struct StartTripInfoSheet: View {
    let initialTransportMode: String
    let onDismiss: () -> Void
    
    @EnvironmentObject var tripStore: TripStore
    @Environment(\.dismiss) private var dismiss
    @State private var tripName: String = ""
    @AppStorage("defaultTransportMode") private var defaultTransportMode: String = "flight"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Trip name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip name (optional)")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    
                    TextField("e.g. Japan Adventure", text: $tripName)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textPrimary)
                        .padding(14)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(Theme.cornerRadiusSmall)
                }
                
                // Transport mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transport mode")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                    
                    HStack(spacing: 12) {
                        ForEach([
                            ("flight", "airplane", "Flight"),
                            ("car", "car.fill", "Car"),
                            ("train", "tram.fill", "Train"),
                            ("bus", "bus.fill", "Bus")
                        ], id: \.0) { mode, icon, label in
                            TransportModeButton(
                                mode: mode,
                                icon: icon,
                                label: label,
                                isSelected: defaultTransportMode == mode
                            ) {
                                defaultTransportMode = mode
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Start button
                Button {
                    let name = tripName.isEmpty ? nil : tripName
                    _ = tripStore.startTrip(name: name, transportMode: initialTransportMode.isEmpty ? defaultTransportMode : initialTransportMode)
                    dismiss()
                    onDismiss()
                } label: {
                    Text("Start Trip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.terracotta)
                        .cornerRadius(Theme.cornerRadiusMedium)
                }
            }
            .padding(20)
            .background(Theme.background)
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
}

// MARK: - Auto-End Trip Banner

struct AutoEndTripBanner: View {
    let trip: Trip
    let onEnd: () -> Void
    let onKeep: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.sage)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You're back home!")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Would you like to end your \(trip.name) trip?")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                Button {
                    onKeep()
                } label: {
                    Text("Keep Running")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.surfaceElevated)
                        .cornerRadius(Theme.cornerRadiusSmall)
                }
                
                Button {
                    onEnd()
                } label: {
                    Text("End Trip")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.terracotta)
                        .cornerRadius(Theme.cornerRadiusSmall)
                }
            }
        }
        .padding(14)
        .background(Theme.sage.opacity(0.12))
        .cornerRadius(Theme.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                .stroke(Theme.sage.opacity(0.3), lineWidth: 1)
        )
    }
}
