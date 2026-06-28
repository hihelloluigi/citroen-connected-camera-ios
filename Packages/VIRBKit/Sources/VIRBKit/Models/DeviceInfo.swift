import Foundation

public struct DeviceInfo: Sendable, Equatable, Decodable {
    public let wifiSSID: String
    public let firmware: Int
    public let vimVersion: Int
    public let partNumber: String
    public let deviceId: Int64
}
