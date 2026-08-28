import Foundation

/// The gallery's single seam over the camera. Everything above this line speaks in entities; only
/// the implementation in `Data/` knows a DTO exists.
public protocol GalleryRepositoryProtocol: Sendable {
	/// All media currently on the camera's SD card.
	func media() async throws -> [MediaEntity]
	/// The camera's current operational status.
	func status() async throws -> CameraStatusEntity
	/// The camera's hardware/firmware identity, for the status details sheet.
	func device() async throws -> DeviceInfoEntity
	/// Triggers the shutter and returns the new photo.
	func snapshot() async throws -> MediaEntity
	/// Deletes the given items from the SD card.
	func delete(_ items: [MediaEntity]) async throws
	/// Downloads an item to `destination`, reporting progress in `0...1`, and returns the local URL.
	func download(
		_ item: MediaEntity,
		to destination: URL,
		progress: @escaping @Sendable (Double) -> Void
	) async throws -> URL
}
