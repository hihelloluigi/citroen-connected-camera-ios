import Foundation

public struct CameraStatus: Sendable, Equatable {
    public let activePhoneId: String?
    public let primaryPhoneId: String?
    public let numberOfConnections: Int
    public let saveVideoDuration: Int
    public let needsFormat: Bool
    public let incidentDetected: Bool
    public let faultDescription: String
    public let gpsLatitude: Double?
    public let gpsLongitude: Double?
}

/// Raw `periodicUpdate` response.
struct StatusResponse: Decodable {
    let result: Int
    let activePhoneId: String?
    let primaryPhoneId: String?
    let numberOfConnections: Int
    let saveVideoDuration: Int
    let needFormat: Int
    let incidentDetected: Int
    let faultDescription: String
    let gpsLatitude: Double?
    let gpsLongitude: Double?

    static func decode(from data: Data) throws -> StatusResponse {
        try JSONDecoder.virb.decode(StatusResponse.self, from: data)
    }

    func status() -> CameraStatus {
        CameraStatus(
            activePhoneId: activePhoneId,
            primaryPhoneId: primaryPhoneId,
            numberOfConnections: numberOfConnections,
            saveVideoDuration: saveVideoDuration,
            needsFormat: needFormat == 1,
            incidentDetected: incidentDetected == 1,
            faultDescription: faultDescription,
            gpsLatitude: gpsLatitude,
            gpsLongitude: gpsLongitude
        )
    }
}
