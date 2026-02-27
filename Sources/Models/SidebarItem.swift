import Foundation

enum SidebarItem: String, CaseIterable, Identifiable {
    case welcome
    case guide
    case camSetup
    case exercises

    var id: String { rawValue }

    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .guide:
            return "Guide"
        case .camSetup:
            return "Cam Setup"
        case .exercises:
            return "Exercises"
        }
    }

    var symbolName: String {
        switch self {
        case .welcome:
            return "house"
        case .guide:
            return "book.closed"
        case .camSetup:
            return "camera"
        case .exercises:
            return "figure.fencing"
        }
    }
}
