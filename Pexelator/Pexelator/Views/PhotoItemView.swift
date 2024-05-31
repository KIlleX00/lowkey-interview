import SwiftUI

struct PhotoItemView: View {
    @Environment(\.displayScale) var scale
    
    let photo: PexelsPhoto
    let width: CGFloat
    
    var imageWidth: CGFloat { width - 2 * spacing }
    
    private let spacing: CGFloat = 24
    
    var body: some View {
        ZStack {
            CachedAsyncImage(url: photo.url(for: imageWidth, scale: scale)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color(hex: photo.avgColor) ?? .gray
            }
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        if !photo.alt.isEmpty {
                            Text(photo.alt).fontWeight(.semibold)
                        }
                        Text("Photo by ") + Text(photo.photographer).fontWeight(.semibold)
                    }.foregroundStyle(.secondary)
                    Spacer()
                }.padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 12, height: 12)))
                    .padding()
            }.frame(width: imageWidth, height: width - spacing)
        }.frame(width: imageWidth, height: width - spacing)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 5)
            .padding(EdgeInsets(top: spacing / 2, leading: spacing, bottom: spacing / 2, trailing: spacing))
    }
}

#Preview {
    PhotoItemView(photo: PexelsMockedApi.photos.first!, width: 400)
}
