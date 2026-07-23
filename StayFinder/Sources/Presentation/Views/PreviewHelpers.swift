#if DEBUG
import SwiftUI

struct PreviewListUseCase: FetchAccommodationsUseCaseProtocol {
    enum Behavior { case success([Accommodation]), failure, loading }
    let behavior: Behavior

    func execute() async throws -> [Accommodation] {
        switch behavior {
        case .success(let items): return items
        case .failure: throw URLError(.notConnectedToInternet)
        case .loading: try await Task.sleep(for: .seconds(9999)); return []
        }
    }
}

struct PreviewDetailUseCase: FetchAccommodationDetailUseCaseProtocol {
    enum Behavior { case success(AccommodationDetail), failure, loading }
    let behavior: Behavior

    func execute(id: UUID) async throws -> AccommodationDetail {
        switch behavior {
        case .success(let detail): return detail
        case .failure: throw URLError(.notConnectedToInternet)
        case .loading: try await Task.sleep(for: .seconds(9999)); return .preview
        }
    }
}

extension Accommodation {
    static let loft = Accommodation(
        id: UUID(),
        title: "Cozy Loft",
        description: "A beautifully renovated loft in the heart of the old town with exposed brick walls and tall ceilings.",
        city: "Prague", country: "Czechia",
        pricePerNight: 120, rating: 4.8,
        imageUrls: [],
        amenities: ["WiFi", "Kitchen", "Washer", "Heating"],
        bedrooms: 1, bathrooms: 1, maxGuests: 2
    )

    static let beach = Accommodation(
        id: UUID(),
        title: "Beachfront Villa",
        description: "Steps from the sand with stunning sea views and a private infinity pool.",
        city: "Barcelona", country: "Spain",
        pricePerNight: 350, rating: 4.5,
        imageUrls: [],
        amenities: ["Pool", "WiFi", "Air conditioning", "BBQ"],
        bedrooms: 3, bathrooms: 2, maxGuests: 6
    )
}

extension AccommodationDetail {
    static let preview = AccommodationDetail(
        accommodation: .loft,
        host: Host(id: UUID(), name: "Jan Kovář", avatarURL: nil),
        reviews: [
            Review(id: UUID(), authorName: "Alice M.", authorAvatarURL: nil, rating: 5,
                   comment: "Fantastic place — very clean and perfectly central!",
                   createdAt: Date(timeIntervalSince1970: 1_720_000_000)),
            Review(id: UUID(), authorName: "Bob T.", authorAvatarURL: nil, rating: 4,
                   comment: "Great location, host was very responsive.",
                   createdAt: Date(timeIntervalSince1970: 1_710_000_000))
        ]
    )
}
#endif
