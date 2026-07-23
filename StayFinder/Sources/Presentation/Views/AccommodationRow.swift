import SwiftUI
import Kingfisher

struct AccommodationRow: View {
    let accommodation: Accommodation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { proxy in
                KFImage(accommodation.thumbnailURL)
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: proxy.size.width, height: 180)))
                    .placeholder {
                        Rectangle()
                            .foregroundStyle(.secondary.opacity(0.2))
                            .overlay { ProgressView() }
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .frame(height: 180)

            Text(accommodation.title)
                .font(.headline)
            Text(accommodation.formattedLocation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Label(accommodation.rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                    .foregroundStyle(.orange)
                Spacer()
                Text("\(accommodation.pricePerNight.formatted(.currency(code: "EUR"))) / night")
                    .fontWeight(.semibold)
            }
            .font(.footnote)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
