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
    static let textTertiary = Color(hex: "4a4540")
    static let co2Neutral = Color(hex: "9ca3af")

    // Semantic colors
    static let cardBackground = surface
    static let divider = Color(hex: "2a2623")
    static let pinColor = terracotta

    // Extended palette (replaces hardcoded hex values)
    static let amber = Color(hex: "f59e0b")
    static let gold = Color(hex: "c9a84c")
    static let red = Color(hex: "ef4444")
    static let darkRed = Color(hex: "b91c1c")
    static let blue = Color(hex: "60a5fa")
    static let lime = Color(hex: "84cc16")
    static let bronze = Color(hex: "b45309")
    static let yellow = Color(hex: "fbbf24")
    static let graySecondary = Color(hex: "9ca3af")
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
            .cornerRadius(Theme.CornerRadius.xl)
    }
}

// MARK: - Corner Radius Scale

extension Theme {
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 24
    }
}

// MARK: - Spacing Scale

extension Theme {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 10
        static let md: CGFloat = 12
        static let base: CGFloat = 14
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
}

extension View {
    func perchCard() -> some View {
        modifier(PerchCardStyle())
    }
}

// MARK: - Cached DateFormatters

/// Thread-safe, lazily-initialized DateFormatter instances.
/// Creating DateFormatter is expensive — always use these shared instances.
enum DateFormatters {
    private static nonisolated(unsafe) var _shortMonthDay: DateFormatter?
    private static nonisolated(unsafe) var _monthYear: DateFormatter?
    private static nonisolated(unsafe) var _fullDate: DateFormatter?
    private static nonisolated(unsafe) var _dayOfWeek: DateFormatter?

    static var shortMonthDay: DateFormatter {
        if let f = _shortMonthDay { return f }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        _shortMonthDay = f
        return f
    }

    static var monthYear: DateFormatter {
        if let f = _monthYear { return f }
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        _monthYear = f
        return f
    }

    static var fullDate: DateFormatter {
        if let f = _fullDate { return f }
        let f = DateFormatter()
        f.dateStyle = .medium
        _fullDate = f
        return f
    }

    static var dayOfWeek: DateFormatter {
        if let f = _dayOfWeek { return f }
        let f = DateFormatter()
        f.dateFormat = "EEE"
        _dayOfWeek = f
        return f
    }
}

// MARK: - Safe Array Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
