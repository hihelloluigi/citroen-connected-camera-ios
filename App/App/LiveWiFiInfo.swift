import NetworkExtension
import AppCore

/// Live SSID reader via `NEHotspotNetwork`. Requires the Access Wi‑Fi Information entitlement and
/// When‑In‑Use Location authorization; returns `nil` when either is missing. Verified on device — the
/// hotspot API returns nothing in the simulator/CLI.
struct LiveWiFiInfo: WiFiInfoService {
    func currentSSID() async -> String? {
        await NEHotspotNetwork.fetchCurrent()?.ssid
    }
}
