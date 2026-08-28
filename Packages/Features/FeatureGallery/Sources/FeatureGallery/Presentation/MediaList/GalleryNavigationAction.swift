/// Navigation events emitted by `MediaListViewModel`. One case: everything else the grid does
/// changes state on the screen the user is already on.
public enum GalleryNavigationAction: Sendable, Equatable {
	case mediaTapped(MediaEntity)
}
