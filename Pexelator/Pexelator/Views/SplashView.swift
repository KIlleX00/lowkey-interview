import SwiftUI
import Lottie

struct SplashView: View {
    
    @StateObject var viewModel: SplashViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
            LottieView(animation: .named("logo_text_animation"))
                .playbackMode(viewModel.logoPlaybackMode)
                .animationDidFinish { _ in
                    viewModel.logoAnimationDidFinish()
                }
            ProgressView()
                .progressViewStyle(PexelatorProgressViewStyle(size: .large))
                .opacity(viewModel.progressViewOpacity)
        }
        .onAppear(perform: {
            viewModel.viewDidAppear()
        })
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(pexelsApi: PexelsMockedApi()))
}
