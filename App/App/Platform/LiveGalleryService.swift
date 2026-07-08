import Foundation
import AppCore
import VIRBKit

/// Live gallery service backed by the camera client. Verified on device — the CLI/simulator has no
/// camera. `device()` reads the identity returned by `connect()`.
struct LiveGalleryService: GalleryService {
	let client: any VIRBClientProtocol

	func media() async throws -> [MediaItem] { try await client.mediaList() }
	func status() async throws -> CameraStatus { try await client.status() }
	func device() async throws -> DeviceInfo { try await client.connect().device }
	func snapshot() async throws -> MediaItem { try await client.snapPicture() }
	func delete(_ items: [MediaItem]) async throws { try await client.delete(items) }
	func download(_ item: MediaItem, to destination: URL,
				  progress: @escaping @Sendable (Double) -> Void) async throws -> URL {
		try await client.download(item, to: destination, progress: progress)
	}
}
