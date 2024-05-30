import SwiftUI

@main
struct PexelatorApp: App {
    
    let pexelsApi: PexelsApi
    
    init() {
        // Use mocked PexelsApi if we are running in a preview environment
        pexelsApi = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? PexelsMockedApi() : PexelsRestApi()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: RootViewModel(pexelsApi: pexelsApi))
        }
    }
}
