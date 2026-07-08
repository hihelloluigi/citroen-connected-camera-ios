import Foundation
import VIRBKit

/// Saves a downloaded camera file into the user's photo library. The app backs this with
/// `PHPhotoLibrary` (needs `NSPhotoLibraryAddUsageDescription`); tests use a recording fake. Kept behind
/// a protocol so the download orchestration is unit-testable without touching Photos.
public protocol PhotoLibrarySaver: Sendable {
	func save(fileAt url: URL, kind: MediaItem.Kind) async throws
}
