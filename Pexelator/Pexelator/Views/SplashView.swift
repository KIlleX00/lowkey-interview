import SwiftUI
import Lottie

struct SplashView: View {
    
    @StateObject var viewModel: SplashViewModel
    
    var body: some View {
        ZStack {
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
            
            VStack {
                Spacer()
                Button(action: viewModel.preloadData, label: {
                    Text("Try Again")
                        .frame(width: 200)
                })
                .buttonStyle(PexelatorButtonStyle())
            }.opacity(viewModel.isTryAgainButtonHidden ? 0.0 : 1.0)
                .animation(.easeOut(duration: 0.2), value: viewModel.isTryAgainButtonHidden)
        }.alert(viewModel: viewModel.alertViewModel)
            .onAppear(perform: {
                viewModel.viewDidAppear()
            })
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(pexelsApi: PexelsMockedApi()))
}
