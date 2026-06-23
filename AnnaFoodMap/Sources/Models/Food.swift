import Foundation

enum FODMAPLight: String, Codable, CaseIterable, Identifiable {
    case green, yellow, red
    var id: String { rawValue }
}

enum FoodCategory: String, Codable, CaseIterable, Identifiable {
    case proteins = "Proteins"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case grains = "Grains"
    case dairy = "Dairy"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .proteins: return "fish.fill"
        case .vegetables: return "carrot.fill"
        case .fruits: return "leaf.fill"
        case .grains: return "tray.full.fill"
        case .dairy: return "drop.fill"
        }
    }
}

struct Food: Identifiable, Codable, Hashable {
    var id: String { name }
    let name: String
    let category: FoodCategory
    let light: FODMAPLight
    let note: String
}
