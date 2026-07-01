import Foundation

/// The camera's hardware and firmware identity, as reported during `initialConnection`.
public struct DeviceInfo: Sendable, Equatable, Decodable {
    /// The camera's own Wi-Fi network name.
    public let wifiSSID: String
    /// Firmware version number.
    public let firmware: Int
    /// VIRB Image Manager (VIM) protocol version the camera speaks.
    public let vimVersion: Int
    /// The camera's part/model number.
    public let partNumber: String
    /// Unique numeric identifier for this camera unit.
    public let deviceId: Int64
}
