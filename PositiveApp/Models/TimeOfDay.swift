import SwiftUI

enum TimeOfDay: CaseIterable {
    case morning    // 6am – 12pm
    case afternoon  // 12pm – 6pm
    case evening    // 6pm – 9pm
    case night      // 9pm – 6am

    // MARK: - Current time detection
    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:  return .morning
        case 12..<18: return .afternoon
        case 18..<21: return .evening
        default:      return .night
        }
    }

    // MARK: - Text
    var greeting: String {
        switch self {
        case .morning:   return "Good Morning"
        case .afternoon: return "Good Afternoon"
        case .evening:   return "Good Evening"
        case .night:     return "Good Night"
        }
    }

    var emoji: String {
        switch self {
        case .morning:   return "☀️"
        case .afternoon: return "⛅"
        case .evening:   return "🌇"
        case .night:     return "🌙"
        }
    }

    var subtitle: String { "You're doing better than you think" }

    // MARK: - Colours
    var backgroundGradient: [Color] {
        switch self {
        case .morning:
            return [Color(hex: "FF9A3C"), Color(hex: "FFCB80"), Color(hex: "FFF0CC")]
        case .afternoon:
            return [Color(hex: "4BA3C7"), Color(hex: "87CEEB"), Color(hex: "C9E8F5")]
        case .evening:
            return [Color(hex: "C9485B"), Color(hex: "E8835A"), Color(hex: "EECDA3")]
        case .night:
            return [Color(hex: "0D1B2A"), Color(hex: "1E2F50"), Color(hex: "2C3E6B")]
        }
    }

    var headingColor: Color {
        switch self {
        case .morning:   return Color(hex: "8B4513")
        case .afternoon: return Color(hex: "1A4A7A")
        case .evening:   return Color(hex: "6B1D3A")
        case .night:     return .white
        }
    }

    var subtitleColor: Color { headingColor.opacity(0.7) }

    var cardBackground: Color {
        switch self {
        case .morning:   return Color(hex: "FFF8F0")
        case .afternoon: return Color(hex: "EEF2FF")   // soft lavender
        case .evening:   return Color(hex: "FFF0F5")
        case .night:     return Color(hex: "1A2A4A")
        }
    }

    var cardTextColor: Color {
        switch self {
        case .night: return .white
        default:     return headingColor
        }
    }

    /// Coral/gold accent used for swipe hint & pill button
    var accentColor: Color {
        switch self {
        case .morning:   return Color(hex: "E8622A")
        case .afternoon: return Color(hex: "E07050")
        case .evening:   return Color(hex: "C8A020")
        case .night:     return Color(hex: "9B7FD4")
        }
    }

    var pillGradient: [Color] {
        switch self {
        case .morning:   return [Color(hex: "FF9A3C"), Color(hex: "FF6B35")]
        case .afternoon: return [Color(hex: "7B9EE8"), Color(hex: "4B7AC7")]
        case .evening:   return [Color(hex: "E8835A"), Color(hex: "C9485B")]
        case .night:     return [Color(hex: "9B7FD4"), Color(hex: "6B4FA4")]
        }
    }

    var reminderBackground: Color {
        switch self {
        case .morning:   return Color(hex: "FFF3E0")
        case .afternoon: return Color(hex: "FFFDE7")
        case .evening:   return Color(hex: "FCE4EC")
        case .night:     return Color(hex: "1A2A3A")
        }
    }

    var jokeBackground: Color {
        switch self {
        case .morning:   return Color(hex: "E8F5E9")
        case .afternoon: return Color(hex: "F1F8E9")
        case .evening:   return Color(hex: "EDE7F6")
        case .night:     return Color(hex: "0D2A1A")
        }
    }
}
