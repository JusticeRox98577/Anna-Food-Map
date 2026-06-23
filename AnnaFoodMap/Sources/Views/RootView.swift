import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case foods, phase, nearby, diary, reintro, reference
    var id: String { rawValue }

    var title: String {
        switch self {
        case .foods: return "Foods"
        case .phase: return "Phase"
        case .nearby: return "Nearby"
        case .diary: return "Diary"
        case .reintro: return "Reintro"
        case .reference: return "Reference"
        }
    }

    var symbolName: String {
        switch self {
        case .foods: return "light.beacon.max.fill"
        case .phase: return "arrow.triangle.turn.up.right.diamond.fill"
        case .nearby: return "location.magnifyingglass"
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
        case .nearby: NearbyView()
        case .diary: DiaryView()
        case .reintro: ReintroView()
        case .reference: ReferenceView()
        }
    }
}

struct RootView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            } else {
                #if os(macOS)
                MacRootView()
                #else
                iOSRootView()
                #endif
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.4))
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = false
            }
        }
    }
}

private struct ReadableNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .toolbarColorScheme(.light, for: .navigationBar)
        #else
        content
        #endif
    }
}

extension View {
    func readableNavigationBar() -> some View {
        modifier(ReadableNavigationBar())
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
                        .readableNavigationBar()
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
