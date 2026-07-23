import SwiftUI
import Kingfisher

struct ImageCarouselView: View {
    let imageUrls: [URL]
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $currentIndex) {
                    ForEach(imageUrls.indices, id: \.self) { index in
                        KFImage(imageUrls[index])
                            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: proxy.size.width, height: 260)))
                            .placeholder {
                                Rectangle()
                                    .foregroundStyle(.secondary.opacity(0.2))
                                    .overlay { ProgressView() }
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                if imageUrls.count > 1 {
                    Text("\(currentIndex + 1) / \(imageUrls.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.5), in: Capsule())
                        .foregroundStyle(.white)
                        .padding([.bottom, .trailing], 12)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .clipped()
    }
}
