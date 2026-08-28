import FeatureGallery
import Foundation

/// Builds `MediaEntity`s for tests. URLs are placeholder camera URLs; only the fields a test
/// asserts on need be set.
enum MediaFactory {
	// MARK: - Factory

	static func item(
		name: String,
		kind: MediaEntity.Kind = .video,
		date: Date? = nil,
		fileSize: Int64? = 1_000_000,
		gps: (lat: Double, lon: Double)? = nil
	) -> MediaEntity {
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

	// MARK: - Private Helpers

	/// Assembled through `URLComponents` rather than `URL(string:)!` so the factory stays
	/// non-throwing without a force-unwrap.
	private static func cameraURL(path: String) -> URL {
		var components = URLComponents()
		components.scheme = "http"
		components.host = "192.168.0.1"
		components.path = path

		return components.url ?? URL(fileURLWithPath: path)
	}
}
