//
//  GalleryBuilder.swift
//  FeatureGallery
//

import SwiftUI

/// The feature's entry point: assembles the gallery flow — coordinator, navigation stack, grid, and
/// the detail screen it pushes — and hands the app shell back a single `View`.
///
/// `onPoll` is the seam that keeps the camera session alive without the feature knowing anything
/// about app-level routing: the flow calls it on a timer, and the app shell decides what a refreshed
/// connectivity snapshot means for the root destination.
public enum GalleryBuilder {
	@MainActor
	public static func build(repository: any GalleryRepositoryProtocol,
							 photoSaver: any PhotoLibrarySaverProtocol,
							 onPoll: @escaping @MainActor () async -> Void) -> some View {
		GalleryFlowView(repository: repository, photoSaver: photoSaver, onPoll: onPoll)
	}
}

/// Hosts the gallery flow. Owns `MediaListViewModel` and `GalleryCoordinator` in `@State` so both
/// survive the app shell re-evaluating its body — the connectivity poll below reassigns the root
/// destination every 3s, which `@Observable` reports as a change even when the value is unchanged.
/// Without `@State` a fresh, unloaded view model would be allocated every poll and the grid would
/// spin forever.
private struct GalleryFlowView: View {
	private let repository: any GalleryRepositoryProtocol
	private let photoSaver: any PhotoLibrarySaverProtocol
	private let onPoll: @MainActor () async -> Void

	@State private var coordinator = GalleryCoordinator()
	@State private var listModel: MediaListViewModel

	init(repository: any GalleryRepositoryProtocol,
		 photoSaver: any PhotoLibrarySaverProtocol,
		 onPoll: @escaping @MainActor () async -> Void) {
		self.repository = repository
		self.photoSaver = photoSaver
		self.onPoll = onPoll
		// The coordinator is created here rather than injected so the handler can close over it;
		// `@State`'s wrapped value is assigned once, on first body evaluation.
		let coordinator = GalleryCoordinator()
		_coordinator = State(wrappedValue: coordinator)
		_listModel = State(wrappedValue: MediaListViewModel(
			repository: repository,
			photoSaver: photoSaver,
			onAction: { [weak coordinator] action in coordinator?.handle(action) }
		))
	}

	var body: some View {
		NavigationStack(path: $coordinator.path) {
			MediaListBuilder.build(model: listModel, repository: repository)
				.navigationDestination(for: MediaEntity.self) { item in
					MediaDetailBuilder.build(
						item: item,
						repository: repository,
						photoSaver: photoSaver,
						onDelete: {
							listModel.remove(id: item.id)
							coordinator.popToRoot()
						}
					)
				}
		}
		.task {
			while !Task.isCancelled {
				// Never interrupt an in-flight download with a session probe.
				if !listModel.isDownloading {
					await onPoll()
				}
				// 3s matches the original app's periodicUpdate cadence; the camera's session
				// timeout is unknown, so the observed heartbeat rate is the only known-good one.
				try? await Task.sleep(for: .seconds(3))
			}
		}
	}
}
