import Foundation
import Observation

@Observable
@MainActor
final class AccommodationDetailViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(AccommodationDetail)
        case failed(String)
    }

    private(set) var state: State = .idle

    private let accommodationId: UUID
    private let fetchDetail: any FetchAccommodationDetailUseCaseProtocol

    init(
        accommodationId: UUID,
        fetchDetail: any FetchAccommodationDetailUseCaseProtocol
    ) {
        self.accommodationId = accommodationId
        self.fetchDetail = fetchDetail
    }

    func load() async {
        if !isLoaded { state = .loading }
        await performLoad()
    }

    private func performLoad() async {
        do {
            state = .loaded(try await fetchDetail.execute(id: accommodationId))
        } catch is CancellationError {} catch {
            state = .failed(error.localizedDescription)
        }
    }

    private var isLoaded: Bool {
        if case .loaded = state { return true }
        return false
    }
}
