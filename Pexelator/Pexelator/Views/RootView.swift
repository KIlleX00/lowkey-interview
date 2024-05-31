import SwiftUI

struct RootView: View {

    @StateObject var viewModel: RootViewModel

    var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.paths) {
                Group {
                    switch viewModel.rootElement {
                    case .splash(let viewModel):
                        SplashView(viewModel: viewModel)
                    case .photoList(let viewModel):
                        PhotoListView(viewModel: viewModel)
                    }
                }.navigationDestination(for: NavigationCoordinatorPath.self) { path in
                    switch path {
                    case .text(let title):
                        Text(title)
                    }
                }
            }
            if let presentedElement = viewModel.presentedElement {
                switch presentedElement.screen {
                case .photoDetails(let photoDetailsViewModel):
                    PhotoDetailsView(namespace: presentedElement.namespace, viewModel: photoDetailsViewModel)
                        .zIndex(1)
                }
            }
        }
    }
}

#Preview {
    RootView(viewModel: RootViewModel(pexelsApi: PexelsMockedApi()))
}
