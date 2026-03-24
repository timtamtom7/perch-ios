import SwiftUI
import CoreLocation

struct StartTripInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripStore: TripStore
    @EnvironmentObject var locationService: LocationService
    @State private var isStarting = false
    @State private var showingPermissionDenied = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showingPermissionDenied {
                LocationPermissionDeniedView()
            } else {
                mainContent
            }
        }
        .onChange(of: locationService.authorizationStatus) { _, newStatus in
            if newStatus == .denied || newStatus == .restricted {
                showingPermissionDenied = true
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "airplane.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Theme.terracotta)

            VStack(spacing: 8) {
                Text("Ready to take off?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("Perch will log your locations in the background.\nNo photos. No check-ins. Just places you've been.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                FeatureRow(icon: "location.slash", title: "Location only when active", description: "Perch only tracks when you start a trip")
                FeatureRow(icon: "battery.100", title: "Battery efficient", description: "Uses significant location changes, not GPS")
                FeatureRow(icon: "lock.shield", title: "Private by design", description: "All data stays on your device")
            }
            .padding(.horizontal, 20)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    startTrip()
                } label: {
                    if isStarting {
                        ProgressView()
                            .tint(Theme.background)
                    } else {
                        Text("Start Trip")
                    }
                }
                .buttonStyle(PerchButtonStyle())
                .disabled(isStarting)

                Button("Cancel") {
                    dismiss()
                }
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    private func startTrip() {
        isStarting = true

        // Check permission status first
        if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
            showingPermissionDenied = true
            isStarting = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            _ = tripStore.startTrip()
            locationService.requestAuthorization()

            // If permission already granted, start monitoring
            if locationService.authorizationStatus == .authorizedAlways || locationService.authorizationStatus == .authorizedWhenInUse {
                locationService.startMonitoring()
            }

            dismiss()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.terracotta)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
