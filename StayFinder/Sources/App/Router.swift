import Foundation
import Observation

@Observable
@MainActor
final class Router {
    var routes: [AppRoute] = []

    func push(_ route: AppRoute) {
        routes.append(route)
    }

    func pop() {
        guard !routes.isEmpty else { return }
        routes.removeLast()
    }

    func popToRoot() {
        routes.removeAll()
    }
}
