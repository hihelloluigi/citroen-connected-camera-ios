import Foundation
import VIRBKit

/// Builds `MediaItem`s for tests. URLs are placeholder camera URLs; only the fields a test asserts on
/// need be set. Uses the public model init from Task 1 — no JSON round-trip.
enum MediaFactory {
	static func item(name: String, kind: MediaItem.Kind = .video, date: Date? = nil,
					 fileSize: Int64? = 1_000_000,
					 gps: (lat: Double, lon: Double)? = nil) -> MediaItem {
		MediaItem(
			kind: kind,
			url: URL(string: "http://192.168.0.1/DCIM/\(name)")!,
			thumbURL: URL(string: "http://192.168.0.1/thumb/\(name)")!,
			name: name,
			fileSize: fileSize,
			date: date,
			gpsLatitude: gps?.lat,
			gpsLongitude: gps?.lon
		)
	}
}
