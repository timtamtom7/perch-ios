import SwiftUI

struct Theme {
    // Brand colors
    static let background = Color(hex: "0f0e0d")
    static let surface = Color(hex: "1a1816")
    static let surfaceElevated = Color(hex: "242120")
    static let terracotta = Color(hex: "e07b39")
    static let sage = Color(hex: "7c9a6e")
    static let textPrimary = Color(hex: "f0ebe4")
    static let textSecondary = Color(hex: "8a7f74")
    static let co2Neutral = Color(hex: "9ca3af")

    // Semantic colors
    static let cardBackground = surface
    static let divider = Color(hex: "2a2623")
    static let pinColor = terracotta
}

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

struct PerchButtonStyle: ButtonStyle {
    var isPrimary: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(isPrimary ? Theme.background : Theme.terracotta)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isPrimary ? Theme.terracotta : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.terracotta, lineWidth: isPrimary ? 0 : 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PerchCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.cardBackground)
            .cornerRadius(16)
    }
}

extension View {
    func perchCard() -> some View {
        modifier(PerchCardStyle())
    }
}
