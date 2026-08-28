//
//  AppCompositionTests.swift
//  CitroenConnectedCameraTests
//

import CoreConnectivity
import CoreDomain
import FeatureOnboarding
import Testing
@testable import CitroenConnectedCamera

@MainActor
private func makeComposition(flagsStore: any OnboardingFlagsStore = InMemoryFlagsStore(),
							 coordinator: RootCoordinator = RootCoordinator()) -> AppComposition {
	AppComposition(
		camera: MockVIRBClient(), phoneId: "ABC-123",
		flagsStore: flagsStore, permissions: MockPermissionsService(),
		wifiInfo: MockWiFiInfoService(), galleryRepository: FakeGalleryRepository(),
		photoSaver: FakePhotoLibrarySaver(),
		connectivity: ConnectivityMonitor(probe: StubReachabilityProbe()),
		coordinator: coordinator)
}

@MainActor
@Test func compositionHoldsInjectedDependencies() {
	#expect(makeComposition().phoneId == "ABC-123")
}

@MainActor
@Test func compositionBuildsRoutingControllerFromStoredFlags() {
	let store = InMemoryFlagsStore(OnboardingFlags(hasCompletedOnboarding: true))
	let coordinator = RootCoordinator()

	let composition = makeComposition(flagsStore: store, coordinator: coordinator)

	// A completed-onboarding user whose camera isn't there lands on Reconnect at launch.
	#expect(coordinator.destination == .onboarding(.reconnect))
	#expect(composition.routing.flags.hasCompletedOnboarding == true)
}
