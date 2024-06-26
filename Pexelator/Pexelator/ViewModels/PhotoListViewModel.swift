import Combine
import SwiftUI

class PhotoListViewModel: ObservableObject {
    
    // MARK: - Output
    
    /// The list of photos to be displayed.
    @Published var photos = [PexelsPhoto]()
    /// Indicates whether the first page of photos is currently being loaded.
    @Published var isLoadingFirstPage = false
    /// Indicates whether the next page of photos is currently being loaded.
    @Published var isFetchingNextPage = false
    
    let alertViewModel = AlertViewModel()
    
    // MARK: - Properties
    
    let id = UUID().uuidString
    
    private let cancellables = CompositeCancellable()
    
    private let pexelsApi: PexelsApi
    private let navigationCoordinator: NavigationCoordinator
    
    private var previousResponse: CuratedPhotosResponse?
    
    private var firstPageTask: Task<Void, Never>?
    private var nextPageTask: Task<Void, Never>?
    
    // MARK: - Lifecycle
    
    init(pexelsApi: PexelsApi, navigationCoordinator: NavigationCoordinator, preloadedResponse: CuratedPhotosResponse? = nil) {
        self.pexelsApi = pexelsApi
        self.navigationCoordinator = navigationCoordinator
        
        if let preloadedResponse {
            previousResponse = preloadedResponse
            photos = preloadedResponse.photos
        } else {
            fetchFirstPageOfUsers()
        }
    }
    
    deinit {
        cancellables.cancel()
    }
    
    // MARK: - Actions
    
    /// Fetches the next page of photos if the current photo is one of the last 10 visible items.
    /// - Parameter photo: Photo that was last displayed in the list.
    func fetchNextPageIfNeeded(currentPhoto photo: PexelsPhoto) {
        guard let index = photos.firstIndex(where: { $0.id == photo.id }),
              index >= photos.count - 10 else { return }
        // Fetch next page only when one of the last 10 items is visible to the user.
        fetchNextPageOfUsers()
        
    }
    
    func photoTapAction(_ photo: PexelsPhoto, namespace: Namespace.ID) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            navigationCoordinator.present(NavigationPresentedElement(screen: .photoDetails(PhotoDetailsViewModel(photo: photo, navigationCoordinator: navigationCoordinator)), namespace: namespace))
        }
    }
    
    // MARK: - Data fetch
    
    /// Fetches the first page of photos.
    func fetchFirstPageOfUsers() {
        isLoadingFirstPage = true
        firstPageTask?.cancel()
        nextPageTask?.cancel()
        isFetchingNextPage = false
        firstPageTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let response = try await pexelsApi.curatedPhotos(page: 1, pageSize: 20)
                guard !Task.isCancelled else { return }
                self.previousResponse = response.content
                self.photos = response.content.photos
            } catch {
                self.alertViewModel.showAlert(for: error)
            }
            self.isLoadingFirstPage = false
        }
    }
    
    /// Fetches the next page of photos if available.
    private func fetchNextPageOfUsers() {
        guard isLoadingFirstPage == false,
              !isFetchingNextPage,
              let previousResponse,
              previousResponse.nextPage != nil else { return }
        isFetchingNextPage = true
        nextPageTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await pexelsApi.nextPage(for: previousResponse)
                guard !Task.isCancelled else { return }
                
                // Pexelator API can sometimes return the same photo on two different pages. As a quick fix, we will filter out those duplicates on the client.
                let photoIds = Set(self.photos.map({ $0.id }))
                let validPhotos = response.content.photos.filter({ !photoIds.contains($0.id) })
                
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.previousResponse = response.content
                    self.photos += validPhotos
                }
            } catch {
                self.alertViewModel.showAlert(for: error)
            }
            await MainActor.run {
                self.isFetchingNextPage = false
            }
        }
    }
    
}
