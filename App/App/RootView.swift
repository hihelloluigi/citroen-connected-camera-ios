//
//  RootView.swift
//  CitroenConnectedCamera
//

import CoreConnectivity
import FeatureGallery
import FeatureOnboarding
import SwiftUI

/// Renders whichever root destination the coordinator is on, by asking that feature's builder for
/// it. The shell composes; it doesn't construct a single ViewModel of its own.
struct RootView: View {
	let coordinator: RootCoordinator
	let composition: AppComposition

	var body: some View {
		switch coordinator.destination {
		case .onboarding(let step):
			OnboardingBuilder.build(
				step: step,
				dependencies: composition.onboardingDependencies,
				onAction: { [routing = composition.routing] action in routing.handle(action) }
			)
		case .gallery:
			GalleryBuilder.build(
				repository: composition.galleryRepository,
				photoSaver: composition.photoSaver,
				onPoll: {
					await composition.connectivity.refresh()
					composition.routing.ingest(composition.connectivity.snapshot)
				}
			)
		}
	}
}
