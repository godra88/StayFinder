import Foundation

protocol FetchAccommodationsUseCaseProtocol: Sendable {
    func execute() async throws -> [Accommodation]
}

struct FetchAccommodationsUseCase: FetchAccommodationsUseCaseProtocol {
    private let repository: any AccommodationRepositoryProtocol

    init(repository: any AccommodationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Accommodation] {
        try await repository.fetchAccommodations()
    }
}
