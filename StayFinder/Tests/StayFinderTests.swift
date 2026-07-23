import Foundation
import Testing
@testable import StayFinder

struct CleanArchitectureTests {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    @Test func dtoAbsorbsWireFormatAndDomainModelIsPlainSwift() throws {
        let json = Data("""
        {
            "id": "1F1E2C4C-0000-0000-0000-000000000001",
            "title": "Cozy Loft", "description": "Bright loft.",
            "city": "Prague", "country": "Czechia",
            "price_per_night": 85.5, "rating": 4.7,
            "image_urls": ["https://example.com/a.jpg"],
            "amenities": ["WiFi"], "bedrooms": 2, "bathrooms": 1, "max_guests": 4
        }
        """.utf8)

        let domain = try decoder.decode(AccommodationDTO.self, from: json).toDomain()

        #expect(domain.pricePerNight == 85.5)
        #expect(domain.formattedLocation == "Prague, Czechia")
    }

    @Test func dtoFiltersInvalidURLsBeforeTheyReachTheDomain() throws {
        let json = Data("""
        {
            "id": "1F1E2C4C-0000-0000-0000-000000000001",
            "title": "T", "description": "D", "city": "C", "country": "X",
            "price_per_night": 50, "rating": 4.0,
            "image_urls": ["https://example.com/ok.jpg", "not a url"],
            "amenities": [], "bedrooms": 1, "bathrooms": 1, "max_guests": 2
        }
        """.utf8)

        let domain = try decoder.decode(AccommodationDTO.self, from: json).toDomain()

        #expect(domain.imageUrls.count == 1)
    }

    @Test func detailDTODecodesJoinedResponseIntoDomainModel() throws {
        let json = Data("""
        {
            "id": "1F1E2C4C-0000-0000-0000-000000000001",
            "title": "Cozy Loft", "description": "Bright loft.", "city": "Prague",
            "country": "Czechia", "price_per_night": 85, "rating": 4.7,
            "image_urls": [], "amenities": [], "bedrooms": 1, "bathrooms": 1, "max_guests": 2,
            "hosts": { "id": "1F1E2C4C-0000-0000-0000-000000000002",
                       "name": "Jan K.", "avatar_url": null },
            "reviews": [{ "id": "1F1E2C4C-0000-0000-0000-000000000003",
                          "author_name": "Ana", "author_avatar_url": null,
                          "rating": 5, "comment": "Amazing.",
                          "created_at": "2024-01-01T00:00:00Z" }]
        }
        """.utf8)

        let domain = try decoder.decode(AccommodationDetailDTO.self, from: json).toDomain()

        #expect(domain.accommodation.title == "Cozy Loft")
        #expect(domain.host.name == "Jan K.")
        #expect(domain.reviews.count == 1)
    }

    @Test func reviewsAreSortedNewestFirst() throws {
        let json = Data("""
        {
            "id": "1F1E2C4C-0000-0000-0000-000000000001",
            "title": "Cozy Loft", "description": "Bright loft.", "city": "Prague",
            "country": "Czechia", "price_per_night": 85, "rating": 4.7,
            "image_urls": [], "amenities": [], "bedrooms": 1, "bathrooms": 1, "max_guests": 2,
            "hosts": { "id": "1F1E2C4C-0000-0000-0000-000000000002",
                       "name": "Jan K.", "avatar_url": null },
            "reviews": [
                { "id": "1F1E2C4C-0000-0000-0000-000000000010",
                  "author_name": "Old", "author_avatar_url": null,
                  "rating": 4, "comment": "First stay.",
                  "created_at": "2023-06-01T12:00:00Z" },
                { "id": "1F1E2C4C-0000-0000-0000-000000000011",
                  "author_name": "New", "author_avatar_url": null,
                  "rating": 5, "comment": "Recent stay.",
                  "created_at": "2024-09-15T12:00:00Z" },
                { "id": "1F1E2C4C-0000-0000-0000-000000000012",
                  "author_name": "Middle", "author_avatar_url": null,
                  "rating": 3, "comment": "Middle stay.",
                  "created_at": "2024-02-10T12:00:00Z" }
            ]
        }
        """.utf8)

        let domain = try decoder.decode(AccommodationDetailDTO.self, from: json).toDomain()

        #expect(domain.reviews.map(\.authorName) == ["New", "Middle", "Old"])
    }

    @Test func useCaseIsDecoupledFromTheDataLayer() async throws {
        let repo = MockAccommodationRepository()
        repo.accommodationsResult = .success([Fixture.accommodation()])

        let result = try await FetchAccommodationsUseCase(repository: repo).execute()

        #expect(result.count == 1)
    }

    @Test func domainErrorsDoNotLeakDataLayerTypes() async {
        let repo = MockAccommodationRepository()
        repo.detailResult = .failure(AccommodationError.notFound)

        await #expect(throws: AccommodationError.self) {
            try await FetchAccommodationDetailUseCase(repository: repo).execute(id: UUID())
        }
    }
}


@MainActor
struct DependencyInjectionTests {

    @Test func viewModelReceivesDependenciesThroughConstructorInjection() async {
        let vm = makeTestListViewModel(
            fetchAccommodations: StubFetchAccommodationsUseCase(result: .success([Fixture.accommodation()]))
        )

        await vm.load()

        #expect(vm.accommodations.count == 1)
    }

    @Test func factoriesFromDifferentRootsDoNotInterfere() async {
        let succeedingSource = StubAccommodationDataSource()
        succeedingSource.listResult = .success([Fixture.accommodationDTO()])
        let failingSource = StubAccommodationDataSource()
        failingSource.listResult = .failure(TestError())

        let succeeding = ViewModelFactory(root: AppCompositionRoot(dataSource: succeedingSource)).makeListViewModel(AppCoordinator())
        let failing = ViewModelFactory(root: AppCompositionRoot(dataSource: failingSource)).makeListViewModel(AppCoordinator())

        await succeeding.load()
        await failing.load()

        #expect(succeeding.accommodations.count == 1)
        #expect(failing.state == .failed(AccommodationError.fetchFailed.localizedDescription))
    }

    @Test func overridingDataSourcePropagatesThroughTheFullGraph() async throws {
        let source = StubAccommodationDataSource()
        source.listResult = .success([Fixture.accommodationDTO(), Fixture.accommodationDTO()])
        let root = AppCompositionRoot(dataSource: source)

        let result = try await root.fetchAccommodationsUseCase.execute()

        #expect(result.count == 2)
    }
}

@MainActor
struct CoordinatorPatternTests {

    @Test func routerStateIsInspectableWithoutRendering() {
        let router = Router()
        let first = UUID()
        let second = UUID()

        router.push(.accommodationDetail(first))
        router.push(.accommodationDetail(second))
        #expect(router.routes == [.accommodationDetail(first), .accommodationDetail(second)])

        router.pop()
        #expect(router.routes == [.accommodationDetail(first)])

        router.popToRoot()
        #expect(router.routes.isEmpty)
    }

    @Test func selectingAccommodationPushesTypedRouteOntoTheStack() {
        let router = Router()
        let coordinator = makeTestCoordinator(router: router)
        let vm = ViewModelFactory(root: makeTestRoot()).makeListViewModel(coordinator)
        let id = UUID()

        vm.selectAccommodation(id: id)

        #expect(router.routes == [.accommodationDetail(id)])
    }

    @Test func coordinatorPassesCorrectIdToDetailViewModelFactory() {
        let expectedId = UUID()
        var capturedId: UUID?

        var factory = ViewModelFactory()
        factory.makeDetailViewModel = { id in
            capturedId = id
            return AccommodationDetailViewModel(
                accommodationId: id,
                fetchDetail: StubFetchAccommodationDetailUseCase(result: .failure(TestError()))
            )
        }

        _ = AppCoordinator(factory: factory).destination(for: .accommodationDetail(expectedId))

        #expect(capturedId == expectedId)
    }
}
