import SwiftUI

struct PhotoItemView: View {
    @Environment(\.displayScale) var scale
    
    let photo: PexelsPhoto
    let isExpanded: Bool
    let width: CGFloat
    let height: CGFloat
    let namespace: Namespace.ID
    
    private let collapsedSpacing: CGFloat = 24
    private var collapsedImageWidth: CGFloat { width - 2 * collapsedSpacing }
    private var imageWidth: CGFloat { isExpanded ? width : collapsedImageWidth }
    private var imageHeight: CGFloat { isExpanded ? height : (width - spacing) }
    private var spacing: CGFloat { isExpanded ? 0 : collapsedSpacing }
    
    var body: some View {
        ZStack {
            CachedAsyncImage(url: photo.url(for: imageWidth, scale: scale)) { image in
                image
                    .resizable()
                    .matchedGeometryEffect(id: "\(photo.id)image", in: namespace)
                    .aspectRatio(contentMode: isExpanded ? .fit : .fill)
            } placeholder: {
                Group {
                    if isExpanded {
                        CachedAsyncImage(url: photo.url(for: collapsedImageWidth, scale: scale)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: isExpanded ? .fit : .fill)
                        } placeholder: {
                            Color(hex: photo.avgColor) ?? .gray
                        }
                    } else {
                        Color(hex: photo.avgColor) ?? .gray
                    }
                }.matchedGeometryEffect(id: "\(photo.id)placeholder", in: namespace)
            }.matchedGeometryEffect(id: "\(photo.id)asyncImage", in: namespace)
                .frame(width: imageWidth, height: imageHeight)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }.matchedGeometryEffect(id: "\(photo.id)details", in: namespace)
                .frame(width: imageWidth, height: imageHeight)
        }.mask(RoundedRectangle(cornerRadius: isExpanded ? 0 : 20)
                .matchedGeometryEffect(id: "\(photo.id)cornerRadius", in: namespace))
            .shadow(radius: isExpanded ? 0 : 5)
            .padding(EdgeInsets(top: spacing / 2, leading: spacing, bottom: spacing / 2, trailing: spacing))
    }
}

#Preview {
    @Namespace var namespace
    
    return PhotoItemView(photo: PexelsMockedApi.photos.first!, isExpanded: true, width: 400, height: 200, namespace: namespace)
}
