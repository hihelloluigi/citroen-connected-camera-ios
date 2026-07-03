import SwiftUI

public extension Color {
    /// Parses a 6-digit hex string ("#RRGGBB" or "RRGGBB") into normalized RGB, or `nil` if malformed.
    static func rgb(hex: String) -> (r: Double, g: Double, b: Double)? {
        var digits = Substring(hex)
        if digits.first == "#" { digits = digits.dropFirst() }
        guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
        return (r: Double((value >> 16) & 0xFF) / 255,
                g: Double((value >> 8) & 0xFF) / 255,
                b: Double(value & 0xFF) / 255)
    }

    /// Builds a color from a 6-digit hex literal. Falls back to loud magenta on a malformed literal
    /// so the mistake is visible in previews — token strings are constants covered by `ColorHexTests`.
    init(hex: String) {
        if let rgb = Color.rgb(hex: hex) {
            self.init(red: rgb.r, green: rgb.g, blue: rgb.b)
        } else {
            self.init(red: 1, green: 0, blue: 1)
        }
    }
}
