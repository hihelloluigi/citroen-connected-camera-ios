import Foundation
@testable import FeatureGallery

/// Recording PhotoLibrarySaverProtocol for view-model tests.
final class FakePhotoLibrarySaver: PhotoLibrarySaverProtocol, @unchecked Sendable {
	var saveError: (any Error)?
	private(set) var savedNames: [String] = []
	func save(fileAt url: URL, kind: MediaEntity.Kind) async throws {
		if let saveError { throw saveError }
		savedNames.append(url.lastPathComponent)
	}
}
