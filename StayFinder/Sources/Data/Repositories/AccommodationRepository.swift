import Foundation

struct AccommodationRepository: AccommodationRepositoryProtocol {
    private let dataSource: any AccommodationDataSource

    init(dataSource: any AccommodationDataSource) {
        self.dataSource = dataSource
    }

    func fetchAccommodations() async throws -> [Accommodation] {
        do {
            return try await dataSource.fetchAccommodations().map { $0.toDomain() }
        } catch {
            throw domainError(for: error, fallback: .fetchFailed)
        }
    }

    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetail {
        do {
            return try await dataSource.fetchAccommodationDetail(id: id).toDomain()
        } catch {
            throw domainError(for: error, fallback: .notFound)
        }
    }

    private func domainError(
        for error: Error,
        fallback: AccommodationError
    ) -> Error {
        switch error {
        case is CancellationError:
            return error
        case let urlError as URLError where urlError.code == .cancelled:
            return CancellationError()
        case is URLError:
            return AccommodationError.unreachable
        case is DecodingError:
            return AccommodationError.malformedResponse
        default:
            return fallback
        }
    }
}
