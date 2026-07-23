import SwiftUI

struct AccommodationListView: View {
    @State private var viewModel: AccommodationListViewModel
    @State private var reloadID = 0
    @State private var showingFilter = false

    init(viewModel: AccommodationListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        content
            .navigationTitle("StayFinder")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: viewModel.filter.isActive
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel(viewModel.filter.isActive ? "Filter (active)" : "Filter")
                }
            }
            .task(id: reloadID) {
                await viewModel.load()
            }
            .sheet(isPresented: $showingFilter) {
                PriceFilterSheet(filter: $viewModel.filter)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading stays...")
        case .failed(let message):
            ContentUnavailableView {
                Label("Failed to load", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try again") {
                    reloadID += 1
                }
                .buttonStyle(.borderedProminent)
            }
        case .loaded:
            if viewModel.accommodations.isEmpty {
                ContentUnavailableView(
                    "No stays found",
                    systemImage: "house",
                    description: Text(viewModel.isFilteringOutEverything
                                      ? "Try adjusting your filter."
                                      : "Check back later.")
                )
            } else {
                List(viewModel.accommodations) { accommodation in
                    Button {
                        viewModel.selectAccommodation(id: accommodation.id)
                    } label: {
                        AccommodationRow(accommodation: accommodation)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        AccommodationListView(viewModel: AccommodationListViewModel(
            fetchAccommodations: PreviewListUseCase(behavior: .success([.loft, .beach]))
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        AccommodationListView(viewModel: AccommodationListViewModel(
            fetchAccommodations: PreviewListUseCase(behavior: .loading)
        ))
    }
}

#Preview("Failed") {
    NavigationStack {
        AccommodationListView(viewModel: AccommodationListViewModel(
            fetchAccommodations: PreviewListUseCase(behavior: .failure)
        ))
    }
}

#Preview("Empty list") {
    NavigationStack {
        AccommodationListView(viewModel: AccommodationListViewModel(
            fetchAccommodations: PreviewListUseCase(behavior: .success([]))
        ))
    }
}

#Preview("Filtered — no results") {
    let vm = AccommodationListViewModel(
        fetchAccommodations: PreviewListUseCase(behavior: .success([.loft, .beach]))
    )
    vm.filter = AccommodationFilter(minPricePerNight: 500, maxPricePerNight: 1000)
    return NavigationStack {
        AccommodationListView(viewModel: vm)
    }
}
