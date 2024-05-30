import SwiftUI

struct PexelatorProgressViewStyle: ProgressViewStyle {
    
    enum Size {
        case medium
        case large
        
        var scale: Double {
            switch self {
                case .medium: return 1.0
                case .large: return 2.0
            }
        }
    }
    
    var color: Color = .pexelatorRed
    var size: Size = .medium

    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .tint(color)
            .scaleEffect(size.scale)
    }
}
