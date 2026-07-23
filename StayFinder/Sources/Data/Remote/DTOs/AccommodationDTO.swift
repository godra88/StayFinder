import Foundation

struct AccommodationDTO: Decodable {
    let id: UUID
    let title: String
    let description: String
    let city: String
    let country: String
    let pricePerNight: Double
    let rating: Double
    let imageUrls: [String]
    let amenities: [String]
    let bedrooms: Int
    let bathrooms: Int
    let maxGuests: Int

    enum CodingKeys: String, CodingKey {
        case id, title, description, city, country, rating, amenities, bedrooms, bathrooms
        case pricePerNight = "price_per_night"
        case imageUrls = "image_urls"
        case maxGuests = "max_guests"
    }
}

extension AccommodationDTO {
    func toDomain() -> Accommodation {
        Accommodation(
            id: id,
            title: title,
            description: description,
            city: city,
            country: country,
            pricePerNight: pricePerNight,
            rating: rating,
            imageUrls: imageUrls.compactMap { string -> URL? in
                guard let url = URL(string: string),
                      url.scheme == "http" || url.scheme == "https" else { return nil }
                return url
            },
            amenities: amenities,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            maxGuests: maxGuests
        )
    }
}
