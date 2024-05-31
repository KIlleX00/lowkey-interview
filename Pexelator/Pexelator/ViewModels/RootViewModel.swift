import Combine
import SwiftUI

/// Represents the root element of the navigation hierarchy.
enum NavigationRootElement {
    case splash(SplashViewModel)
    case photoList(PhotoListViewModel)
}

/// Represents a navigation path element that can be pushed onto the navigation stack.
enum NavigationCoordinatorPath: Hashable {
    case text(String)
}

/// Represents an element that can be presented modally.
struct NavigationPresentedElement {
    let screen: Screen
    let namespace: Namespace.ID
    
    /// Represents the screen to be presented.
    enum Screen {
        case photoDetails(PhotoDetailsViewModel)
    }
}

/// Protocol for a navigation coordinator that manages navigation actions.
protocol NavigationCoordinator: AnyObject {
    /// Replaces the root of the navigation hierarchy.
    ///
    /// - Parameter root: The new root element.
    func replaceRoot(_ root: NavigationRootElement)
    
    /// Pushes a new path onto the navigation stack.
    ///
    /// - Parameter path: The path to be pushed.
    func push(_ path: NavigationCoordinatorPath)
    
    /// Pops the top path from the navigation stack.
    func pop()
    
    /// Presents a modal element.
    ///
    /// - Parameter element: The element to be presented.
    func present(_ element: NavigationPresentedElement)
    
    /// Dismisses the currently presented modal element.
    func dismiss()
}

/// ViewModel for managing the root of the navigation hierarchy.
class RootViewModel: ObservableObject {
    
    // MARK: - Output
    
    /// The current navigation path.
    @Published var paths = NavigationPath()
    
    /// The current root element of the navigation hierarchy.
    @Published var rootElement: NavigationRootElement
    
    /// The currently presented modal element, if any.
    @Published var presentedElement: NavigationPresentedElement? = nil
    
    // MARK: - Properties

    /// The Pexels API service.
    private let pexelsApi: PexelsApi
    
    // MARK: - Lifecycle
    
    /// Initializes a new instance of `RootViewModel`.
    ///
    /// - Parameter pexelsApi: The Pexels API service.
    init(pexelsApi: PexelsApi) {
        self.pexelsApi = pexelsApi
        let splashViewModel = SplashViewModel(pexelsApi: pexelsApi)
        rootElement = .splash(splashViewModel)
        splashViewModel.navigationCoordinator = self
    }
    
}

extension RootViewModel: NavigationCoordinator {
    
    /// Replaces the root of the navigation hierarchy with an animation.
    ///
    /// - Parameter path: The new root element.
    func replaceRoot(_ path: NavigationRootElement) {
        withAnimation {
            rootElement = path
        }
    }
    
    /// Pushes a new path onto the navigation stack.
    ///
    /// - Parameter path: The path to be pushed.
    func push(_ path: NavigationCoordinatorPath) {
        paths.append(path)
    }
    
    /// Pops the top path from the navigation stack.
    func pop() {
        paths.removeLast()
    }
    
    /// Presents a modal element.
    ///
    /// - Parameter element: The element to be presented.
    func present(_ element: NavigationPresentedElement) {
        presentedElement = element
    }
    
    /// Dismisses the currently presented modal element.
    func dismiss() {
        presentedElement = nil
    }
    
}

/// A mock implementation of the `NavigationCoordinator` protocol for testing purposes.
class MockedNavigationCoordinator: NavigationCoordinator {
    func replaceRoot(_ path: NavigationRootElement) { }
    func push(_ path: NavigationCoordinatorPath) { }
    func pop() { }
    func present(_ element: NavigationPresentedElement) { }
    func dismiss() { }
}
