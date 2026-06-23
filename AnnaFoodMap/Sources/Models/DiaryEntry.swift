import Foundation
import SwiftData

enum EntryType: String, Codable, CaseIterable, Identifiable {
    case meal, symptom
    var id: String { rawValue }
    var label: String { self == .meal ? "Meal / Food" : "Symptom only" }
}

enum Severity: Int, Codable, CaseIterable, Identifiable {
    case none = 0, mild = 1, severe = 2
    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .none: return "🙂"
        case .mild: return "😐"
        case .severe: return "😣"
        }
    }

    var label: String {
        switch self {
        case .none: return "None"
        case .mild: return "Mild"
        case .severe: return "Severe"
        }
    }
}

@Model
final class DiaryEntry {
    var id: UUID
    var typeRaw: String
    var date: Date
    var title: String
    var severityRaw: Int
    var notes: String

    init(
        id: UUID = UUID(),
        type: EntryType,
        date: Date,
        title: String,
        severity: Severity,
        notes: String
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.date = date
        self.title = title
        self.severityRaw = severity.rawValue
        self.notes = notes
    }

    var type: EntryType {
        get { EntryType(rawValue: typeRaw) ?? .meal }
        set { typeRaw = newValue.rawValue }
    }

    var severity: Severity {
        get { Severity(rawValue: severityRaw) ?? .none }
        set { severityRaw = newValue.rawValue }
    }

    var day: Date {
        Calendar.current.startOfDay(for: date)
    }
}
