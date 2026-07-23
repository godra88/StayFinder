import Foundation

struct ReviewDTO: Decodable {
    let id: UUID
    let authorName: String
    let authorAvatarUrl: String?
    let rating: Int
    let comment: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, rating, comment
        case authorName = "author_name"
        case authorAvatarUrl = "author_avatar_url"
        case createdAt = "created_at"
    }
}

extension ReviewDTO {
    func toDomain() -> Review {
        Review(
            id: id,
            authorName: authorName,
            authorAvatarURL: authorAvatarUrl.flatMap(URL.init(string:)),
            rating: rating,
            comment: comment,
            createdAt: createdAt
        )
    }
}
