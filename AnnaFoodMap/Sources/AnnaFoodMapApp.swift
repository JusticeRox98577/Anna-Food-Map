import SwiftUI
import SwiftData

@main
struct AnnaFoodMapApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([DiaryEntry.self, ReintroTest.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .defaultSize(width: 980, height: 700)
        #endif
    }
}
