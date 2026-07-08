import Foundation
import VIRBKit
import AppCore

/// Recording PhotoLibrarySaver for view-model tests.
final class MockPhotoLibrarySaver: PhotoLibrarySaver, @unchecked Sendable {
    var saveError: (any Error)?
    private(set) var savedNames: [String] = []
    func save(fileAt url: URL, kind: MediaItem.Kind) async throws {
        if let saveError { throw saveError }
        savedNames.append(url.lastPathComponent)
    }
}
