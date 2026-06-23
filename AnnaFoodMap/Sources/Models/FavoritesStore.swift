import Foundation
import Combine

@MainActor
final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteNames: Set<String>

    private static let defaultsKey = "fodmap.favoriteFoods"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? []
        favoriteNames = Set(saved)
    }

    func isFavorite(_ food: Food) -> Bool {
        favoriteNames.contains(food.name)
    }

    func toggle(_ food: Food) {
        if favoriteNames.contains(food.name) {
            favoriteNames.remove(food.name)
        } else {
            favoriteNames.insert(food.name)
        }
        UserDefaults.standard.set(Array(favoriteNames), forKey: Self.defaultsKey)
    }
}
