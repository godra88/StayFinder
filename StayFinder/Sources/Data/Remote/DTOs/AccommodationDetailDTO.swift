import Foundation

struct AccommodationDetailDTO: Decodable {
    let accommodation: AccommodationDTO
    let host: HostDTO
    let reviews: [ReviewDTO]

    enum CodingKeys: String, CodingKey {
        case hosts, reviews
    }

    init(from decoder: Decoder) throws {
        accommodation = try AccommodationDTO(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        host = try container.decode(HostDTO.self, forKey: .hosts)
        reviews = try container.decodeIfPresent([ReviewDTO].self, forKey: .reviews) ?? []
    }
}

extension AccommodationDetailDTO {
    func toDomain() -> AccommodationDetail {
        AccommodationDetail(
            accommodation: accommodation.toDomain(),
            host: host.toDomain(),
            reviews: reviews
                .map { $0.toDomain() }
                .sorted { $0.createdAt > $1.createdAt }
        )
    }
}
