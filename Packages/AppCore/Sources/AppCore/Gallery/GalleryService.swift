import Foundation
import VIRBKit

/// The gallery's single seam over the camera. The live implementation wraps `VIRBClient`; tests use a
/// mock. Keeping every gallery-facing camera call behind one protocol means the view models never touch
/// `VIRBClientProtocol` directly and are fully unit-testable.
public protocol GalleryService: Sendable {
    /// All media currently on the camera's SD card.
    func media() async throws -> [MediaItem]
    /// The camera's current operational status (storage/GPS/active phone).
    func status() async throws -> CameraStatus
    /// The camera's hardware/firmware identity (for the status details sheet).
    func device() async throws -> DeviceInfo
    /// Triggers the shutter and returns the new photo.
    func snapshot() async throws -> MediaItem
    /// Deletes the given items from the SD card.
    func delete(_ items: [MediaItem]) async throws
    /// Downloads an item to `destination`, reporting progress in `0...1`, and returns the local URL.
    func download(_ item: MediaItem, to destination: URL,
                  progress: @escaping @Sendable (Double) -> Void) async throws -> URL
}
