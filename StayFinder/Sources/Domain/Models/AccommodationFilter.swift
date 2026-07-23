import Foundation

struct AccommodationFilter: Equatable, Sendable {
    var minPricePerNight: Double?
    var maxPricePerNight: Double?

    var isActive: Bool { minPricePerNight != nil || maxPricePerNight != nil }

    func matches(pricePerNight price: Double) -> Bool {
        if let min = minPricePerNight, price < min { return false }
        if let max = maxPricePerNight, price > max { return false }
        return true
    }

    func apply(to accommodations: [Accommodation]) -> [Accommodation] {
        guard isActive else { return accommodations }
        return accommodations.filter { matches(pricePerNight: $0.pricePerNight) }
    }

    static let empty = AccommodationFilter()
}
