import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sightingsViewModel: SightingsViewModel
    @EnvironmentObject var lifeListViewModel: LifeListViewModel
    @State private var showingAddSighting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress card
                    lifeListProgressCard

                    // Recent sightings
                    recentSightingsSection

                    // Quick stats
                    quickStatsSection
                }
                .padding(16)
            }
            .background(Theme.cream)
            .navigationTitle("Perch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSighting = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.forestGreen)
                    }
                }
            }
            .sheet(isPresented: $showingAddSighting) {
                AddSightingView()
            }
        }
    }

    private var lifeListProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Life List Progress")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)

                    Text("\(lifeListViewModel.spottedCount) of \(lifeListViewModel.totalInRegion) species")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }

                Spacer()

                ZStack {
                    ProgressRingView(
                        progress: lifeListViewModel.progressPercentage,
                        lineWidth: 8,
                        primaryColor: Theme.forestGreen
                    )
                    .frame(width: 60, height: 60)

                    Text("\(Int(lifeListViewModel.progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary)
                }
            }

            // Region picker
            HStack {
                Text("Region:")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)

                Picker("Region", selection: $lifeListViewModel.selectedRegion) {
                    ForEach(lifeListViewModel.availableRegions) { region in
                        Text(region.name).tag(region)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.forestGreen)
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var recentSightingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Sightings")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                NavigationLink {
                    BirdSightingsView()
                } label: {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(Theme.forestGreen)
                }
            }

            if sightingsViewModel.recentSightings.isEmpty {
                emptyStateView
            } else {
                ForEach(sightingsViewModel.recentSightings) { sighting in
                    NavigationLink {
                        if let species = sighting.species {
                            SpeciesDetailView(species: species)
                        }
                    } label: {
                        RecentSightingRow(sighting: sighting)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "bird.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.forestGreen.opacity(0.5))

            Text("Start Your Bird Watching Journey")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Text("Tap the + button to log your first sighting")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingAddSighting = true
            } label: {
                Text("Add First Sighting")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.forestGreen)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 20)
    }

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            HStack(spacing: 16) {
                StatCard(
                    title: "Total Sightings",
                    value: "\(sightingsViewModel.sightings.count)",
                    icon: "binoculars.fill",
                    color: Theme.skyBlue
                )

                StatCard(
                    title: "Species Seen",
                    value: "\(lifeListViewModel.spottedCount)",
                    icon: "bird.fill",
                    color: Theme.forestGreen
                )
            }
        }
    }
}

struct RecentSightingRow: View {
    let sighting: Sighting

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.forestGreen.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "bird.fill")
                    .foregroundColor(Theme.forestGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(sighting.species?.commonName ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)

                Text(sighting.location.name)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(dateFormatter.string(from: sighting.date))
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(SightingsViewModel())
        .environmentObject(LifeListViewModel())
}
