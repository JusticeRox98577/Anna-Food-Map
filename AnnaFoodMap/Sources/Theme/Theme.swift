import SwiftUI

enum Theme {
    static let green50 = Color(red: 0.945, green: 0.976, blue: 0.953)
    static let green100 = Color(red: 0.863, green: 0.937, blue: 0.882)
    static let green200 = Color(red: 0.722, green: 0.875, blue: 0.769)
    static let green300 = Color(red: 0.557, green: 0.804, blue: 0.639)
    static let green400 = Color(red: 0.373, green: 0.718, blue: 0.506)
    static let green500 = Color(red: 0.227, green: 0.616, blue: 0.388)
    static let green600 = Color(red: 0.173, green: 0.494, blue: 0.306)
    static let green700 = Color(red: 0.141, green: 0.392, blue: 0.247)
    static let green800 = Color(red: 0.114, green: 0.314, blue: 0.200)

    static let amber100 = Color(red: 1.0, green: 0.953, blue: 0.839)
    static let amber400 = Color(red: 0.961, green: 0.725, blue: 0.259)
    static let amber600 = Color(red: 0.788, green: 0.541, blue: 0.078)

    static let red100 = Color(red: 0.992, green: 0.886, blue: 0.882)
    static let red400 = Color(red: 0.937, green: 0.420, blue: 0.388)
    static let red600 = Color(red: 0.769, green: 0.239, blue: 0.208)

    static let ink900 = Color(red: 0.110, green: 0.149, blue: 0.133)
    static let ink700 = Color(red: 0.235, green: 0.290, blue: 0.267)
    static let ink500 = Color(red: 0.392, green: 0.439, blue: 0.412)
    static let ink300 = Color(red: 0.604, green: 0.651, blue: 0.627)

    static let paper = Color.white
    static let bg = Color(red: 0.965, green: 0.980, blue: 0.969)

    static let headerGradient = LinearGradient(
        colors: [green600, green500],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardRadius: CGFloat = 18
    static let chipRadius: CGFloat = 999
}

extension FODMAPLight {
    var color: Color {
        switch self {
        case .green: return Theme.green500
        case .yellow: return Theme.amber400
        case .red: return Theme.red400
        }
    }

    var badgeBackground: Color {
        switch self {
        case .green: return Theme.green100
        case .yellow: return Theme.amber100
        case .red: return Theme.red100
        }
    }

    var badgeForeground: Color {
        switch self {
        case .green: return Theme.green700
        case .yellow: return Theme.amber600
        case .red: return Theme.red600
        }
    }

    var label: String {
        switch self {
        case .green: return "Low FODMAP"
        case .yellow: return "Moderate"
        case .red: return "High FODMAP"
        }
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.paper)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
            .shadow(color: Theme.ink900.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
    }
}

struct PageHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 26, weight: .heavy))
            .foregroundStyle(Theme.ink900)
    }
}
