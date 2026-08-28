import CoreConnectivity

/// Scriptable `WiFiInfoService` for view-model tests: returns `ssid` (default `nil`).
final class MockWiFiInfoService: WiFiInfoService, @unchecked Sendable {
	// MARK: - Stored Properties

	var ssid: String?

	// MARK: - Init

	init(ssid: String? = nil) {
		self.ssid = ssid
	}

	// MARK: - WiFiInfoService

	func currentSSID() async -> String? { ssid }
}
