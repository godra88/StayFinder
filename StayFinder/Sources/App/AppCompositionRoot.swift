import Supabase

final class AppCompositionRoot {
    private let injectedDataSource: (any AccommodationDataSource)?
    private lazy var supabaseClient: SupabaseClient = SupabaseClientFactory.make()
    private lazy var repository: any AccommodationRepositoryProtocol = {
        let dataSource = injectedDataSource ?? SupabaseAccommodationDataSource(client: supabaseClient)
        return AccommodationRepository(dataSource: dataSource)
    }()

    init(dataSource: (any AccommodationDataSource)? = nil) {
        self.injectedDataSource = dataSource
    }

    lazy var fetchAccommodationsUseCase: any FetchAccommodationsUseCaseProtocol =
        FetchAccommodationsUseCase(repository: repository)

    lazy var fetchAccommodationDetailUseCase: any FetchAccommodationDetailUseCaseProtocol =
        FetchAccommodationDetailUseCase(repository: repository)
}
