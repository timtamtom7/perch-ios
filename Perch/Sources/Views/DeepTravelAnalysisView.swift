import SwiftUI

/// R7: Deep Travel Analysis view - AI-powered insights and recommendations
struct DeepTravelAnalysisView: View {
    @StateObject private var analysisService = DeepTravelAnalysisService.shared
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                if analysisService.isAnalyzing {
                    analyzingView
                } else if analysisService.travelPatterns.isEmpty {
                    emptyState
                } else {
                    analysisContent
                }
            }
            .navigationTitle("Travel Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await analysisService.analyzeAll(trips: [])
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Theme.sage)
                    }
                }
            }
            .task {
                if analysisService.travelPatterns.isEmpty {
                    await analysisService.analyzeAll(trips: [])
                }
            }
        }
    }

    private var analyzingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "e0e0e0"), lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: analysisService.analysisProgress)
                    .stroke(Theme.sage, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: analysisService.analysisProgress)

                Text("\(Int(analysisService.analysisProgress * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Theme.textPrimary)
            }

            VStack(spacing: 6) {
                Text("Analyzing your travels…")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("Discovering patterns and insights")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(Theme.textTertiary)

            VStack(spacing: 6) {
                Text("No trips to analyze")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text("Start tracking your travels to\nuncover insights about your journeys.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await analysisService.analyzeAll(trips: [])
                }
            } label: {
                Text("Analyze Now")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.background)
                    .frame(width: 160, height: 44)
                    .background(Theme.sage)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
            }
            .padding(.top, 8)
        }
        .padding(40)
    }

    private var analysisContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Tab selector
                Picker("", selection: $selectedTab) {
                    Text("Patterns").tag(0)
                    Text("CO2").tag(1)
                    Text("Destinations").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                switch selectedTab {
                case 0: patternsSection
                case 1: co2Section
                case 2: destinationsSection
                default: EmptyView()
                }
            }
            .padding(.vertical, 16)
        }
    }

    private var patternsSection: some View {
        VStack(spacing: 12) {
            ForEach(analysisService.travelPatterns) { pattern in
                patternCard(pattern)
            }
        }
        .padding(.horizontal, 16)
    }

    private func patternCard(_ pattern: DeepTravelAnalysisService.TravelPattern) -> some View {
        HStack(spacing: 16) {
            Image(systemName: patternIcon(pattern.type))
                .font(.system(size: 24))
                .foregroundColor(Theme.sage)
                .frame(width: 48, height: 48)
                .background(Theme.sage.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)

                Text(pattern.description)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)

                if pattern.co2Saved > 0 {
                    Text("~\(String(format: "%.0f", pattern.co2Saved)) kg CO2 saved")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.sage)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    private func patternIcon(_ type: DeepTravelAnalysisService.TravelPattern.PatternType) -> String {
        switch type {
        case .frequentFlyer: return "airplane"
        case .roadTrip: return "car.fill"
        case .weekendGetaway: return "bag.fill"
        case .ecoTraveler: return "leaf.fill"
        }
    }

    private var co2Section: some View {
        VStack(spacing: 12) {
            ForEach(analysisService.co2Insights) { insight in
                co2InsightCard(insight)
            }
        }
        .padding(.horizontal, 16)
    }

    private func co2InsightCard(_ insight: DeepTravelAnalysisService.CO2Insight) -> some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.sage)
                .frame(width: 40, height: 40)
                .background(Theme.sage.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)

                Text(insight.value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: trendIcon(insight.trend))
                        .font(.system(size: 12))
                    Text(insight.comparison)
                        .font(.system(size: 12))
                }
                .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    private func trendIcon(_ trend: DeepTravelAnalysisService.CO2Insight.Trend) -> String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }

    private var destinationsSection: some View {
        VStack(spacing: 12) {
            ForEach(analysisService.recommendations) { rec in
                recommendationCard(rec)
            }
        }
        .padding(.horizontal, 16)
    }

    private func recommendationCard(_ rec: DeepTravelAnalysisService.DestinationRecommendation) -> some View {
        HStack(spacing: 16) {
            Image(systemName: rec.imageSystemName)
                .font(.system(size: 24))
                .foregroundColor(Theme.background)
                .frame(width: 56, height: 56)
                .background(LinearGradient(colors: [Theme.sage, Theme.sage], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rec.destination)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text("•")
                        .foregroundColor(Theme.textTertiary)

                    Text(rec.country)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                }

                Text(rec.reason)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.textSecondary)

                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.caption2)
                    Text("Eco Score: \(rec.ecoScore)/100")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Theme.sage)
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DeepTravelAnalysisView()
}
