import SwiftUI

/// The app's semantic color tokens. Each resolves adaptively for light and dark. Screens reference
/// these by role (background, accent, danger…), never raw hex, so the whole app restyles from here.
public enum AppColor {
	/// The two greens the app icon is drawn in, in one place so every accent role stays in the
	/// same hue family as the icon. Internal rather than private so `TokenTests` can pin them.
	static let brandHex = "#1DA79B"     // the icon's field
	static let brandDeepHex = "#036E6D" // the icon's road

	// Surfaces
	public static let background = Color(light: Color(hex: "#F7F6F3"), dark: Color(hex: "#0E1116"))
	public static let surface = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#171B22"))
	public static let surfaceElevated = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1F242D"))
	// Text
	public static let textPrimary = Color(light: Color(hex: "#1A1D22"), dark: Color(hex: "#E6E9EF"))
	public static let textSecondary = Color(light: Color(hex: "#6B7280"), dark: Color(hex: "#8A93A2"))
	// Signal
	/// Filled brand surfaces — primary button, badges. The icon's field colour, unchanged in both
	/// modes. It is a mid-tone, which is why `onAccent` is near-black rather than white: white on it
	/// is only 2.98:1 and would fail AA at any size.
	public static let accent = Color(light: Color(hex: brandHex), dark: Color(hex: brandHex))
	/// Text and icons drawn on top of `accent`. Near-black in the brand hue, in both modes — 5.7:1.
	public static let onAccent = Color(light: Color(hex: "#03211F"), dark: Color(hex: "#03211F"))
	/// The brand in its foreground role — accent-tinted labels, icons, outlines and spinners drawn
	/// straight onto `background`/`surface`. Light mode takes the icon's darker road green (5.6:1 on
	/// `background`); dark mode takes the field colour (6.4:1), so an `accentEmphasis` outline on
	/// `accent` reads as a darker edge in light mode and vanishes in dark, where the fill already
	/// separates from the background on its own.
	public static let accentEmphasis = Color(light: Color(hex: brandDeepHex), dark: Color(hex: brandHex))
	/// Deliberately not in the brand hue. Telemetry used to be a teal, which the green brand now
	/// occupies — at 1.05:1 against `accentEmphasis` a speed readout was indistinguishable from an
	/// accent-tinted label. Blue keeps "this is a measurement" separable from "this is actionable".
	public static let telemetry = Color(light: Color(hex: "#0B5FA5"), dark: Color(hex: "#6FB4FF"))
	public static let danger = Color(light: Color(hex: "#D93A3F"), dark: Color(hex: "#E5484D"))
	public static let onDanger = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#FFFFFF"))
	// Lines
	public static let separator = Color(light: Color(hex: "#E4E2DD"), dark: Color(hex: "#262B33"))
}
