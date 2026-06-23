import SwiftUI
import Foundation

struct ReferenceView: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    @State private var selectedCategory: FoodCategory?
    @State private var selectedFood: Food?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tap a category to see Low FODMAP picks at a glance.")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.ink500)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(FoodCategory.allCases) { category in
                        CategoryCard(category: category, count: safeCount(for: category))
                            .onTapGesture { selectedCategory = category }
                    }
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Safe Foods Quick Reference")
        .sheet(item: $selectedCategory) { category in
            CategorySafeFoodsSheet(category: category, onSelect: { food in
                selectedCategory = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    selectedFood = food
                }
            })
        }
        .sheet(item: $selectedFood) { food in
            FoodDetailSheet(food: food)
        }
    }

    private func safeCount(for category: FoodCategory) -> Int {
        FoodDatabase.all.filter { $0.category == category && $0.light == .green }.count
    }
}

struct CategoryCard: View {
    let category: FoodCategory
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.symbolName)
                .font(.system(size: 26))
                .foregroundStyle(Theme.green500)
            Text(category.rawValue)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Theme.ink900)
            Text("\(count) safe foods")
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.ink500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .cardStyle()
        .contentShape(Rectangle())
    }
}

struct CategorySafeFoodsSheet: View {
    let category: FoodCategory
    let onSelect: (Food) -> Void
    @Environment(\.dismiss) private var dismiss

    private var safeFoods: [Food] {
        FoodDatabase.all
            .filter { $0.category == category && $0.light == .green }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(safeFoods) { food in
                        HStack(spacing: 12) {
                            Circle().fill(Theme.green500).frame(width: 14, height: 14)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.ink900)
                                Text(food.note).font(.system(size: 12)).foregroundStyle(Theme.ink500)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .cardStyle()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                            onSelect(food)
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.bg)
            .navigationTitle("\(category.rawValue) — Safe Picks")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .readableNavigationBar()
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 480)
        #endif
    }
}
