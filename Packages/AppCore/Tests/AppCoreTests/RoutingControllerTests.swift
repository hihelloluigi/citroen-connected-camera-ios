import Testing
@testable import AppCore

@MainActor
@Test func controllerDrivesCoordinatorFromInputs() {
	let coordinator = AppCoordinator()
	let controller = RoutingController(coordinator: coordinator, flags: OnboardingFlags())
	#expect(coordinator.destination == .welcome)

	controller.update(flags: OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true))
	#expect(coordinator.destination == .locationPermission)

	controller.update(locationStatus: .denied)
	#expect(coordinator.destination == .connectWiFi)

	controller.ingest(ConnectivitySnapshot(isReachable: true, setupComplete: false))
	#expect(coordinator.destination == .setPassword)
}

@MainActor
@Test func clearPasswordChangedRoutesPastReconnect() {
	let coordinator = AppCoordinator()
	let controller = RoutingController(
		coordinator: coordinator,
		flags: OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	controller.markPasswordChanged()
	#expect(coordinator.destination == .reconnect)

	controller.ingest(ConnectivitySnapshot(isReachable: true, setupComplete: true))
	#expect(coordinator.destination == .reconnect) // still pinned to reconnect by the flag

	controller.clearPasswordChanged()
	#expect(coordinator.destination == .gallery)   // flag cleared → setupComplete routes on
}
