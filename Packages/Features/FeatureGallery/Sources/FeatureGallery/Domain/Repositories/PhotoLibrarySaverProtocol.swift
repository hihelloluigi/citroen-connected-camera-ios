import Foundation

/// Saves a downloaded camera file into the user's photo library. Behind a protocol so the download
/// orchestration is testable without touching Photos.
public protocol PhotoLibrarySaverProtocol: Sendable {
	func save(fileAt url: URL, kind: MediaEntity.Kind) async throws
}
