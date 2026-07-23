import Foundation

struct AccommodationDetail: Identifiable, Equatable, Sendable {
    let accommodation: Accommodation
    let host: Host
    let reviews: [Review]

    var id: UUID { accommodation.id }
}
