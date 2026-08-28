# FeatureGallery

The media grid and the detail screen, over one repository.

## Invariants

**`GalleryRepository` is the only type here that sees a DTO.** Everything above it speaks entities.
A ViewModel importing `CoreCamera` is the smell this boundary exists to prevent.

**The entities are narrower than the wire shapes on purpose.** `MediaEntity` drops `sessionId` and
`videoType`; `CameraStatusEntity` keeps two of `CameraStatusDTO`'s eleven fields. A field the UI
never shows is a field the UI cannot accidentally start depending on — and widening an entity later
is a deliberate act, where passing the DTO through would have been an accident.

**The camera addresses an item by its `url`.** `delete` and `download` reconstruct a minimal DTO
from the entity rather than caching one between calls, so the url has to survive the round trip
exactly. `GalleryRepositoryTests` covers that.

**Deletion is optimistic and reconciles.** Selected items leave the grid immediately, the delete is
confirmed against the camera, then a fresh `refresh()` reconciles. On failure the previous grid is
restored and the error surfaced — the grid never quietly diverges from the card.

**The poll must not run during a download.** `GalleryFlowView`'s loop skips its tick while
`isDownloading`, because a session probe mid-transfer is what makes a large file fail.

**The flow view owns its ViewModel and coordinator in `@State`.** The shell reassigns its root
destination every 3s and `@Observable` reports that as a change even when the value is unchanged;
without `@State` a fresh, unloaded view model would be allocated on every poll and the grid would
spin forever. That shipped once.

**A tap in select mode navigates nowhere.** `select(_:)` guards on `isSelecting` — pushing a detail
screen under a user who is mid-multi-select is the bug the guard prevents, and it is tested.

**The detail screen emits no navigation action.** Its only exit is a dismissal, which
`@Environment(\.dismiss)` already handles; routing a `DismissTapped` case through the coordinator
would add a hop that changes nothing. `onDelete` is not navigation — it tells the grid behind it to
drop a row it no longer has.
