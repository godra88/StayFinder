import SwiftUI

@MainActor
final class AppCoordinator {
    let router: Router
    private let factory: ViewModelFactory

    init(router: Router? = nil, factory: ViewModelFactory = ViewModelFactory()) {
        self.router = router ?? Router()
        self.factory = factory
    }

    @ViewBuilder
    func rootView() -> some View {
        AccommodationListView(viewModel: factory.makeListViewModel(self))
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .accommodationDetail(let id):
            AccommodationDetailView(viewModel: factory.makeDetailViewModel(id))
        }
    }
}
