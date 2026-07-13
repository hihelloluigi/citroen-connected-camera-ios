import Foundation
import VIRBKit

/// Scriptable `VIRBClientProtocol` for AppCore tests. Records the camera commands the onboarding
/// flow issues (`setWiFiPassword`, `activate`), lets a test force a rejection, and scripts the
/// session commands (`connect`, `status`) the reachability probe sends. The remaining read-path
/// methods only need to compile — no test drives them.
final class MockVIRBClient: VIRBClientProtocol, @unchecked Sendable {
	/// When set, `setWiFiPassword` throws this instead of succeeding (e.g. `.passwordRejected`).
	var setWiFiPasswordError: (any Error)?
	/// When set, `activate` throws this instead of succeeding.
	var activateError: (any Error)?
	/// Scripted `connect()` outcome. Defaults to unreachable.
	var connectResult: Result<CameraSession, any Error> = .failure(VIRBError.cameraUnreachable)
	/// Scripted `status()` outcome. Defaults to unreachable.
	var statusResult: Result<CameraStatus, any Error> = .failure(VIRBError.cameraUnreachable)
	private(set) var setWiFiPasswordCalls: [(current: String, new: String)] = []
	private(set) var activateCallCount = 0
	/// Every session command in the order sent — lets a test assert handshake-vs-heartbeat sequencing.
	private(set) var sessionCommands: [String] = []

	func connect() async throws -> CameraSession {
		sessionCommands.append("initialConnection")
		return try connectResult.get()
	}
	func status() async throws -> CameraStatus {
		sessionCommands.append("periodicUpdate")
		return try statusResult.get()
	}
	func activate() async throws {
		activateCallCount += 1
		if let activateError { throw activateError }
	}
	func mediaList() async throws -> [MediaItem] { [] }
	func snapPicture() async throws -> MediaItem { throw VIRBError.cameraUnreachable }
	func delete(_ items: [MediaItem]) async throws {}
	func setWiFiPassword(current: String, new: String) async throws {
		setWiFiPasswordCalls.append((current, new))
		if let setWiFiPasswordError { throw setWiFiPasswordError }
	}
	func download(_ item: MediaItem, to destination: URL,
				  progress: (@Sendable (Double) -> Void)?) async throws -> URL { destination }
	func isReachable() async -> Bool { true }
}

extension CameraSession {
	/// A minimal valid session for probe tests.
	static func stub(setupComplete: Bool = true) -> CameraSession {
		CameraSession(isSetupComplete: setupComplete, activePhoneId: nil,
					  device: DeviceInfo(wifiSSID: "ConnectedCAM0000", firmware: 200,
										 vimVersion: 140, partNumber: "006-B2465-00", deviceId: 1))
	}
}

extension CameraStatus {
	/// A minimal healthy status for probe tests.
	static func stub() -> CameraStatus {
		CameraStatus(activePhoneId: nil, primaryPhoneId: nil, numberOfConnections: 1,
					 saveVideoDuration: 20, needsFormat: false, incidentDetected: false,
					 faultDescription: "No Fault", gpsLatitude: nil, gpsLongitude: nil)
	}
}
