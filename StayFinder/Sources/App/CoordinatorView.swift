import SwiftUI

struct CoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        @Bindable var router = coordinator.router

        NavigationStack(path: $router.routes) {
            coordinator.rootView()
                .navigationDestination(for: AppRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
