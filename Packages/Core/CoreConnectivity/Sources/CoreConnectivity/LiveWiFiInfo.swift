#if os(iOS)
import NetworkExtension

/// Live SSID reader via `NEHotspotNetwork`. Requires the Access Wi‑Fi Information entitlement and
/// When‑In‑Use Location authorization; returns `nil` when either is missing. Verified on device — the
/// hotspot API returns nothing in the simulator/CLI.
public struct LiveWiFiInfo: WiFiInfoService {
	public init() {}

	public func currentSSID() async -> String? {
		await NEHotspotNetwork.fetchCurrent()?.ssid
	}
}
#endif
