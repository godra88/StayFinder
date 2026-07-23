import SwiftUI
import Kingfisher

struct AccommodationDetailView: View {
    @State private var viewModel: AccommodationDetailViewModel
    @State private var reloadID = 0

    init(viewModel: AccommodationDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: reloadID) {
                await viewModel.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading...")
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
        case .loaded(let detail):
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ImageCarouselView(imageUrls: detail.accommodation.imageUrls)

                    headerSection(detail.accommodation)
                    detailsSection(detail.accommodation)
                    hostSection(detail.host)
                    if !detail.reviews.isEmpty {
                        reviewsSection(detail.reviews)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func headerSection(_ accommodation: Accommodation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(accommodation.title)
                .font(.title2)
                .fontWeight(.bold)
            HStack {
                Label(accommodation.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    .foregroundStyle(.orange)
                Text("·")
                Text(accommodation.formattedLocation)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .padding()
    }

    @ViewBuilder
    private func detailsSection(_ accommodation: Accommodation) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            HStack(spacing: 24) {
                Label("\(accommodation.bedrooms) bed", systemImage: "bed.double")
                Label("\(accommodation.bathrooms) bath", systemImage: "shower")
                Label("\(accommodation.maxGuests) guests", systemImage: "person.2")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Divider()

            Text(accommodation.description)
                .font(.body)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Amenities")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(accommodation.amenities, id: \.self) { amenity in
                        Text(amenity)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.secondary.opacity(0.15), in: Capsule())
                    }
                }
            }

            Divider()

            HStack {
                Spacer()
                VStack(spacing: 2) {
                    Text(accommodation.pricePerNight.formatted(.currency(code: "EUR")))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("per night")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func hostSection(_ host: Host) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your host")
                .font(.headline)
            HStack(spacing: 12) {
                if let avatarURL = host.avatarURL {
                    KFImage(avatarURL)
                        .placeholder {
                            Circle()
                                .foregroundStyle(.secondary.opacity(0.2))
                                .overlay { ProgressView() }
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                }
                Text(host.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding()

        Divider()
            .padding(.horizontal)
    }

    @ViewBuilder
    private func reviewsSection(_ reviews: [Review]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews (\(reviews.count))")
                .font(.headline)
            ForEach(Array(reviews.enumerated()), id: \.element.id) { index, review in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(review.authorName)
                            .fontWeight(.medium)
                        Spacer()
                        Label("\(review.rating)", systemImage: "star.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                    Text(review.comment)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if index < reviews.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
    }
}


#Preview("Loaded") {
    NavigationStack {
        AccommodationDetailView(viewModel: AccommodationDetailViewModel(
            accommodationId: UUID(),
            fetchDetail: PreviewDetailUseCase(behavior: .success(.preview))
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        AccommodationDetailView(viewModel: AccommodationDetailViewModel(
            accommodationId: UUID(),
            fetchDetail: PreviewDetailUseCase(behavior: .loading)
        ))
    }
}

#Preview("Failed") {
    NavigationStack {
        AccommodationDetailView(viewModel: AccommodationDetailViewModel(
            accommodationId: UUID(),
            fetchDetail: PreviewDetailUseCase(behavior: .failure)
        ))
    }
}
