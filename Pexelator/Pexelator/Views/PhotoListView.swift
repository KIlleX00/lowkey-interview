import SwiftUI

struct PhotoListView: View {
    
    @StateObject var viewModel: PhotoListViewModel
    @Namespace var namespace
    
    var body: some View {
        GeometryReader(content: { geometry in
            List {
                ForEach(viewModel.photos) { photo in
                    PhotoItemView(photo: photo, isExpanded: false, width: geometry.size.width, height: geometry.size.height, namespace: namespace)
                        .matchedGeometryEffect(id: "\(photo.id)", in: namespace)
                        .listRowSeparator(.hidden)
                        .onAppear(perform: {
                            viewModel.fetchNextPageIfNeeded(currentPhoto: photo)
                        })
                        .onTapGesture {
                            viewModel.photoTapAction(photo, namespace: namespace)
                        }
                }
                if viewModel.isFetchingNextPage {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(PexelatorProgressViewStyle())
                            .id(UUID())
                        Spacer()
                    }.listRowSeparator(.hidden)
                }
            }.listStyle(PlainListStyle.plain)
                .scrollIndicators(.hidden)
                .animation(.easeIn, value: viewModel.photos)
                .alert(viewModel: viewModel.alertViewModel)
                .refreshable {
                    viewModel.fetchFirstPageOfUsers()
                }
        }).navigationTitle("Curated Photos")
    }
}

#Preview {
    NavigationStack {
        PhotoListView(viewModel: PhotoListViewModel(pexelsApi: PexelsMockedApi(), navigationCoordinator: MockedNavigationCoordinator()))
    }
}
