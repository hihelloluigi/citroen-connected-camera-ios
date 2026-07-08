import SwiftUI

public extension Color {
	/// Normalized RGB components in 0...1. A named struct (not a tuple) to satisfy `large_tuple` lint.
	struct RGB: Equatable, Sendable {
		public let r, g, b: Double
	}

	/// Parses a 6-digit hex string ("#RRGGBB" or "RRGGBB") into RGB, or `nil` if malformed.
	static func rgb(hex: String) -> RGB? {
		var digits = Substring(hex)
		if digits.first == "#" { digits = digits.dropFirst() }
		guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
		return RGB(r: Double((value >> 16) & 0xFF) / 255,
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
