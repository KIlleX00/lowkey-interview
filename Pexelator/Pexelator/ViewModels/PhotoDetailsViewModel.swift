import Combine
import SwiftUI

/// ViewModel for handling the details of a photo.
///
/// This ViewModel is responsible for providing the photo details and handling
/// the dismissal of the photo details screen.
class PhotoDetailsViewModel: ObservableObject {
    
    // MARK: - Output
    
    /// The photo whose details are being displayed.
    let photo: PexelsPhoto
    
    // MARK: - Properties
    
    /// The navigation coordinator responsible for handling navigation actions.
    private let navigationCoordinator: NavigationCoordinator
    
    // MARK: - Lifecycle
    
    /// Initializes a new instance of `PhotoDetailsViewModel`.
    ///
    /// - Parameters:
    ///   - photo: The photo to be displayed.
    ///   - navigationCoordinator: The navigation coordinator responsible for handling navigation actions.
    init(photo: PexelsPhoto, navigationCoordinator: NavigationCoordinator) {
        self.photo = photo
        self.navigationCoordinator = navigationCoordinator
    }
    
    // MARK: - Action
    
    /// Dismisses the photo details screen with an animation.
    ///
    /// This method uses a spring animation to dismiss the screen via the
    /// navigation coordinator.
    func dismiss() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            navigationCoordinator.dismiss()
        }
    }
    
}
