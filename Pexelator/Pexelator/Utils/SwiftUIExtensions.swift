import SwiftUI

extension Color {
    /// Initializes a `Color` from a hex string.
    /// - Parameter hex: The hex string representing the color, optionally prefixed with `#`.
    init?(hex: String) {
        // Remove the '#' prefix if it exists
        let hexString = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        
        // Ensure the string has exactly 6 characters
        guard hexString.count == 6,
              let hexNumber = Int(hexString, radix: 16) else {
            return nil
        }
        
        // Extract RGB components
        let red = Double((hexNumber >> 16) & 0xFF) / 255.0
        let green = Double((hexNumber >> 8) & 0xFF) / 255.0
        let blue = Double(hexNumber & 0xFF) / 255.0
        
        // Initialize the color
        self.init(red: red, green: green, blue: blue)
    }
}
