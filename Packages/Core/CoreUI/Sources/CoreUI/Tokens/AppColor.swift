import SwiftUI

/// The app's semantic color tokens. Each resolves adaptively for light and dark. Screens reference
/// these by role (background, accent, danger…), never raw hex, so the whole app restyles from here.
public enum AppColor {
	/// The brand periwinkle, in one place so every accent role stays in the same hue family.
	/// Internal rather than private so `TokenTests` can pin the literal.
	static let brandHex = "#C7C8E5"

	// Surfaces
	public static let background = Color(light: Color(hex: "#F7F6F3"), dark: Color(hex: "#0E1116"))
	public static let surface = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#171B22"))
	public static let surfaceElevated = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1F242D"))
	// Text
	public static let textPrimary = Color(light: Color(hex: "#1A1D22"), dark: Color(hex: "#E6E9EF"))
	public static let textSecondary = Color(light: Color(hex: "#6B7280"), dark: Color(hex: "#8A93A2"))
	// Signal
	/// Filled brand surfaces — primary button, badges. The brand color unchanged in both modes: it is
	/// light enough to carry `onAccent` at ~9.8:1, and too light to read as a foreground on a light
	/// background, which is what `accentEmphasis` is for.
	public static let accent = Color(light: Color(hex: brandHex), dark: Color(hex: brandHex))
	/// Text and icons drawn on top of `accent`. Near-black in the brand hue, in both modes.
	public static let onAccent = Color(light: Color(hex: "#1E2033"), dark: Color(hex: "#1E2033"))
	/// The brand color in its foreground role — accent-tinted labels, icons, outlines and spinners drawn
	/// straight onto `background`/`surface`. Darkened for light mode (7.1:1 on `background`); in dark
	/// mode it is the brand color itself, so an `accentEmphasis` outline on `accent` vanishes there.
	public static let accentEmphasis = Color(light: Color(hex: "#4A4E8C"), dark: Color(hex: brandHex))
	public static let telemetry = Color(light: Color(hex: "#0B7080"), dark: Color(hex: "#35C4D7"))
	public static let danger = Color(light: Color(hex: "#D93A3F"), dark: Color(hex: "#E5484D"))
	public static let onDanger = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#FFFFFF"))
	// Lines
	public static let separator = Color(light: Color(hex: "#E4E2DD"), dark: Color(hex: "#262B33"))
}
