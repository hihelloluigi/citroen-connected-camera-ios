import AppCore

/// Scriptable WiFiInfoService for view-model tests: returns `ssid` (default `nil`).
final class MockWiFiInfoService: WiFiInfoService, @unchecked Sendable {
	var ssid: String?
	init(ssid: String? = nil) { self.ssid = ssid }
	func currentSSID() async -> String? { ssid }
}
