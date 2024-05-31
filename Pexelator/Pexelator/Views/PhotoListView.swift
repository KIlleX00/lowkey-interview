import SwiftUI

struct PhotoListView: View {
    
    @StateObject var viewModel: PhotoListViewModel
    
    var body: some View {
        GeometryReader(content: { geometry in
            List {
                ForEach(viewModel.photos) { photo in
                    PhotoItemView(photo: photo, width: geometry.size.width)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .onAppear(perform: {
                            viewModel.fetchNextPageIfNeeded(currentPhoto: photo)
                        })
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
                .navigationTitle("Curated Photos")
                .alert(viewModel: viewModel.alertViewModel)
                .refreshable {
                    viewModel.fetchFirstPageOfUsers()
                }
        })
    }
}

#Preview {
    NavigationStack {
        PhotoListView(viewModel: PhotoListViewModel(pexelsApi: PexelsMockedApi(), navigationCoordinator: MockedNavigationCoordinator()))
    }
}
