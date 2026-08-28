//
//  MediaDetailBuilder.swift
//  FeatureGallery
//

import SwiftUI

/// Assembles one media item's detail screen.
///
/// The detail screen's only exit is a dismissal, so it emits no `NavigationAction` —
/// `@Environment(\.dismiss)` already handles that correctly, and routing a `DismissTapped` case back
/// through the coordinator would add a hop that changes nothing. `onDelete` is not navigation: it
/// tells the grid behind it to drop the row it no longer has.
public enum MediaDetailBuilder {
	@MainActor
	public static func build(item: MediaEntity,
							 repository: any GalleryRepositoryProtocol,
							 photoSaver: any PhotoLibrarySaverProtocol,
							 onDelete: @escaping () -> Void) -> some View {
		MediaDetailView(
			model: MediaDetailViewModel(item: item, repository: repository, photoSaver: photoSaver),
			onDelete: onDelete
		)
	}
}
