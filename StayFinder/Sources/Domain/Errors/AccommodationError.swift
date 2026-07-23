import Foundation

enum AccommodationError: LocalizedError, Equatable {
    case fetchFailed
    case notFound
    case unreachable
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .fetchFailed:
            return "Failed to load accommodations. Please try again."
        case .notFound:
            return "The accommodation could not be found."
        case .unreachable:
            return "Can't reach the server. Check your connection and try again."
        case .malformedResponse:
            return "The server sent something unexpected. Please try again later."
        }
    }
}
