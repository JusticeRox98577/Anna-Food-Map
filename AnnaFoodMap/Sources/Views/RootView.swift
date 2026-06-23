import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case foods, phase, diary, reintro, reference
    var id: String { rawValue }

    var title: String {
        switch self {
        case .foods: return "Foods"
        case .phase: return "Phase"
        case .diary: return "Diary"
        case .reintro: return "Reintro"
        case .reference: return "Reference"
        }
    }

    var symbolName: String {
        switch self {
        case .foods: return "light.beacon.max.fill"
        case .phase: return "arrow.triangle.turn.up.right.diamond.fill"
        case .diary: return "book.closed.fill"
        case .reintro: return "testtube.2"
        case .reference: return "list.bullet.rectangle.fill"
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .foods: FoodsView()
        case .phase: PhaseView()
        case .diary: DiaryView()
        case .reintro: ReintroView()
        case .reference: ReferenceView()
        }
    }
}

struct RootView: View {
    var body: some View {
        #if os(macOS)
        MacRootView()
        #else
        iOSRootView()
        #endif
    }
}

#if os(macOS)
struct MacRootView: View {
    @State private var selection: AppSection? = .foods

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.symbolName)
                    .tag(section)
            }
            .navigationTitle("Low FODMAP Guide")
            .listStyle(.sidebar)
        } detail: {
            NavigationStack {
                (selection ?? .foods).destination
            }
        }
        .tint(Theme.green600)
    }
}
#else
struct iOSRootView: View {
    @State private var selection: AppSection = .foods

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppSection.allCases) { section in
                NavigationStack {
                    section.destination
                }
                .tabItem {
                    Label(section.title, systemImage: section.symbolName)
                }
                .tag(section)
            }
        }
        .tint(Theme.green600)
    }
}
#endif
