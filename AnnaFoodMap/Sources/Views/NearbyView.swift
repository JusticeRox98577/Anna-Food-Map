import SwiftUI
import CoreLocation

private enum SearchMode: String, CaseIterable, Identifiable {
    case cuisine = "Cuisine"
    case category = "Food Category"
    case custom = "Search"
    var id: String { rawValue }
}

struct NearbyView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var searchManager = RestaurantSearchManager()

    @State private var mode: SearchMode = .cuisine
    @State private var selectedCuisine: Cuisine = .american
    @State private var selectedCategory: FoodCategory = .proteins
    @State private var customQuery = ""
    @State private var selectedRestaurant: NearbyRestaurant?
    @State private var locationErrorMessage: String?
    @State private var hasSearchedOnce = false

    private var activeTips: [String] {
        mode == .cuisine ? selectedCuisine.fodmapTips : []
    }

    private var searchTerm: String {
        switch mode {
        case .cuisine: return selectedCuisine.searchTerm
        case .category: return selectedCategory.restaurantSearchTerm
        case .custom: return customQuery
        }
    }

    private var tipsTitle: String {
        "Ordering tips for \(selectedCuisine.rawValue)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PageHeader(title: "Nearby Restaurants")
                Text("Find restaurants within 20 miles and get FODMAP-friendly ordering tips.")
                    .font(.system(size: 13.5))
                    .foregroundStyle(Theme.ink500)

                modePicker
                modeContent
                searchButton

                if let locationErrorMessage {
                    messageCard(locationErrorMessage, symbol: "location.slash")
                }
                if let error = searchManager.errorMessage {
                    messageCard(error, symbol: "exclamationmark.triangle")
                }
                if !activeTips.isEmpty {
                    tipsCard
                }

                if searchManager.isSearching {
                    ProgressView("Searching nearby...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                } else if !searchManager.results.isEmpty {
                    resultsList
                } else if hasSearchedOnce {
                    EmptyView()
                }
            }
            .padding(16)
        }
        .background(Theme.bg)
        .navigationTitle("Nearby")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $selectedRestaurant) { restaurant in
            RestaurantDetailSheet(restaurant: restaurant, cuisineTips: activeTips)
        }
    }

    private var modePicker: some View {
        Picker("Search by", selection: $mode) {
            ForEach(SearchMode.allCases) { m in
                Text(m.rawValue).tag(m)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var modeContent: some View {
        switch mode {
        case .cuisine:
            Picker("Cuisine", selection: $selectedCuisine) {
                ForEach(Cuisine.allCases) { c in
                    Text(c.rawValue).tag(c)
                }
            }
            .pickerStyle(.menu)
            .tint(Theme.green600)
        case .category:
            Picker("Food Category", selection: $selectedCategory) {
                ForEach(FoodCategory.allCases) { c in
                    Text(c.rawValue).tag(c)
                }
            }
            .pickerStyle(.menu)
            .tint(Theme.green600)
        case .custom:
            VStack(alignment: .leading, spacing: 4) {
                TextField("e.g. \"something with raw fish\", \"a juicy burger\"", text: $customQuery)
                    #if os(iOS)
                    .textFieldStyle(.roundedBorder)
                    #endif
                if FoodQueryInterpreter.isAvailable {
                    Label("Interpreted on-device by Apple Intelligence", systemImage: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.ink500)
                }
            }
        }
    }

    private var searchButton: some View {
        Button {
            Task { await performSearch() }
        } label: {
            Label("Find Nearby Restaurants", systemImage: "location.magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.green600)
        .disabled(mode == .custom && customQuery.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    private func performSearch() async {
        locationErrorMessage = nil
        hasSearchedOnce = true
        do {
            let location = try await locationManager.requestLocation()
            let term: String
            if mode == .custom {
                term = await FoodQueryInterpreter.interpret(customQuery)
            } else {
                term = searchTerm
            }
            await searchManager.search(query: term, near: location)
        } catch {
            locationErrorMessage = error.localizedDescription
        }
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(tipsTitle, systemImage: "lightbulb.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.amber600)
            ForEach(activeTips, id: \.self) { tip in
                Text("• \(tip)")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink700)
            }
        }
        .padding(14)
        .background(Theme.green50)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.green100, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func messageCard(_ text: String, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol).foregroundStyle(Theme.red600)
            Text(text).font(.system(size: 13)).foregroundStyle(Theme.ink700)
        }
        .padding(14)
        .background(Theme.red100.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var resultsList: some View {
        LazyVStack(spacing: 10) {
            ForEach(searchManager.results) { restaurant in
                RestaurantRow(restaurant: restaurant)
                    .onTapGesture { selectedRestaurant = restaurant }
            }
        }
    }
}

struct RestaurantRow: View {
    let restaurant: NearbyRestaurant

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Theme.green500)
            VStack(alignment: .leading, spacing: 2) {
                Text(restaurant.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.ink900)
                if !restaurant.address.isEmpty {
                    Text(restaurant.address)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.ink500)
                }
            }
            Spacer()
            Text(String(format: "%.1f mi", restaurant.distanceMiles))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.green700)
        }
        .padding(12)
        .cardStyle()
        .contentShape(Rectangle())
    }
}

struct RestaurantDetailSheet: View {
    let restaurant: NearbyRestaurant
    let cuisineTips: [String]
    @Environment(\.dismiss) private var dismiss

    @State private var isScanning = false
    @State private var menuMatches: [MenuMatch] = []
    @State private var triggerWords: [String] = []
    @State private var scanAttempted = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.ink900)
                        if !restaurant.address.isEmpty {
                            Text(restaurant.address)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.ink500)
                        }
                        Text(String(format: "%.1f miles away", restaurant.distanceMiles))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.green700)
                    }

                    actionButtons

                    if !cuisineTips.isEmpty {
                        detailSection(title: "Ordering Tips", content: AnyView(
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(cuisineTips, id: \.self) { tip in
                                    Text("• \(tip)")
                                        .font(.system(size: 13.5))
                                        .foregroundStyle(Theme.ink700)
                                }
                            }
                        ))
                    }

                    detailSection(title: "Menu Scan", content: AnyView(menuSection))
                }
                .padding(20)
            }
            .background(Theme.bg)
            .navigationTitle("Restaurant")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .readableNavigationBar()
            .task {
                await scanMenuIfPossible()
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 520)
        #endif
    }

    private func detailSection(title: String, content: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.ink500)
            content
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if let phone = restaurant.phoneNumber, let telURL = URL(string: "tel:\(phone.filter { $0.isNumber })") {
                Link(destination: telURL) {
                    Label("Call", systemImage: "phone.fill")
                }
                .buttonStyle(.bordered)
            }
            if let url = restaurant.url {
                Link(destination: url) {
                    Label("Website", systemImage: "globe")
                }
                .buttonStyle(.bordered)
            }
        }
        .tint(Theme.green600)
    }

    @ViewBuilder
    private var menuSection: some View {
        if restaurant.url == nil {
            Text("No website on file for this restaurant, so we couldn't scan their menu. Call ahead to ask about FODMAP-friendly options.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.ink700)
        } else if isScanning {
            HStack(spacing: 8) {
                ProgressView()
                Text("Scanning their website for menu info...")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink500)
            }
        } else if scanAttempted {
            if menuMatches.isEmpty && triggerWords.isEmpty {
                Text("We couldn't find specific menu items automatically — many restaurant sites load menus dynamically or as images/PDFs. Call or check their website directly.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.ink700)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if !menuMatches.isEmpty {
                        Text("Foods mentioned on their site:")
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Theme.ink700)
                        ForEach(menuMatches) { match in
                            HStack(spacing: 8) {
                                Circle().fill(match.food.light.color).frame(width: 10, height: 10)
                                Text(match.food.name)
                                    .font(.system(size: 13.5))
                                    .foregroundStyle(Theme.ink900)
                                Spacer()
                                Text(match.food.light.label)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.ink500)
                            }
                        }
                    }
                    if !triggerWords.isEmpty {
                        Text("Possible high-FODMAP ingredients mentioned: \(triggerWords.joined(separator: ", "))")
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.red600)
                    }
                }
            }
            Text("Automated scan — always confirm with the restaurant before ordering.")
                .font(.system(size: 11))
                .foregroundStyle(Theme.ink300)
                .padding(.top, 4)
        }
    }

    private func scanMenuIfPossible() async {
        guard let url = restaurant.url else { return }
        isScanning = true
        if let scan = await MenuScanner.scan(url: url) {
            menuMatches = scan.matches
            triggerWords = scan.triggerWords
        }
        isScanning = false
        scanAttempted = true
    }
}
