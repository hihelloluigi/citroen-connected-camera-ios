/// Reads the name (SSID) of the Wi‑Fi network the phone is currently joined to. Returns `nil` when the
/// name is unavailable — Location authorization not granted, or no Wi‑Fi joined — so callers degrade to
/// reachability-only ("Camera detected") rather than showing a blank network name.
public protocol WiFiInfoService: Sendable {
    func currentSSID() async -> String?
}
