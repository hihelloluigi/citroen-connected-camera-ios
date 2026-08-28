//
//  GalleryNavigationAction.swift
//  FeatureGallery
//

/// Navigation events emitted by `MediaListViewModel`.
///
/// One case, because the grid has exactly one way out that isn't a dismissal: tapping a cell while
/// not in select mode. Everything else the list does — selecting, deleting, downloading, taking a
/// snapshot — changes state on the screen the user is already on.
public enum GalleryNavigationAction: Sendable, Equatable {
	case mediaTapped(MediaEntity)
}
