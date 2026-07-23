import Foundation

struct Review: Identifiable, Equatable, Sendable {
    let id: UUID
    let authorName: String
    let authorAvatarURL: URL?
    let rating: Int
    let comment: String
    let createdAt: Date
}
