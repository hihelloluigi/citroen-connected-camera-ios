import Foundation

/// Formats raw camera data (coordinates, byte counts) into the compact strings the telemetry
/// treatment renders. Kept here so the whole app reads telemetry the same way.
public enum TelemetryFormatter {
	public static func coordinate(lat: Double, lon: Double) -> String {
		String(format: "%.4f, %.4f", lat, lon)
	}

	public static func bytes(_ count: Int64) -> String {
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		return formatter.string(fromByteCount: count)
	}
}
