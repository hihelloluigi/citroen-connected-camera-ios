import Foundation

public struct CameraSession: Sendable, Equatable {
    public let isSetupComplete: Bool
    public let activePhoneId: String?
    public let device: DeviceInfo
}

/// Raw `initialConnection` response.
struct ConnectResponse: Decodable {
    let result: Int
    let setupComplete: Int
    let activePhoneId: String?
    let deviceInfo: [DeviceInfo]

    static func decode(from data: Data) throws -> ConnectResponse {
        try JSONDecoder.virb.decode(ConnectResponse.self, from: data)
    }

    func session() throws -> CameraSession {
        guard let device = deviceInfo.first else { throw VIRBError.decoding("missing deviceInfo") }
        return CameraSession(
            isSetupComplete: setupComplete == 1,
            activePhoneId: activePhoneId,
            device: device
        )
    }
}
