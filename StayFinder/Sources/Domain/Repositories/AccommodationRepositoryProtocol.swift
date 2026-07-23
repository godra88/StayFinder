import Foundation

protocol AccommodationRepositoryProtocol: Sendable {
    func fetchAccommodations() async throws -> [Accommodation]
    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetail
}
