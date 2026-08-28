import Foundation

/// The result of `VIRBClient.connect()`: the camera's setup state and identity.
public struct CameraSessionDTO: Sendable, Equatable {
	/// Whether the camera has completed its first-time setup wizard.
	public let isSetupComplete: Bool
	/// The phone ID the camera currently treats as active, if any phone is paired.
	public let activePhoneId: String?
	/// The connected camera's hardware/firmware identity.
	public let device: DeviceInfoDTO

	public init(isSetupComplete: Bool, activePhoneId: String?, device: DeviceInfoDTO) {
		self.isSetupComplete = isSetupComplete
		self.activePhoneId = activePhoneId
		self.device = device
	}
}

/// Raw `initialConnection` response.
struct ConnectResponse: Decodable {
	let result: Int
	let setupComplete: Int
	let activePhoneId: String?
	let deviceInfo: [DeviceInfoDTO]

	static func decode(from data: Data) throws -> ConnectResponse {
		try JSONDecoder.virb.decode(ConnectResponse.self, from: data)
	}

	func session() throws -> CameraSessionDTO {
		guard let device = deviceInfo.first else { throw VIRBError.decoding("missing deviceInfo") }
		return CameraSessionDTO(
			isSetupComplete: setupComplete == 1,
			activePhoneId: activePhoneId,
			device: device
		)
	}
}
