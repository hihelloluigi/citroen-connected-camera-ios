import Foundation
import FeatureGallery

/// Builds `MediaEntity`s for tests. URLs are placeholder camera URLs; only the fields a test asserts on
/// need be set. Uses the public model init from Task 1 — no JSON round-trip.
enum MediaFactory {
	static func item(name: String, kind: MediaEntity.Kind = .video, date: Date? = nil,
					 fileSize: Int64? = 1_000_000,
					 gps: (lat: Double, lon: Double)? = nil) -> MediaEntity {
		MediaEntity(
			kind: kind,
			url: cameraURL(path: "/DCIM/\(name)"),
			thumbURL: cameraURL(path: "/thumb/\(name)"),
			name: name,
			fileSize: fileSize,
			date: date,
			gpsLatitude: gps?.lat,
			gpsLongitude: gps?.lon
		)
	}

	/// The camera's media URL for `path`. Assembled through `URLComponents` rather than
	/// `URL(string:)!` so the factory stays non-throwing without a force-unwrap; a fixed
	/// scheme/host/path always resolves, and the fallback is unreachable in practice.
	private static func cameraURL(path: String) -> URL {
		var components = URLComponents()
		components.scheme = "http"
		components.host = "192.168.0.1"
		components.path = path
		return components.url ?? URL(fileURLWithPath: path)
	}
}
