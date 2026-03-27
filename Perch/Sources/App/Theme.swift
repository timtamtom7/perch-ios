import SwiftUI

struct Theme {
    // MARK: - Brand Colors
    static let background = Color(hex: "0f0e0d")
    static let surface = Color(hex: "1a1816")
    static let surfaceElevated = Color(hex: "242120")
    static let terracotta = Color(hex: "e07b39")
    static let sage = Color(hex: "7c9a6e")
    static let textPrimary = Color(hex: "f0ebe4")
    static let textSecondary = Color(hex: "8a7f74")
    static let textTertiary = Color(hex: "4a4540")
    static let textQuaternary = Color(hex: "2e2a26")
    static let co2Neutral = Color(hex: "9ca3af")

    // MARK: - Background Depth Levels (R1: Background surface hierarchy)
    /// Level 0 — Deepest background (root view)
    static let backgroundBase = Color(hex: "0a0908")
    /// Level 1 — Primary background (most surfaces)
    static let backgroundLevel1 = Color(hex: "0f0e0d")
    /// Level 2 — Elevated surfaces (cards, sheets)
    static let backgroundLevel2 = Color(hex: "1a1816")
    /// Level 3 — Highest elevated surfaces (modals, popovers)
    static let backgroundLevel3 = Color(hex: "242120")
    /// Level 4 — Overlay surfaces (selected states)
    static let backgroundLevel4 = Color(hex: "2e2a26")

    // MARK: - Semantic Colors
    static let cardBackground = surface
    static let divider = Color(hex: "2a2623")
    static let separator = Color(hex: "2a2623")
    static let pinColor = terracotta

    // MARK: - Corner Radius Tokens (R2: Unified corner radius system)
    /// 6pt — Smallest interactive elements (badges, pills)
    static let cornerRadiusPill: CGFloat = 6
    /// 8pt — Small components (buttons, small cards)
    static let cornerRadiusSmall: CGFloat = 8
    /// 12pt — Medium components (cards, sheets)
    static let cornerRadiusMedium: CGFloat = 12
    /// 16pt — Large components (major cards, modals)
    static let cornerRadiusLarge: CGFloat = 16
    /// 20pt — Extra large (hero cards, splash elements)
    static let cornerRadiusXLarge: CGFloat = 20

    // MARK: - Haptic Feedback (R3: Consistent haptic system)
    /// Light impact — subtle UI feedback (toggles, selections)
    static func haptic(_ style: HapticStyle = .light) {
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    enum HapticStyle {
        case light, medium, heavy, selection, success, warning, error
    }

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacingXXL: CGFloat = 24
}

// MARK: - Perch Primary Button Style

struct PerchButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(isPrimary ? Theme.background : Theme.terracotta)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isPrimary ? Theme.terracotta : Color.clear)
            .cornerRadius(Theme.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(Theme.terracotta, lineWidth: isPrimary ? 0 : 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Perch Secondary Button Style (AxiomSecondaryButtonStyle equivalent)

struct PerchSecondaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(isDestructive ? Color(hex: "ef4444") : Theme.terracotta)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isDestructive
                    ? Color(hex: "ef4444").opacity(0.12)
                    : Theme.terracotta.opacity(0.12)
            )
            .cornerRadius(Theme.cornerRadiusSmall)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Perch Tertiary Button Style (text-only buttons)

struct PerchTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Theme.textSecondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.clear)
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Perch Card Style Modifier

struct PerchCardStyle: ViewModifier {
    var cornerRadius: CGFloat = Theme.cornerRadiusLarge
    var backgroundColor: Color = Theme.cardBackground
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func perchCard(
        cornerRadius: CGFloat = Theme.cornerRadiusLarge,
        backgroundColor: Color = Theme.cardBackground,
        padding: CGFloat = 16
    ) -> some View {
        modifier(PerchCardStyle(cornerRadius: cornerRadius, backgroundColor: backgroundColor, padding: padding))
    }
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
