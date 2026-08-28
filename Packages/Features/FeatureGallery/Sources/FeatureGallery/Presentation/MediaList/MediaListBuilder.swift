import SwiftUI

/// Assembles the media grid: its ViewModel, the device-details loader the status header needs, and
/// the handler its navigation actions go to.
public enum MediaListBuilder {
	@MainActor
	public static func build(model: MediaListViewModel,
							 repository: any GalleryRepositoryProtocol) -> some View {
		MediaListView(model: model, loadDevice: { try? await repository.device() })
	}
}
