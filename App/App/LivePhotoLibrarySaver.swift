import Foundation
import Photos
import AppCore
import VIRBKit

/// Live save-to-Photos via `PHPhotoLibrary`. Verified on device — the add-to-library authorization
/// prompt and the library don't exist in the CLI/simulator.
struct LivePhotoLibrarySaver: PhotoLibrarySaver {
    func save(fileAt url: URL, kind: MediaItem.Kind) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let type: PHAssetResourceType = (kind == .video) ? .video : .photo
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: type, fileURL: url, options: nil)
        }
    }
}
