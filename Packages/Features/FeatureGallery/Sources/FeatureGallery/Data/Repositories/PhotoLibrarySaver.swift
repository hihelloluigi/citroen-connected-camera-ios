import Foundation
import Photos

/// The live `PhotoLibrarySaverProtocol`, backed by `PHPhotoLibrary`.
///
/// Verified on device — neither the add-to-library authorization prompt nor the library itself
/// exists in the CLI test environment.
public struct PhotoLibrarySaver: PhotoLibrarySaverProtocol {
	public init() {}

	public func save(fileAt url: URL, kind: MediaEntity.Kind) async throws {
		try await PHPhotoLibrary.shared().performChanges {
			let type: PHAssetResourceType = (kind == .video) ? .video : .photo
			let request = PHAssetCreationRequest.forAsset()
			request.addResource(with: type, fileURL: url, options: nil)
		}
	}
}
