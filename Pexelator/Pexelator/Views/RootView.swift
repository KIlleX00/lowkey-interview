import SwiftUI

struct RootView: View {

    @StateObject var viewModel: RootViewModel

    var body: some View {
        NavigationStack(path: $viewModel.paths) {
            Group {
                switch viewModel.rootElement {
                case .splash(let viewModel):
                    SplashView(viewModel: viewModel)
                case .text(let title):
                    Text(title)
                }
            }.navigationDestination(for: NavigationCoordinatorPath.self) { path in
                    switch path {
                    case .text(let title):
                        Text(title)
                    }
                }
        }

    }
}

#Preview {
    RootView(viewModel: RootViewModel(pexelsApi: PexelsMockedApi()))
}
