import SwiftUI

struct ViewModelFactory {
    var makeListViewModel: @MainActor (AppCoordinator) -> AccommodationListViewModel
    var makeDetailViewModel: @MainActor (UUID) -> AccommodationDetailViewModel

    init(root: AppCompositionRoot = AppCompositionRoot()) {
        makeListViewModel = { coordinator in
            AccommodationListViewModel(
                fetchAccommodations: root.fetchAccommodationsUseCase,
                onSelectAccommodation: { [weak coordinator] id in
                    coordinator?.router.push(.accommodationDetail(id))
                }
            )
        }
        makeDetailViewModel = { id in
            AccommodationDetailViewModel(
                accommodationId: id,
                fetchDetail: root.fetchAccommodationDetailUseCase
            )
        }
    }
}
