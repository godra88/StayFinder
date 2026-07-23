import Foundation
import Observation

@Observable
@MainActor
final class AccommodationListViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded([Accommodation])
        case failed(String)
    }

    private(set) var state: State = .idle
    var filter: AccommodationFilter = .empty

    private let fetchAccommodations: any FetchAccommodationsUseCaseProtocol
    private let onSelectAccommodation: @MainActor (UUID) -> Void

    init(
        fetchAccommodations: any FetchAccommodationsUseCaseProtocol,
        onSelectAccommodation: @escaping @MainActor (UUID) -> Void = { _ in }
    ) {
        self.fetchAccommodations = fetchAccommodations
        self.onSelectAccommodation = onSelectAccommodation
    }

    var accommodations: [Accommodation] {
        guard case .loaded(let all) = state else { return [] }
        return filter.apply(to: all)
    }

    var isFilteringOutEverything: Bool {
        guard case .loaded(let all) = state else { return false }
        return !all.isEmpty && filter.apply(to: all).isEmpty
    }

    func load() async {
        if !isLoaded { state = .loading }
        await performLoad()
    }

    func refresh() async {
        await performLoad(preservingContentOnFailure: true)
    }

    private func performLoad(preservingContentOnFailure: Bool = false) async {
        do {
            state = .loaded(try await fetchAccommodations.execute())
        } catch is CancellationError {} catch {
            guard !preservingContentOnFailure || !isLoaded else { return }
            state = .failed(error.localizedDescription)
        }
    }

    private var isLoaded: Bool {
        if case .loaded = state { return true }
        return false
    }

    func selectAccommodation(id: UUID) {
        onSelectAccommodation(id)
    }
}
