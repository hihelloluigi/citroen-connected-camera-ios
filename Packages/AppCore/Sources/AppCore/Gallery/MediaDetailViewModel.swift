import Foundation
import Observation
import VIRBKit

/// Drives one media item's detail screen: save to Photos, delete, and prepare a file for the share
/// sheet. Pure of SwiftUI/AVKit so it unit-tests under `swift test`.
@MainActor
@Observable
public final class MediaDetailViewModel {
    public let item: MediaItem
    private let service: any GalleryService
    private let photoSaver: any PhotoLibrarySaver
    public private(set) var isSaving = false
    public private(set) var didSaveToPhotos = false
    public private(set) var actionError: UserFacingError?

    public init(item: MediaItem, service: any GalleryService, photoSaver: any PhotoLibrarySaver) {
        self.item = item
        self.service = service
        self.photoSaver = photoSaver
    }

    public func clearActionError() { actionError = nil }

    /// Downloads the full file to a temp location, then adds it to the photo library.
    public func saveToPhotos() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent(item.name)
            _ = try await service.download(item, to: destination) { _ in }
            try await photoSaver.save(fileAt: destination, kind: item.kind)
            didSaveToPhotos = true
        } catch {
            actionError = UserFacingError(error)
        }
    }

    /// Deletes this item. Returns `true` on success so the view can pop back to the list.
    public func delete() async -> Bool {
        do {
            try await service.delete([item])
            return true
        } catch {
            actionError = UserFacingError(error)
            return false
        }
    }

    /// Downloads the file to a temp location for the system share sheet, returning its local URL.
    public func prepareShareURL() async -> URL? {
        do {
            let destination = FileManager.default.temporaryDirectory.appendingPathComponent(item.name)
            return try await service.download(item, to: destination) { _ in }
        } catch {
            actionError = UserFacingError(error)
            return nil
        }
    }
}
