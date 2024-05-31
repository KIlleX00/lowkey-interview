import Combine
import SwiftUI

/// ViewModel for handling cached asynchronous image loading.
class CachedAsyncImageViewModel: ObservableObject {
    
    /// Cache for storing images in memory.
    private static let imageCache = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 20
        return cache
    }()
    
    // MARK: - Output
    
    /// Published property to store the loaded image.
    @Published var image: UIImage?
    
    // MARK: - Properties
    
    /// Composite cancellable to store cancellable tasks.
    private let cancellables = CompositeCancellable()
    
    /// URL of the image to be loaded.
    private let url: URL?
    
    /// URL session data task for downloading the image.
    private var task: URLSessionDataTask?
    
    /// Boolean flag to track the visibility of the view.
    private var isVisible = false
    
    // MARK: - Lifecycle
    
    /// Initializes the ViewModel with an optional URL.
    /// - Parameter url: The URL of the image to be loaded.
    init(url: URL?) {
        self.url = url
    }
    
    /// Cancels ongoing tasks when the ViewModel is deallocated.
    deinit {
        cancellables.cancel()
    }
    
    // MARK: - Actions
    
    /// Called when the view appears. Starts the process of loading the image.
    func viewDidAppear() {
        isVisible = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self,
                  let url,
                  image == nil else { return }
            
            if let cachedImage = CachedAsyncImageViewModel.imageCache.object(forKey: url as NSURL) {
                updateImage(cachedImage)
            } else if let cachedImage = self.getCachedImageFromDisk(url: url) {
                CachedAsyncImageViewModel.imageCache.setObject(cachedImage, forKey: url as NSURL)
                updateImage(cachedImage)
            } else {
                downloadImage(from: url)
            }
        }
    }
        
    /// Called when the view disappears. Cancels the image loading task and clears the image.
    func viewDidDisappear() {
        isVisible = false
        task?.cancel()
        image = nil
    }
    
    // MARK: - Utils
    
    /// Updates the image property on the main thread.
    /// - Parameters:
    ///   - image: The new image to be set.
    ///   - animated: Boolean flag indicating whether the update should be animated.
    private func updateImage(_ image: UIImage, animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self, isVisible else { return }
            if animated {
                withAnimation {
                    self.image = image
                }
            } else {
                self.image = image
            }
        }
    }
    
    // MARK: - Data fetch
    
    /// Downloads the image from the specified URL.
    /// - Parameter url: The URL of the image to be downloaded.
    private func downloadImage(from url: URL) {
        task = URLSession.shared.dataTask(with: URLRequest(url: url)) { [weak self] data, _, error in
            guard let self,
                  let data,
                  let image = UIImage(data: data),
                  error == nil else { return }
            
            CachedAsyncImageViewModel.imageCache.setObject(image, forKey: url as NSURL)
            saveImageToDisk(image: image, url: url)
            updateImage(image, animated: true)
        }
        task?.resume()
    }
    
    // MARK: - Disk Cache
    
    /// Retrieves a cached image from disk.
    /// - Parameter url: The URL of the image to be retrieved.
    /// - Returns: The cached image if it exists, otherwise nil.
    private func getCachedImageFromDisk(url: URL) -> UIImage? {
        guard let fileURL = cachedImageUrl(for: url),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        return image.preparingForDisplay() ?? image
    }
    
    /// Saves an image to disk.
    /// - Parameters:
    ///   - image: The image to be saved.
    ///   - url: The URL of the image to be used as a key.
    private func saveImageToDisk(image: UIImage, url: URL) {
        guard let fileURL = cachedImageUrl(for: url),
              let data = image.pngData() else { return }
        try? data.write(to: fileURL)
    }
    
    /// Returns the file URL for a cached image.
    /// - Parameter url: The URL of the image.
    /// - Returns: The file URL for the cached image.
    private func cachedImageUrl(for url: URL) -> URL? {
        let fileName = url.lastPathComponent
        guard let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        return documentsURL.appendingPathComponent(fileName)
    }
}
