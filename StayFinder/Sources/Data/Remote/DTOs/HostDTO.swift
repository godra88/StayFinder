import Foundation

struct HostDTO: Decodable {
    let id: UUID
    let name: String
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case avatarUrl = "avatar_url"
    }
}

extension HostDTO {
    func toDomain() -> Host {
        Host(
            id: id,
            name: name,
            avatarURL: avatarUrl.flatMap(URL.init(string:))
        )
    }
}
