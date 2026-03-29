import SwiftUI

struct ExpertGuideView: View {
    @State private var selectedSpeciesId: String?
    @State private var selectedGuide: ExpertGuide?

    private var communityService: CommunityService { CommunityService.shared }

    private var guides: [ExpertGuide] {
        communityService.getAllExpertGuides()
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if guides.isEmpty {
                emptyState
            } else {
                guidesList
            }
        }
        .background(Theme.cream)
        .sheet(item: $selectedGuide) { guide in
            ExpertGuideDetailView(guide: guide)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "books.vertical")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.barkBrown)

                Text("Expert Species Guides")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()
            }

            Text("Detailed guides written by ornithologists for the most-watched species")
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Theme.textSecondary.opacity(0.4))

            Text("No Guides Available")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("Expert guides will be available for download soon")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var guidesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(guides) { guide in
                    ExpertGuideCard(guide: guide)
                        .onTapGesture {
                            selectedGuide = guide
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Expert Guide Card

struct ExpertGuideCard: View {
    let guide: ExpertGuide

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Species icon
                ZStack {
                    Circle()
                        .fill(Theme.forestGreen.opacity(0.15))
                        .frame(width: 60, height: 60)

                    Image(systemName: "bird.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.forestGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(guide.species?.commonName ?? "Unknown Species")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(guide.species?.scientificName ?? "")
                        .font(.system(size: 12))
                        .italic()
                        .foregroundStyle(Theme.textSecondary)

                    HStack(spacing: 4) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 10))
                        Text(guide.author)
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Theme.barkBrown)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(guide.sections.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.forestGreen)
                    Text("sections")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Divider()

            // Quick info row
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tips")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(guide.tips.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Similar Species")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(guide.similarSpecies.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Best Locations")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(guide.bestLocations.count)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()

                Text("Updated \(guide.lastUpdated, format: Date.FormatStyle().month(.abbreviated).day())")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Expert Guide Detail View

struct ExpertGuideDetailView: View {
    let guide: ExpertGuide
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSections: Set<UUID> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection

                    // Quick Tips
                    tipsSection

                    // Sections
                    ForEach(guide.sections) { section in
                        sectionView(section)
                    }

                    // Best Locations
                    bestLocationsSection

                    // Similar Species
                    similarSpeciesSection
                }
                .padding()
            }
            .background(Theme.cream)
            .navigationTitle("Expert Guide")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Theme.forestGreen.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "bird.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.forestGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(guide.species?.commonName ?? "Unknown")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(guide.species?.scientificName ?? "")
                        .font(.system(size: 14))
                        .italic()
                        .foregroundStyle(Theme.textSecondary)

                    Divider()
                        .padding(.vertical, 4)

                    HStack(spacing: 4) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 11))
                        Text(guide.author)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Theme.barkBrown)

                    Text(guide.authorTitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }

            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 11))
                Text("Last updated: \(guide.lastUpdated, format: .dateTime.month().day().year())")
                    .font(.system(size: 11))
            }
            .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Quick Tips")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(guide.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.forestGreen)

                        Text(tip)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
        }
        .padding()
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sectionView(_ section: GuideSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header (tappable)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedSections.contains(section.id) {
                        expandedSections.remove(section.id)
                    } else {
                        expandedSections.insert(section.id)
                    }
                }
            }) {
                HStack {
                    Text(section.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    Image(systemName: expandedSections.contains(section.id) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
                .background(Theme.cardBg)
            }
            .buttonStyle(.plain)

            // Section content
            if expandedSections.contains(section.id) {
                Text(section.content)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(4)
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    private var bestLocationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(Theme.barkBrown)
                Text("Best Viewing Locations")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            ForEach(guide.bestLocations, id: \.name) { location in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)

                        HStack(spacing: 8) {
                            Text(location.state)
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.forestGreen)

                            Text("•")
                                .foregroundStyle(Theme.textSecondary)

                            Text("Best in \(location.bestSeason)")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding()
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var similarSpeciesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.on.square")
                    .foregroundStyle(Theme.skyBlue)
                Text("Similar Species")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            FlowLayout(spacing: 8) {
                ForEach(guide.similarSpecies, id: \.self) { speciesId in
                    if let species = SpeciesDataService.shared.species.first(where: { $0.id == speciesId }) {
                        Text(species.commonName)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.surface)
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Theme.skyBlue.opacity(0.3), lineWidth: 1)
                            }
                    } else {
                        Text(speciesId)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.surface)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    if let guide = CommunityService.shared.getExpertGuide(for: "amro") {
        ExpertGuideDetailView(guide: guide)
            .frame(width: 500, height: 800)
    }
}
