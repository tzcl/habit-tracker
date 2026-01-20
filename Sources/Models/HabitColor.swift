import SwiftUI

enum HabitColor: Int, CaseIterable {
    case coral = 0
    case amber = 1
    case lime = 2
    case teal = 3
    case sky = 4
    case indigo = 5
    case purple = 6
    case pink = 7

    /// The accent color used for segments and highlights
    var color: Color {
        switch self {
        case .coral:  Color(red: 255/255, green: 107/255, blue: 107/255)
        case .amber:  Color(red: 255/255, green: 171/255, blue: 94/255)
        case .lime:   Color(red: 126/255, green: 214/255, blue: 135/255)
        case .teal:   Color(red: 78/255,  green: 205/255, blue: 196/255)
        case .sky:    Color(red: 116/255, green: 185/255, blue: 255/255)
        case .indigo: Color(red: 124/255, green: 122/255, blue: 232/255)
        case .purple: Color(red: 179/255, green: 136/255, blue: 235/255)
        case .pink:   Color(red: 255/255, green: 143/255, blue: 177/255)
        }
    }

    /// A soft pastel background color that complements the accent
    var backgroundColor: Color {
        switch self {
        case .coral:  Color(red: 255/255, green: 235/255, blue: 235/255)
        case .amber:  Color(red: 255/255, green: 245/255, blue: 230/255)
        case .lime:   Color(red: 235/255, green: 250/255, blue: 238/255)
        case .teal:   Color(red: 230/255, green: 250/255, blue: 248/255)
        case .sky:    Color(red: 232/255, green: 244/255, blue: 255/255)
        case .indigo: Color(red: 238/255, green: 238/255, blue: 252/255)
        case .purple: Color(red: 245/255, green: 238/255, blue: 252/255)
        case .pink:   Color(red: 255/255, green: 238/255, blue: 244/255)
        }
    }

    var name: String {
        switch self {
        case .coral:  "Coral"
        case .amber:  "Amber"
        case .lime:   "Lime"
        case .teal:   "Teal"
        case .sky:    "Sky"
        case .indigo: "Indigo"
        case .purple: "Purple"
        case .pink:   "Pink"
        }
    }
}
