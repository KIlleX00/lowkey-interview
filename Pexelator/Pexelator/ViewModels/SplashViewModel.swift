import Combine
import SwiftUI
import Lottie

/// ViewModel for managing the splash screen logic, including animation and data preloading.
class SplashViewModel: ObservableObject {
    
    // MARK: - Output
    
    /// Published property to control the playback mode of the logo animation.
    @Published var logoPlaybackMode = LottiePlaybackMode.paused(at: .progress(0))
    
    /// Published property to control the opacity of the progress view.
    @Published var progressViewOpacity = 0.0
    
    /// Published property to control the visibility of Try Again button.
    @Published var isTryAgainButtonHidden = true
    
    let alertViewModel = AlertViewModel()
    
    // MARK: - Properties
    
    /// Unique identifier for the ViewModel instance.
    let id = UUID().uuidString
    
    /// Weak reference to the navigation coordinator for handling navigation events.
    weak var navigationCoordinator: NavigationCoordinator?
    
    /// Subject to track the completion status of the logo animation.
    private let hasCompletedLogoAnimation = CurrentValueSubject<Bool, Never>(false)
    
    /// Subject to track the data preloading status.
    private let isPreloadingData = CurrentValueSubject<Bool, Never>(true)
    
    /// Subject to store the response from the Pexels API.
    private let response = CurrentValueSubject<CuratedPhotosResponse?, Never>(nil)
    
    /// Composite cancellable to manage multiple cancellable tasks.
    private let cancellables = CompositeCancellable()
    
    /// API used to perform networing requests.
    private let pexelsApi: PexelsApi
    
    // MARK: - Lifecycle
    
    /// Initializes the ViewModel with the given Pexels API.
    /// - Parameter pexelsApi: The Pexels API instance for fetching curated photos.
    init(pexelsApi: PexelsApi) {
        self.pexelsApi = pexelsApi
        
        cancellables += isPreloadingData
            .combineLatest(hasCompletedLogoAnimation)
            .map { $0 && $1 ? 1.0 : 0.0 }
            .assign(to: \.progressViewOpacity, on: self)
        
        cancellables += response
            .combineLatest(hasCompletedLogoAnimation)
            .filter { $0 != nil && $1 }
            .sinkOnMain(receiveValue: { [weak self] response, _ in
                guard let navigationCoordinator = self?.navigationCoordinator else { return }
                navigationCoordinator.replaceRoot(.photoList(PhotoListViewModel(pexelsApi: pexelsApi, navigationCoordinator: navigationCoordinator, preloadedResponse: response)))
            })
        
        preloadData()
    }
    
    /// Cancels all ongoing tasks when the ViewModel is deallocated.
    deinit {
        cancellables.cancel()
    }
    
    // MARK: - Interface
    
    /// Called when the view appears. Starts the logo animation after a delay.
    func viewDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.logoPlaybackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
        }
    }
    
    /// Called when the logo animation finishes. Updates the completion status of the logo animation.
    func logoAnimationDidFinish() {
        hasCompletedLogoAnimation.value = true
    }
    
    /// Preloads data that will be displayed on the Photo List screen.
    func preloadData() {
        isPreloadingData.value = true
        isTryAgainButtonHidden = true
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response = try await self.pexelsApi.curatedPhotos(page: 1, pageSize: 20)
                self.response.value = response.content
            } catch {
                self.alertViewModel.showAlert(for: error)
                self.isTryAgainButtonHidden = false
            }
            self.isPreloadingData.value = false
        }
    }
    
}
