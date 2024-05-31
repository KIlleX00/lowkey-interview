import SwiftUI

/// A view that loads an image asynchronously from a URL and caches it.
///
/// Use `CachedAsyncImage` to display an image asynchronously from a URL with caching support. You can provide a content view and a placeholder view to be displayed while the image is being loaded.
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: CachedAsyncImageViewModel
    
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }.onAppear(perform: loader.viewDidAppear)
            .onDisappear(perform: loader.viewDidDisappear)
    }
    
    /// Initializes a `CachedAsyncImage` with a URL, content view, and placeholder view.
    /// - Parameters:
    ///   - url: The URL from which to load the image.
    ///   - content: A closure that provides the content view to display when the image is loaded.
    ///   - placeholder: A closure that provides the placeholder view to display while the image is being loaded.
    init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        _loader = StateObject(wrappedValue: CachedAsyncImageViewModel(url: url))
        self.content = content
        self.placeholder = placeholder
    }
}
