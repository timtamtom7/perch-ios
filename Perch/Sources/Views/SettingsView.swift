import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tripStore: TripStore
    @AppStorage("useImperialUnits") private var useImperialUnits = false
    @AppStorage("defaultTransportMode") private var defaultTransportMode = "flight"
    @AppStorage("userSubscriptionTier") private var userSubscriptionTier = "free"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingOnboarding = false
    @State private var showingPricing = false

    var body: some View {
        NavigationStack {
            List {
                // Subscription section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Plan")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                            Text(subscriptionTierName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(tierColor)
                        }
                        Spacer()

                        if userSubscriptionTier != "explorer" {
                            Button("Upgrade") {
                                showingPricing = true
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.background)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Theme.terracotta)
                            .cornerRadius(8)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    if userSubscriptionTier == "free" {
                        HStack {
                            Text("Trips remaining")
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Text("3 of 3 used")
                                .foregroundColor(Theme.textSecondary)
                        }
                        .listRowBackground(Theme.surface)
                    }
                } header: {
                    Text("Subscription")
                        .foregroundColor(Theme.textSecondary)
                }

                // Preferences section
                Section {
                    HStack {
                        Text("Distance units")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Picker("", selection: $useImperialUnits) {
                            Text("Kilometers").tag(false)
                            Text("Miles").tag(true)
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.terracotta)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Transport mode")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Picker("", selection: $defaultTransportMode) {
                            Text("Flight").tag("flight")
                            Text("Car").tag("car")
                            Text("Train").tag("train")
                            Text("Bus").tag("bus")
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.terracotta)
                    }
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("Preferences")
                        .foregroundColor(Theme.textSecondary)
                }

                // Help section
                Section {
                    Button {
                        showingOnboarding = true
                    } label: {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(Theme.terracotta)
                                .frame(width: 24)
                            Text("How Perch works")
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Image(systemName: "location.slash")
                            .foregroundColor(Theme.textSecondary)
                            .frame(width: 24)
                        Text("Location permissions")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text(locationPermissionStatus)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("Help")
                        .foregroundColor(Theme.textSecondary)
                }

                // Privacy section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location Privacy")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Perch uses your location only to log cities you visit during active trips. No data leaves your phone. Ever.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Theme.surface)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data Storage")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text("All trip data is stored locally on your device. Perch does not use any cloud services, accounts, or external servers.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("Privacy")
                        .foregroundColor(Theme.textSecondary)
                }

                // App Store section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Perch — Know where you've been")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)

                        Text("Perch is a passive travel tracker. Start a trip before you leave and it quietly logs every city you visit. No check-ins. No social. No effort. Just a beautiful record of everywhere you've been.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                            .lineSpacing(4)

                        Divider().background(Theme.divider)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("App Description")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)

                            Text("Perch passively tracks your travels, building a personal travel atlas of every city and country you visit. Start a trip, forget about it, end it when you get home — and discover everywhere you've been.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.textSecondary)
                                .lineSpacing(4)

                            Text("Keywords")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                                .padding(.top, 4)

                            Text("travel tracker, trip logger, places visited, city tracker, travel history, passive tracking, trip counter, country visited, personal atlas, footprint tracker, co2 tracker, flight tracker")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("App Store")
                        .foregroundColor(Theme.textSecondary)
                }

                // About section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text("1.0 (1)")
                            .foregroundColor(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.surface)

                    HStack {
                        Text("Build")
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                        Text("Release")
                            .foregroundColor(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("About")
                        .foregroundColor(Theme.textSecondary)
                }

                // Data section
                Section {
                    Button(role: .destructive) {
                        // Future: data export
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export All Data")
                        }
                    }
                    .listRowBackground(Theme.surface)

                    Button(role: .destructive) {
                        // Future: data reset with confirmation
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete All Trips")
                        }
                    }
                    .listRowBackground(Theme.surface)
                } header: {
                    Text("Data")
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.terracotta)
                }
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $showingPricing) {
                PricingView()
            }
        }
    }

    private var subscriptionTierName: String {
        switch userSubscriptionTier {
        case "wander": return "Wander · $4.99/mo"
        case "explorer": return "Explorer · $9.99/mo"
        default: return "Free"
        }
    }

    private var tierColor: Color {
        switch userSubscriptionTier {
        case "wander": return Theme.terracotta
        case "explorer": return Theme.sage
        default: return Theme.textSecondary
        }
    }

    private var locationPermissionStatus: String {
        // R6: Use instance method to avoid deprecated class method
        let status = CLLocationManager().authorizationStatus
        switch status {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Set"
        @unknown default: return "Unknown"
        }
    }
}
