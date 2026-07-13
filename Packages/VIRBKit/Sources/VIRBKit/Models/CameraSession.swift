import Foundation

/// The result of `VIRBClient.connect()`: the camera's setup state and identity.
public struct CameraSession: Sendable, Equatable {
	/// Whether the camera has completed its first-time setup wizard.
	public let isSetupComplete: Bool
	/// The phone ID the camera currently treats as active, if any phone is paired.
	public let activePhoneId: String?
	/// The connected camera's hardware/firmware identity.
	public let device: DeviceInfo

	public init(isSetupComplete: Bool, activePhoneId: String?, device: DeviceInfo) {
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
