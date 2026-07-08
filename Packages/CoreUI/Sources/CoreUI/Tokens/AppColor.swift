import SwiftUI

/// The app's semantic color tokens. Each resolves adaptively for light and dark. Screens reference
/// these by role (background, accent, danger…), never raw hex, so the whole app restyles from here.
public enum AppColor {
	// Surfaces
	public static let background = Color(light: Color(hex: "#F7F6F3"), dark: Color(hex: "#0E1116"))
	public static let surface = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#171B22"))
	public static let surfaceElevated = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#1F242D"))
	// Text
	public static let textPrimary = Color(light: Color(hex: "#1A1D22"), dark: Color(hex: "#E6E9EF"))
	public static let textSecondary = Color(light: Color(hex: "#6B7280"), dark: Color(hex: "#8A93A2"))
	// Signal
	public static let accent = Color(light: Color(hex: "#C77A0E"), dark: Color(hex: "#F5A524"))
	public static let onAccent = Color(light: Color(hex: "#201400"), dark: Color(hex: "#201400"))
	public static let telemetry = Color(light: Color(hex: "#0B7080"), dark: Color(hex: "#35C4D7"))
	public static let danger = Color(light: Color(hex: "#D93A3F"), dark: Color(hex: "#E5484D"))
	public static let onDanger = Color(light: Color(hex: "#FFFFFF"), dark: Color(hex: "#FFFFFF"))
	// Lines
	public static let separator = Color(light: Color(hex: "#E4E2DD"), dark: Color(hex: "#262B33"))
}
