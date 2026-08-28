import CoreDomain
import Foundation
import Observation

/// Drives one media item's detail screen: save to Photos, delete, and prepare a file for the share
/// sheet. Pure of SwiftUI/AVKit so it unit-tests under `swift test`.
@MainActor
@Observable
public final class MediaDetailViewModel {
	public let item: MediaEntity
	private let repository: any GalleryRepositoryProtocol
	private let photoSaver: any PhotoLibrarySaverProtocol
	public private(set) var isSaving = false
	public private(set) var didSaveToPhotos = false
	public private(set) var actionError: UserFacingError?

	public init(item: MediaEntity, repository: any GalleryRepositoryProtocol,
				photoSaver: any PhotoLibrarySaverProtocol) {
		self.item = item
		self.repository = repository
		self.photoSaver = photoSaver
	}

	public func clearActionError() { actionError = nil }

	/// Downloads the full file to a temp location, then adds it to the photo library.
	public func saveToPhotos() async {
		isSaving = true
		defer { isSaving = false }
		do {
			let destination = FileManager.default.temporaryDirectory.appendingPathComponent(item.name)
			_ = try await repository.download(item, to: destination) { _ in }
			try await photoSaver.save(fileAt: destination, kind: item.kind)
			didSaveToPhotos = true
		} catch {
			actionError = UserFacingError(error)
		}
	}

	/// Deletes this item. Returns `true` on success so the view can pop back to the list.
	public func delete() async -> Bool {
		do {
			try await repository.delete([item])
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
			return try await repository.download(item, to: destination) { _ in }
		} catch {
			actionError = UserFacingError(error)
			return nil
		}
	}
}
