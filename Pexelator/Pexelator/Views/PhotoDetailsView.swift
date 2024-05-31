import SwiftUI

struct PhotoDetailsView: View {
    
    var namespace: Namespace.ID
    
    @StateObject var viewModel: PhotoDetailsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            PhotoItemView(photo: viewModel.photo, isExpanded: true, width: geometry.size.width, height: geometry.size.height, namespace: namespace)
                .matchedGeometryEffect(id: "\(viewModel.photo.id)", in: namespace)
                .onTapGesture {
                    viewModel.dismiss()
                }
            HStack {
                Spacer()
                Button(action: viewModel.dismiss, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                })
            }.padding(.trailing, 16)
        }.background(.black)
            .navigationTitle("Photo")
    }
}

#Preview {
    @Namespace var namespace
    return PhotoDetailsView(namespace: namespace, viewModel: PhotoDetailsViewModel(photo: PexelsMockedApi.photos.first!, navigationCoordinator: MockedNavigationCoordinator()))
}
