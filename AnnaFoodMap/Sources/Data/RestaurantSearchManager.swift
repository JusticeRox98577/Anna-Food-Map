import Foundation
import CoreLocation
import MapKit

struct NearbyRestaurant: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let phoneNumber: String?
    let url: URL?
    let distanceMiles: Double
}

@MainActor
final class RestaurantSearchManager: ObservableObject {
    @Published private(set) var isSearching = false
    @Published private(set) var results: [NearbyRestaurant] = []
    @Published private(set) var errorMessage: String?

    private let maxRadiusMiles: Double = 20
    private let metersPerMile = 1609.34

    func search(query: String, near location: CLLocation) async {
        isSearching = true
        errorMessage = nil
        results = []

        let radiusMeters = maxRadiusMiles * metersPerMile
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusMeters * 2,
            longitudinalMeters: radiusMeters * 2
        )

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(query) restaurants"
        request.region = region
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant, .bakery, .cafe, .foodMarket])

        do {
            let response = try await MKLocalSearch(request: request).start()
            let mapped: [NearbyRestaurant] = response.mapItems.compactMap { item in
                guard let itemLocation = item.placemark.location else { return nil }
                let distanceMiles = itemLocation.distance(from: location) / metersPerMile
                guard distanceMiles <= maxRadiusMiles else { return nil }
                return NearbyRestaurant(
                    name: item.name ?? "Unknown",
                    address: Self.formattedAddress(item.placemark),
                    phoneNumber: item.phoneNumber,
                    url: item.url,
                    distanceMiles: distanceMiles
                )
            }
            results = mapped.sorted { $0.distanceMiles < $1.distanceMiles }
            if results.isEmpty {
                errorMessage = "No restaurants found within 20 miles for that search."
            }
        } catch {
            errorMessage = "Couldn't search nearby restaurants: \(error.localizedDescription)"
        }

        isSearching = false
    }

    private static func formattedAddress(_ placemark: MKPlacemark) -> String {
        [placemark.thoroughfare, placemark.locality, placemark.administrativeArea]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
