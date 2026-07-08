import Foundation
import Observation
import VIRBKit

/// Drives the media grid. Holds the loaded items as the source of truth (the view groups them into date
/// sections for display) plus the camera status for the header. Pure of SwiftUI so it unit-tests under
/// `swift test`. Extended in later tasks with selection, snapshot, delete, and download.
@MainActor
@Observable
public final class MediaListViewModel {
    private let service: any GalleryService
    private let photoSaver: any PhotoLibrarySaver
    public private(set) var state: LoadState<[MediaItem]> = .idle
    public private(set) var status: CameraStatus?
    public private(set) var isSelecting = false
    public private(set) var selection: Set<String> = []
    public private(set) var actionError: UserFacingError?
    public private(set) var isDownloading = false
    public private(set) var downloadingIDs: Set<String> = []

    public init(service: any GalleryService, photoSaver: any PhotoLibrarySaver) {
        self.service = service
        self.photoSaver = photoSaver
    }

    /// The currently-loaded items, or empty when idle/loading/failed.
    public var items: [MediaItem] {
        if case .loaded(let items) = state { return items }
        return []
    }

    /// Initial load: shows a spinner (unless content is already present), then refreshes.
    public func load() async {
        if case .loaded = state {} else { state = .loading }
        await refresh()
    }

    /// Reloads media and status. Keeps existing content on failure (pull-to-refresh shouldn't blank the
    /// grid); only an empty grid flips to `.failed`. Status is best-effort — a status hiccup never hides
    /// the media.
    public func refresh() async {
        do {
            let media = try await service.media()
            status = try? await service.status()
            state = .loaded(media)
        } catch {
            if items.isEmpty { state = .failed(UserFacingError(error)) }
        }
    }

    /// Enters or leaves multi-select mode. Leaving clears any in-progress selection.
    public func setSelecting(_ on: Bool) {
        isSelecting = on
        if !on { selection.removeAll() }
    }

    /// Toggles membership of `id` in the current selection. A no-op outside select mode.
    public func toggle(_ id: String) {
        guard isSelecting else { return }
        if selection.contains(id) { selection.remove(id) } else { selection.insert(id) }
    }

    /// Clears the last action error (e.g. once the user has dismissed the alert).
    public func clearActionError() { actionError = nil }

    /// Removes an item from the loaded grid locally (e.g. after it was deleted on the detail screen).
    public func remove(id: String) {
        guard case .loaded(let items) = state else { return }
        state = .loaded(items.filter { $0.id != id })
    }

    /// Triggers the shutter; the new photo animates in at the front of the grid.
    public func snapshot() async {
        do {
            let item = try await service.snapshot()
            state = .loaded([item] + items)
        } catch {
            actionError = UserFacingError(error)
        }
    }

    /// Removes the selected items from the grid immediately, then confirms with the camera and reconciles
    /// by refreshing. If the camera rejects it, the previous grid is restored and the error surfaced.
    public func deleteSelected() async {
        let targets = items.filter { selection.contains($0.id) }
        guard !targets.isEmpty else { return }
        let previous = items
        state = .loaded(items.filter { !selection.contains($0.id) })
        selection.removeAll()
        isSelecting = false
        do {
            try await service.delete(targets)
            await refresh()
        } catch {
            state = .loaded(previous)
            actionError = UserFacingError(error)
        }
    }

    /// Downloads each selected item to a temp file and saves it into the photo library, marking each item
    /// as in-flight for the duration of its own download. A failure on one item surfaces the error and
    /// moves on to the rest. The kit currently reports completion only (no real fractional progress), so
    /// the marker is a simple in-flight flag rather than a percentage.
    public func downloadSelected() async {
        let targets = items.filter { selection.contains($0.id) }
        guard !targets.isEmpty else { return }
        isDownloading = true
        for item in targets {
            downloadingIDs.insert(item.id)
            do {
                let destination = FileManager.default.temporaryDirectory.appendingPathComponent(item.name)
                _ = try await service.download(item, to: destination, progress: { _ in })
                try await photoSaver.save(fileAt: destination, kind: item.kind)
            } catch {
                actionError = UserFacingError(error)
            }
            downloadingIDs.remove(item.id)
        }
        isDownloading = false
        setSelecting(false)
    }
}
