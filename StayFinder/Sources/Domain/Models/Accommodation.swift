import Foundation

struct Accommodation: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let city: String
    let country: String
    let pricePerNight: Double
    let rating: Double
    let imageUrls: [URL]
    let amenities: [String]
    let bedrooms: Int
    let bathrooms: Int
    let maxGuests: Int

    var thumbnailURL: URL? { imageUrls.first }
    var formattedLocation: String { "\(city), \(country)" }
}
