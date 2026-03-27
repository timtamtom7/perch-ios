import SwiftUI

/// R8: Cross-device sync settings view
struct PerchCrossDeviceSyncView: View {
    @StateObject private var syncService = PerchCrossDeviceSyncService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Sync status
                        syncStatusCard

                        // Connected devices
                        devicesSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Sync")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var syncStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("iCloud Sync")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text(syncService.lastSyncText)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                if syncService.isSyncing {
                    ProgressView()
                        .tint(Theme.sage)
                } else {
                    Button {
                        Task {
                            try? await syncService.syncAll()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 18))
                            .foregroundColor(Theme.sage)
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Devices")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            if syncService.connectedDevices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.textTertiary)

                    Text("No devices connected")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.textSecondary)

                    Text("Sign in with the same Apple ID on other devices to sync your trips.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
            } else {
                ForEach(syncService.connectedDevices) { device in
                    deviceRow(device)
                }
            }
        }
    }

    private func deviceRow(_ device: PerchCrossDeviceSyncService.Device) -> some View {
        HStack(spacing: 12) {
            Image(systemName: deviceIcon(device.type))
                .font(.system(size: 20))
                .foregroundColor(device.isConnected ? Theme.sage : Theme.textSecondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textPrimary)

                Text(device.isConnected ? "Connected" : "Last seen recently")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            if device.isConnected {
                Circle()
                    .fill(Theme.sage)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
    }

    private func deviceIcon(_ type: PerchCrossDeviceSyncService.Device.DeviceType) -> String {
        switch type {
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .mac: return "laptopcomputer"
        case .appleWatch: return "applewatch"
        }
    }
}

#Preview {
    PerchCrossDeviceSyncView()
}
