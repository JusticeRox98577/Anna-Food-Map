import SwiftUI

struct FoodsView: View {
    @State private var searchText = ""
    @State private var lightFilter: FODMAPLight? = nil
    @State private var categoryFilter: FoodCategory? = nil
    @State private var selectedFood: Food?

    private var filteredFoods: [Food] {
        FoodDatabase.all
            .filter { lightFilter == nil || $0.light == lightFilter }
            .filter { categoryFilter == nil || $0.category == categoryFilter }
            .filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                filterChips
                foodList
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Food Traffic Light")
        .searchable(text: $searchText, prompt: "Search foods (e.g. garlic, banana, oats)")
        .sheet(item: $selectedFood) { food in
            FoodDetailSheet(food: food)
        }
    }

    private var filterChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All Foods", isActive: lightFilter == nil) { lightFilter = nil }
                    ForEach(FODMAPLight.allCases) { light in
                        FilterChip(title: "\(emoji(for: light)) \(light.label)", isActive: lightFilter == light) {
                            lightFilter = (lightFilter == light) ? nil : light
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All Categories", isActive: categoryFilter == nil) { categoryFilter = nil }
                    ForEach(FoodCategory.allCases) { cat in
                        FilterChip(title: cat.rawValue, isActive: categoryFilter == cat) {
                            categoryFilter = (categoryFilter == cat) ? nil : cat
                        }
                    }
                }
            }
        }
    }

    private func emoji(for light: FODMAPLight) -> String {
        switch light {
        case .green: return "🟢"
        case .yellow: return "🟡"
        case .red: return "🔴"
        }
    }

    @ViewBuilder
    private var foodList: some View {
        if filteredFoods.isEmpty {
            EmptyStateView(symbolName: "magnifyingglass", message: "No foods match your search.")
                .padding(.top, 40)
        } else {
            LazyVStack(spacing: 10) {
                ForEach(filteredFoods) { food in
                    FoodRow(food: food)
                        .onTapGesture { selectedFood = food }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isActive ? Theme.green600 : Theme.paper)
                .foregroundStyle(isActive ? .white : Theme.ink700)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isActive ? Theme.green600 : Theme.green100, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct FoodRow: View {
    let food: Food

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(food.light.color)
                .frame(width: 14, height: 14)

            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink900)
                Text(food.category.rawValue)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.ink500)
            }

            Spacer()

            Text(food.light.label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(food.light.badgeBackground)
                .foregroundStyle(food.light.badgeForeground)
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Theme.paper)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Theme.green50, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(food.light.color)
                .frame(width: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.vertical, 6)
                .padding(.leading, 2)
        }
        .shadow(color: Theme.ink900.opacity(0.04), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}

struct FoodDetailSheet: View {
    let food: Food
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 10) {
                        Circle().fill(food.light.color).frame(width: 20, height: 20)
                        Text(food.light.label)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.ink900)
                    }

                    detailRow(title: "Category", value: food.category.rawValue)
                    detailRow(title: "Why", value: food.note)
                }
                .padding(20)
            }
            .navigationTitle(food.name)
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
        .frame(minWidth: 380, minHeight: 320)
        #endif
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.ink500)
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(Theme.ink900)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct EmptyStateView: View {
    let symbolName: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbolName)
                .font(.system(size: 34))
                .foregroundStyle(Theme.green200)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(Theme.ink500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}
