//
//  GalleryCoordinator.swift
//  FeatureGallery
//

import CoreNavigation
import Observation

/// Owns the gallery's navigation stack: the grid is the root, and each `mediaTapped` pushes that
/// item's detail screen.
///
/// The path holds `MediaEntity` values rather than ids because `navigationDestination(for:)` keys
/// off the pushed value's type, and the detail screen needs the whole item anyway.
@MainActor
@Observable
public final class GalleryCoordinator: Coordinator {
	public var path: [MediaEntity] = []

	public init() {}

	public func handle(_ action: GalleryNavigationAction) {
		switch action {
		case .mediaTapped(let item):
			path.append(item)
		}
	}

	/// Pops back to the grid. Called after the detail screen deletes the item it was showing, since
	/// the screen it would return to no longer has anything to show for it.
	public func popToRoot() {
		path.removeAll()
	}
}
