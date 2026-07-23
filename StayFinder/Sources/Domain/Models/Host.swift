import Foundation

struct Host: Identifiable, Equatable, Sendable {
    let id: UUID
    let name: String
    let avatarURL: URL?
}
