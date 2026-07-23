import Foundation

protocol FetchAccommodationDetailUseCaseProtocol: Sendable {
    func execute(id: UUID) async throws -> AccommodationDetail
}

struct FetchAccommodationDetailUseCase: FetchAccommodationDetailUseCaseProtocol {
    private let repository: any AccommodationRepositoryProtocol

    init(repository: any AccommodationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: UUID) async throws -> AccommodationDetail {
        try await repository.fetchAccommodationDetail(id: id)
    }
}
