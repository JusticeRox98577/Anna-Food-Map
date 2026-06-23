import Foundation
import SwiftData

enum ReintroGroup: String, Codable, CaseIterable, Identifiable {
    case fructans = "Fructans (wheat, garlic, onion)"
    case lactose = "Lactose (dairy)"
    case fructose = "Fructose (honey, apple)"
    case galactans = "Galactans / GOS (legumes)"
    case mannitol = "Mannitol (mushrooms, cauliflower)"
    case sorbitol = "Sorbitol (stone fruits)"
    case other = "Other"

    var id: String { rawValue }
}

enum ReintroResult: String, Codable, CaseIterable, Identifiable {
    case pending, pass, fail
    var id: String { rawValue }

    var label: String {
        switch self {
        case .pending: return "Testing"
        case .pass: return "Tolerated"
        case .fail: return "Triggered"
        }
    }
}

@Model
final class ReintroTest {
    var id: UUID
    var groupRaw: String
    var food: String
    var date: Date
    var resultRaw: String
    var notes: String

    init(
        id: UUID = UUID(),
        group: ReintroGroup,
        food: String,
        date: Date,
        result: ReintroResult,
        notes: String
    ) {
        self.id = id
        self.groupRaw = group.rawValue
        self.food = food
        self.date = date
        self.resultRaw = result.rawValue
        self.notes = notes
    }

    var group: ReintroGroup {
        get { ReintroGroup(rawValue: groupRaw) ?? .other }
        set { groupRaw = newValue.rawValue }
    }

    var result: ReintroResult {
        get { ReintroResult(rawValue: resultRaw) ?? .pending }
        set { resultRaw = newValue.rawValue }
    }
}
