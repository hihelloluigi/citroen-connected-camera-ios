import Observation
import VIRBKit

/// Drives the media grid. Holds the loaded items as the source of truth (the view groups them into date
/// sections for display) plus the camera status for the header. Pure of SwiftUI so it unit-tests under
/// `swift test`. Extended in later tasks with selection, snapshot, delete, and download.
@MainActor
@Observable
public final class MediaListViewModel {
    private let service: any GalleryService
    public private(set) var state: LoadState<[MediaItem]> = .idle
    public private(set) var status: CameraStatus?

    public init(service: any GalleryService) { self.service = service }

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
}
