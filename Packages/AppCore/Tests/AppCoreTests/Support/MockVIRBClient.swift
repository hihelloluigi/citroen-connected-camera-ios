import Foundation
import VIRBKit

/// Scriptable `VIRBClientProtocol` for AppCore tests. Records the camera commands the onboarding
/// flow issues (`setWiFiPassword`, `activate`) and lets a test force a rejection. The read-path
/// methods only need to compile — no test drives them — and deliberately construct no VIRBKit model,
/// whose memberwise initializers are internal to the kit.
final class MockVIRBClient: VIRBClientProtocol, @unchecked Sendable {
	/// When set, `setWiFiPassword` throws this instead of succeeding (e.g. `.passwordRejected`).
	var setWiFiPasswordError: (any Error)?
	/// When set, `activate` throws this instead of succeeding.
	var activateError: (any Error)?
	private(set) var setWiFiPasswordCalls: [(current: String, new: String)] = []
	private(set) var activateCallCount = 0

	func connect() async throws -> CameraSession { throw VIRBError.cameraUnreachable }
	func status() async throws -> CameraStatus { throw VIRBError.cameraUnreachable }
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
