import Foundation
@testable import FeatureGallery

/// Scriptable `GalleryRepositoryProtocol` for view-model tests. Returns scripted values or throws
/// scripted errors, and records the mutations the view models perform.
final class FakeGalleryRepository: GalleryRepositoryProtocol, @unchecked Sendable {
	// MARK: - Stored Properties

	var mediaResult: [MediaEntity] = []
	var mediaError: (any Error)?
	var statusResult: CameraStatusEntity?
	var statusError: (any Error)?
	var deviceResult: DeviceInfoEntity?
	var snapshotResult: MediaEntity?
	var snapshotError: (any Error)?
	var deleteError: (any Error)?
	var downloadError: (any Error)?
	private(set) var deletedBatches: [[MediaEntity]] = []
	private(set) var downloadedNames: [String] = []

	// MARK: - Reads

	func media() async throws -> [MediaEntity] {
		if let mediaError { throw mediaError }

		return mediaResult
	}

	func status() async throws -> CameraStatusEntity {
		if let statusError { throw statusError }

		return statusResult ?? CameraStatusEntity(needsFormat: false, hasGPSFix: false)
	}

	func device() async throws -> DeviceInfoEntity {
		deviceResult ?? DeviceInfoEntity(
			firmware: 200,
			partNumber: "006-B2465-00",
			deviceId: 1_234_567_890
		)
	}

	// MARK: - Mutations

	func snapshot() async throws -> MediaEntity {
		if let snapshotError { throw snapshotError }

		return snapshotResult ?? MediaFactory.item(name: "SNAP.JPG", kind: .photo)
	}

	func delete(_ items: [MediaEntity]) async throws {
		if let deleteError { throw deleteError }

		deletedBatches.append(items)

		let ids = Set(items.map(\.id))
		mediaResult.removeAll { ids.contains($0.id) }
	}

	func download(
		_ item: MediaEntity,
		to destination: URL,
		progress: @escaping @Sendable (Double) -> Void
	) async throws -> URL {
		if let downloadError { throw downloadError }

		progress(1)
		downloadedNames.append(item.name)

		return destination
	}
}
