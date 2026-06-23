import SwiftUI
import SwiftData
#if os(iOS)
import UIKit
#endif

@main
struct AnnaFoodMapApp: App {
    @StateObject private var favorites = FavoritesStore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([DiaryEntry.self, ReintroTest.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        #if os(iOS)
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Theme.ink900)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.ink900)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favorites)
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .defaultSize(width: 980, height: 700)
        #endif
    }
}
