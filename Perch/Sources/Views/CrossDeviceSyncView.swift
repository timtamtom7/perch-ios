import SwiftUI

/// R8: Cross-device sync settings view
struct PerchCrossDeviceSyncView: View {
    @StateObject private var syncService = PerchCrossDeviceSyncService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f8f6f2")
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
                        .foregroundColor(Color(hex: "1a1a1a"))

                    Text(syncService.lastSyncText)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b6b6b"))
                }

                Spacer()

                if syncService.isSyncing {
                    ProgressView()
                        .tint(Color(hex: "2d7d46"))
                } else {
                    Button {
                        Task {
                            try? await syncService.syncAll()
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "2d7d46"))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var devicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Devices")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "1a1a1a"))

            if syncService.connectedDevices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: "c0c0c0"))

                    Text("No devices connected")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "6b6b6b"))

                    Text("Sign in with the same Apple ID on other devices to sync your trips.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "999999"))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
                .foregroundColor(device.isConnected ? Color(hex: "2d7d46") : Color(hex: "6b6b6b"))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "1a1a1a"))

                Text(device.isConnected ? "Connected" : "Last seen recently")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b6b6b"))
            }

            Spacer()

            if device.isConnected {
                Circle()
                    .fill(Color(hex: "2d7d46"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
