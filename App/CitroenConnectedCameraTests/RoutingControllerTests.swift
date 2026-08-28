import CoreConnectivity
import CoreDomain
import FeatureOnboarding
import Testing
@testable import CitroenConnectedCamera

@MainActor
@Test func controllerDrivesCoordinatorFromInputs() {
	let coordinator = RootCoordinator()
	let controller = RoutingController(coordinator: coordinator, flags: OnboardingFlags())
	#expect(coordinator.destination == .onboarding(.welcome))

	controller.handle(.flagsUpdated(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true)))
	#expect(coordinator.destination == .onboarding(.locationPermission))

	controller.update(locationStatus: .denied)
	#expect(coordinator.destination == .onboarding(.connectWiFi))

	controller.ingest(ConnectivitySnapshot(isReachable: true, setupComplete: false))
	#expect(coordinator.destination == .onboarding(.setPassword))
}

@MainActor
@Test func reconnectFinishedReleasesThePasswordPin() {
	let coordinator = RootCoordinator()
	let controller = RoutingController(
		coordinator: coordinator,
		flags: OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))

	controller.handle(.passwordChanged)
	#expect(coordinator.destination == .onboarding(.reconnect))

	controller.handle(.connectivityUpdated(ConnectivitySnapshot(isReachable: true, setupComplete: true)))
	#expect(coordinator.destination == .onboarding(.reconnect))	// still pinned by the flag

	controller.handle(.reconnectFinished)
	#expect(coordinator.destination == .gallery)				// pin released, setup routes on
}

@MainActor
@Test func connectivityUpdatedActionMatchesDirectIngest() {
	let reachable = ConnectivitySnapshot(isReachable: true, setupComplete: true)
	let viaAction = RootCoordinator()
	let viaIngest = RootCoordinator()
	let flags = OnboardingFlags(hasCompletedOnboarding: true)

	RoutingController(coordinator: viaAction, flags: flags).handle(.connectivityUpdated(reachable))
	RoutingController(coordinator: viaIngest, flags: flags).ingest(reachable)

	// The gallery's poll uses `ingest` directly while the onboarding flow reports an action; both
	// have to land on the same destination or the app would flip between them.
	#expect(viaAction.destination == viaIngest.destination)
	#expect(viaAction.destination == .gallery)
}
