import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingScreen1()
                        .tag(0)

                    OnboardingScreen2()
                        .tag(1)

                    OnboardingScreen3()
                        .tag(2)

                    OnboardingScreen4()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Page indicator + CTA
                VStack(spacing: 24) {
                    PageIndicator(currentPage: currentPage, totalPages: 4)

                    if currentPage < 3 {
                        Button {
                            withAnimation { currentPage += 1 }
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(PerchButtonStyle())
                    } else {
                        Button {
                            hasCompletedOnboarding = true
                            dismiss()
                        } label: {
                            Text("Start Exploring")
                        }
                        .buttonStyle(PerchButtonStyle())
                    }

                    if currentPage > 0 {
                        Button {
                            withAnimation { currentPage -= 1 }
                        } label: {
                            Text("Back")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textSecondary)
                        }
                    } else {
                        Button {
                            hasCompletedOnboarding = true
                            dismiss()
                        } label: {
                            Text("Skip")
                                .font(.system(size: 15))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Screen 1: Know where you've been

struct OnboardingScreen1: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Abstract world map composition
            ZStack {
                // Globe arc
                Circle()
                    .trim(from: 0.3, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.terracotta.opacity(0.3), Theme.terracotta, Theme.terracotta.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 240, height: 240)

                // Latitude lines
                ForEach(0..<5, id: \.self) { i in
                    let offset = CGFloat(i - 2) * 28
                    Ellipse()
                        .trim(from: 0.25, to: 0.75)
                        .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 0.8)
                        .frame(width: 160, height: 80)
                        .offset(y: offset)
                }

                // Longitude lines
                ForEach(0..<3, id: \.self) { i in
                    let offset = CGFloat(i - 1) * 50
                    Ellipse()
                        .trim(from: 0.3, to: 0.7)
                        .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 0.8)
                        .frame(width: 80, height: 200)
                        .rotationEffect(.degrees(80))
                        .offset(x: offset)
                }

                // Map pins on the "globe"
                let pins: [(CGFloat, CGFloat)] = [
                    (-40, -30), (20, -60), (60, -10),
                    (80, 40), (-20, 60), (-70, 10),
                    (0, -80), (50, 80)
                ]
                ForEach(0..<pins.count, id: \.self) { i in
                    let pin = pins[i]
                    MapPinGraphic(size: 12, opacity: Double(i) * 0.1 + 0.4)
                        .offset(x: pin.0, y: pin.1)
                }

                // Center pin (larger, accent)
                MapPinGraphic(size: 18, opacity: 1.0)
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Know where you've been")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Perch quietly builds your personal travel atlas — every city, every country, every journey you've taken.")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Screen 2: Just start a trip

struct OnboardingScreen2: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Passive tracking visualization
            ZStack {
                // Background glow
                Circle()
                    .fill(Theme.terracotta.opacity(0.08))
                    .frame(width: 260, height: 260)

                // Radar rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Theme.terracotta.opacity(0.15 + Double(i) * 0.05), lineWidth: 1)
                        .frame(width: CGFloat(100 + i * 60), height: CGFloat(100 + i * 60))
                }

                // Phone icon at center
                VStack(spacing: 6) {
                    Image(systemName: "iphone")
                        .font(.system(size: 44))
                        .foregroundColor(Theme.terracotta)

                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.sage)
                }

                // Dashed orbit rings
                Circle()
                    .trim(from: 0, to: 0.35)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .foregroundColor(Theme.terracotta.opacity(0.5))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(30))

                Circle()
                    .trim(from: 0.5, to: 0.85)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .foregroundColor(Theme.terracotta.opacity(0.4))
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-20))
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Just start a trip")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Tap start, close the app, live your trip. Perch runs in the background — no check-ins, no effort. It just remembers where you went.")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Screen 3: See your year

struct OnboardingScreen3: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Year visualization — abstract trip timeline
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: Theme.cornerRadiusXLarge)
                    .fill(Theme.surface)
                    .frame(width: 300, height: 200)

                // Month grid
                HStack(spacing: 4) {
                    ForEach(1...12, id: \.self) { month in
                        VStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(monthColor(for: month))
                                .frame(width: 18, height: CGFloat(heightForMonth(month)))
                            Text(monthLabel(month))
                                .font(.caption2)
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Cities list below
                VStack(spacing: 6) {
                    Divider().background(Theme.divider)
                    HStack {
                        ForEach(sampleCities, id: \.self) { city in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Theme.terracotta)
                                    .frame(width: 5, height: 5)
                                Text(city)
                                    .font(.system(size: 11))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Year summary overlay
                VStack(spacing: 4) {
                    Text("2026")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.textPrimary.opacity(0.15))
                    Text("Your travel year")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary.opacity(0.6))
                }
            }

            Spacer()

            VStack(spacing: 16) {
                Text("See your year")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("At year's end, your complete travel history — countries visited, cities explored, distance traveled, and your footprint along the way.")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 60)
        }
    }

    private let sampleCities = ["Tokyo", "Paris", "NYC", "Lisbon", "Cape Town"]

    private func monthColor(for month: Int) -> Color {
        let activeMonths = [1, 2, 3, 4, 7, 8, 9, 11]
        return activeMonths.contains(month) ? Theme.terracotta : Theme.textSecondary.opacity(0.15)
    }

    private func heightForMonth(_ month: Int) -> Int {
        let heights = [60, 40, 90, 30, 70, 20, 80, 100, 50, 20, 60, 30]
        return heights[month - 1]
    }

    private func monthLabel(_ month: Int) -> String {
        let labels = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
        return labels[month - 1]
    }
}

// MARK: - Screen 4: Start exploring

struct OnboardingScreen4: View {
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Location permission visualization
            ZStack {
                // Compass rose
                CompassGraphic()

                // Permission icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Theme.terracotta.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Theme.terracotta)
                    }

                    Text("Location access needed")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textPrimary)

                    Text("Perch needs location access to record the cities you visit during trips. It only tracks when a trip is active.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Start exploring")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Your location data never leaves your phone. Perch is built for privacy — nothing is collected, shared, or uploaded.")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Privacy badges
                HStack(spacing: 12) {
                    PrivacyBadge(icon: "lock.fill", text: "On-device only")
                    PrivacyBadge(icon: "icloud.slash", text: "No cloud sync")
                    PrivacyBadge(icon: "trash", text: "You own your data")
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
    }
}

struct PrivacyBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(Theme.sage)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Theme.sage.opacity(0.15))
        .cornerRadius(Theme.cornerRadiusXLarge)
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Theme.terracotta : Theme.textSecondary.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 7, height: index == currentPage ? 10 : 7)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

// MARK: - Compass Graphic

struct CompassGraphic: View {
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Theme.textSecondary.opacity(0.2), lineWidth: 1)
                .frame(width: 260, height: 260)

            // Tick marks
            ForEach(0..<36, id: \.self) { tick in
                let isMajor = tick % 9 == 0
                Rectangle()
                    .fill(isMajor ? Theme.terracotta.opacity(0.6) : Theme.textSecondary.opacity(0.2))
                    .frame(width: isMajor ? 2 : 1, height: isMajor ? 12 : 6)
                    .offset(y: -120)
                    .rotationEffect(.degrees(Double(tick) * 10))
            }

            // Cardinal directions
            CompassDirection(dir: "N", angle: 0)
            CompassDirection(dir: "E", angle: 90)
            CompassDirection(dir: "S", angle: 180)
            CompassDirection(dir: "W", angle: 270)

            // Inner compass needle
            ZStack {
                Circle()
                    .fill(Theme.surface)
                    .frame(width: 60, height: 60)

                // North pointer
                Path { path in
                    path.move(to: CGPoint(x: 0, y: -22))
                    path.addLine(to: CGPoint(x: 8, y: 0))
                    path.addLine(to: CGPoint(x: -8, y: 0))
                    path.closeSubpath()
                }
                .fill(Theme.terracotta)
                .offset(y: -4)

                // South pointer
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 22))
                    path.addLine(to: CGPoint(x: 8, y: 0))
                    path.addLine(to: CGPoint(x: -8, y: 0))
                    path.closeSubpath()
                }
                .fill(Theme.textSecondary.opacity(0.4))
                .offset(y: 4)

                Circle()
                    .fill(Theme.terracotta)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Map Pin Graphic

struct MapPinGraphic: View {
    let size: CGFloat
    let opacity: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.terracotta.opacity(opacity))
                .frame(width: size, height: size)

            Circle()
                .stroke(Color.white.opacity(0.4), lineWidth: size > 10 ? 1.5 : 1)
                .frame(width: size, height: size)

            if size > 10 {
                Circle()
                    .fill(Theme.terracotta)
                    .frame(width: size * 0.4, height: size * 0.4)
                    .offset(y: -size * 0.1)
            }
        }
    }
}

struct CompassDirection: View {
    let dir: String
    let angle: Double

    var body: some View {
        Text(dir)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(dir == "N" ? Theme.terracotta : Theme.textSecondary)
            .offset(y: -100)
            .rotationEffect(.degrees(angle))
    }
}
