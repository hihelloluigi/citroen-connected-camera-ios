import FeatureGallery
import Foundation

/// Recording `PhotoLibrarySaverProtocol` for view-model tests.
final class FakePhotoLibrarySaver: PhotoLibrarySaverProtocol, @unchecked Sendable {
	// MARK: - Stored Properties

	var saveError: (any Error)?
	private(set) var savedNames: [String] = []

	// MARK: - PhotoLibrarySaverProtocol

	func save(fileAt url: URL, kind: MediaEntity.Kind) async throws {
		if let saveError { throw saveError }

		savedNames.append(url.lastPathComponent)
	}
}
