import Combine
import SwiftUI
import Lottie

class SplashViewModel: ObservableObject {
    
    // MARK: - Output
    
    @Published var logoPlaybackMode = LottiePlaybackMode.paused(at: .progress(0))
    @Published var progressViewOpacity = 0.0
    
    // MARK: - Properties
    
    let id = UUID().uuidString
    
    weak var navigationCoordinator: NavigationCoordinator?
    
    private let hasCompletedLogoAnimation = CurrentValueSubject<Bool, Never>(false)
    private let isPreloadingData = CurrentValueSubject<Bool, Never>(true)
    private let response = CurrentValueSubject<CuratedPhotosResponse?, Never>(nil)
    
    private let cancellables = CompositeCancellable()
    
    // MARK: - Lifecycle
    
    init(pexelsApi: PexelsApi) {
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
        
        Task { @MainActor [weak self] in
            do {
                let response = try await pexelsApi.curatedPhotos(page: 1, pageSize: 20)
                self?.response.value = response.content
                self?.isPreloadingData.value = false
            } catch {
                print(error)
            }
        }
    }
    
    deinit {
        cancellables.cancel()
    }
    
    // MARK: - Interface
    
    func viewDidAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.logoPlaybackMode = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
        }
    }
    
    func logoAnimationDidFinish() {
        hasCompletedLogoAnimation.value = true
    }
    
}
