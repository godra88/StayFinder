import Foundation
@testable import StayFinder

enum Fixture {
    static func accommodation(
        id: UUID = UUID(),
        title: String = "Cozy Loft",
        pricePerNight: Double = 100
    ) -> Accommodation {
        Accommodation(
            id: id,
            title: title,
            description: "A nice place.",
            city: "Prague",
            country: "Czechia",
            pricePerNight: pricePerNight,
            rating: 4.7,
            imageUrls: [URL(string: "https://example.com/1.jpg")!],
            amenities: ["WiFi"],
            bedrooms: 2,
            bathrooms: 1,
            maxGuests: 4
        )
    }

    static func accommodationDTO(
        id: UUID = UUID(),
        pricePerNight: Double = 100
    ) -> AccommodationDTO {
        AccommodationDTO(
            id: id,
            title: "Cozy Loft",
            description: "A nice place.",
            city: "Prague",
            country: "Czechia",
            pricePerNight: pricePerNight,
            rating: 4.7,
            imageUrls: ["https://example.com/1.jpg"],
            amenities: ["WiFi"],
            bedrooms: 2,
            bathrooms: 1,
            maxGuests: 4
        )
    }
}

final class StubAccommodationDataSource: AccommodationDataSource, @unchecked Sendable {
    var listResult: Result<[AccommodationDTO], Error> = .success([])
    var detailResult: Result<AccommodationDetailDTO, Error> = .failure(TestError())

    func fetchAccommodations() async throws -> [AccommodationDTO] {
        try listResult.get()
    }

    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetailDTO {
        try detailResult.get()
    }
}

final class MockAccommodationRepository: AccommodationRepositoryProtocol, @unchecked Sendable {
    var accommodationsResult: Result<[Accommodation], Error> = .success([])
    var detailResult: Result<AccommodationDetail, Error> = .failure(AccommodationError.notFound)

    func fetchAccommodations() async throws -> [Accommodation] {
        try accommodationsResult.get()
    }

    func fetchAccommodationDetail(id: UUID) async throws -> AccommodationDetail {
        try detailResult.get()
    }
}

struct StubFetchAccommodationsUseCase: FetchAccommodationsUseCaseProtocol {
    let result: Result<[Accommodation], Error>

    func execute() async throws -> [Accommodation] {
        try result.get()
    }
}

struct StubFetchAccommodationDetailUseCase: FetchAccommodationDetailUseCaseProtocol {
    let result: Result<AccommodationDetail, Error>

    func execute(id: UUID) async throws -> AccommodationDetail {
        try result.get()
    }
}

@MainActor
func makeTestListViewModel(
    fetchAccommodations: any FetchAccommodationsUseCaseProtocol
        = StubFetchAccommodationsUseCase(result: .success([])),
    onSelectAccommodation: @escaping (UUID) -> Void = { _ in }
) -> AccommodationListViewModel {
    AccommodationListViewModel(
        fetchAccommodations: fetchAccommodations,
        onSelectAccommodation: onSelectAccommodation
    )
}

func makeTestRoot(
    dataSource: any AccommodationDataSource = StubAccommodationDataSource()
) -> AppCompositionRoot {
    AppCompositionRoot(dataSource: dataSource)
}

@MainActor
func makeTestCoordinator(
    router: Router? = nil,
    root: AppCompositionRoot = makeTestRoot()
) -> AppCoordinator {
    AppCoordinator(router: router, factory: ViewModelFactory(root: root))
}

struct TestError: Error, LocalizedError {
    var errorDescription: String? { "Something broke" }
}
