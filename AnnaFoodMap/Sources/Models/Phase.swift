import Foundation

enum Phase: Int, Codable, CaseIterable, Identifiable {
    case elimination = 0
    case reintroduction = 1
    case personalization = 2

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .elimination: return "Elimination"
        case .reintroduction: return "Reintroduction"
        case .personalization: return "Personalization"
        }
    }

    var symbolName: String {
        switch self {
        case .elimination: return "nosign"
        case .reintroduction: return "testtube.2"
        case .personalization: return "leaf.circle.fill"
        }
    }

    var summary: String {
        switch self {
        case .elimination:
            return "Strictly avoid high FODMAP foods for 2–6 weeks to calm symptoms and establish a baseline."
        case .reintroduction:
            return "Systematically reintroduce one FODMAP group at a time to identify your personal triggers."
        case .personalization:
            return "Build your long-term, personalized diet based on what you've learned about your tolerances."
        }
    }

    var tips: [String] {
        switch self {
        case .elimination:
            return [
                "Stick to green-light foods from the Foods tab",
                "Read labels for hidden onion, garlic & wheat",
                "Track every meal and symptom in your diary",
                "Typical duration: 2–6 weeks"
            ]
        case .reintroduction:
            return [
                "Test one FODMAP group every 3 days",
                "Start with a small portion, then increase",
                "Return to elimination diet between challenges",
                "Log every challenge in the Reintro tab"
            ]
        case .personalization:
            return [
                "Reintroduce well-tolerated foods permanently",
                "Keep confirmed triggers limited or avoided",
                "Re-test triggers periodically — tolerance can change",
                "Aim for the least restrictive diet that keeps you well"
            ]
        }
    }

    var next: Phase? { Phase(rawValue: rawValue + 1) }
    var previous: Phase? { Phase(rawValue: rawValue - 1) }
}
