import SwiftUI

/// R7: Deep Travel Analysis view - AI-powered insights and recommendations
struct DeepTravelAnalysisView: View {
    @StateObject private var analysisService = DeepTravelAnalysisService.shared
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "f8f6f2")
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
                            .foregroundColor(Color(hex: "2d7d46"))
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
                    .stroke(Color(hex: "2d7d46"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: analysisService.analysisProgress)

                Text("\(Int(analysisService.analysisProgress * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "1a1a1a"))
            }

            VStack(spacing: 6) {
                Text("Analyzing your travels…")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "1a1a1a"))

                Text("Discovering patterns and insights")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6b6b6b"))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "c0c0c0"))

            VStack(spacing: 6) {
                Text("No trips to analyze")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "1a1a1a"))

                Text("Start tracking your travels to\nuncover insights about your journeys.")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6b6b6b"))
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await analysisService.analyzeAll(trips: [])
                }
            } label: {
                Text("Analyze Now")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 44)
                    .background(Color(hex: "2d7d46"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
                .foregroundColor(Color(hex: "2d7d46"))
                .frame(width: 48, height: 48)
                .background(Color(hex: "2d7d46").opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "1a1a1a"))

                Text(pattern.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6b6b6b"))

                if pattern.co2Saved > 0 {
                    Text("~\(String(format: "%.0f", pattern.co2Saved)) kg CO2 saved")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "2d7d46"))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                .foregroundColor(Color(hex: "2d7d46"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "2d7d46").opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "6b6b6b"))

                Text(insight.value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "1a1a1a"))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: trendIcon(insight.trend))
                        .font(.system(size: 12))
                    Text(insight.comparison)
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "6b6b6b"))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(LinearGradient(colors: [Color(hex: "2d7d46"), Color(hex: "4a9d5e")], startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(rec.destination)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "1a1a1a"))

                    Text("•")
                        .foregroundColor(Color(hex: "c0c0c0"))

                    Text(rec.country)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "6b6b6b"))
                }

                Text(rec.reason)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "6b6b6b"))

                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                    Text("Eco Score: \(rec.ecoScore)/100")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Color(hex: "2d7d46"))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DeepTravelAnalysisView()
}
