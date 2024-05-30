import Combine
import SwiftUI

enum NavigationRootElement {
    case splash(SplashViewModel)
    case text(String)
}

enum NavigationCoordinatorPath: Hashable {
    case text(String)
}

protocol NavigationCoordinator: AnyObject {
    func replaceRoot(_ root: NavigationRootElement)
    func push(_ path: NavigationCoordinatorPath)
    func pop()
}

class RootViewModel: ObservableObject {
    
    // MARK: - Output
    
    @Published var paths = NavigationPath()
    @Published var rootElement: NavigationRootElement
    
    // MARK: - Properties

    private let pexelsApi: PexelsApi
    
    // MARK: - Lifecycle
    
    init(pexelsApi: PexelsApi) {
        self.pexelsApi = pexelsApi
        let splashViewModel = SplashViewModel(pexelsApi: pexelsApi)
        rootElement = .splash(splashViewModel)
        splashViewModel.navigationCoordinator = self
    }
    
}

extension RootViewModel: NavigationCoordinator {
    
    func replaceRoot(_ path: NavigationRootElement) {
        withAnimation {
            rootElement = path
        }
    }
    
    func push(_ path: NavigationCoordinatorPath) {
        paths.append(path)
    }
    
    func pop() {
        paths.removeLast()
    }
    
}

class MockedNavigationCoordinator: NavigationCoordinator {
    func replaceRoot(_ path: NavigationRootElement) { }
    func push(_ path: NavigationCoordinatorPath) { }
    func pop() { }
}
