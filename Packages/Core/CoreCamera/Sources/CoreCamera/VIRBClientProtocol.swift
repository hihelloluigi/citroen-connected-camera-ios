import Foundation

/// The contract that the camera client satisfies. All methods execute their network work
/// asynchronously and throw on camera-reported errors or connectivity failures.
public protocol VIRBClientProtocol: Sendable {
	/// Registers this phone with the camera and returns the resulting session.
	func connect() async throws -> CameraSessionDTO

	/// Registers this phone as the active controller so the camera accepts commands.
	func activate() async throws

	/// Returns the camera's current operational status.
	func status() async throws -> CameraStatusDTO

	/// Returns the list of media items stored on the camera's SD card.
	func mediaList() async throws -> [MediaItemDTO]

	/// Triggers the camera shutter and returns the captured photo item.
	func snapPicture() async throws -> MediaItemDTO

	/// Deletes the given media items from the camera's SD card.
	func delete(_ items: [MediaItemDTO]) async throws

	/// Changes the camera's Wi-Fi password.
	func setWiFiPassword(current: String, new: String) async throws

	/// Downloads a media item to the given local URL, reporting progress via the optional closure.
	func download(_ item: MediaItemDTO, to destination: URL,
				  progress: (@Sendable (Double) -> Void)?) async throws -> URL

	/// Returns `true` if the camera is reachable at its current base URL.
	func isReachable() async -> Bool
}
