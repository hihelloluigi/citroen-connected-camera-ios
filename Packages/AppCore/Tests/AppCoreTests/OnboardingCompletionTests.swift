import Testing
import VIRBKit
@testable import AppCore

@MainActor
@Test func changePasswordSucceedsThenRoutesToReconnect() async throws {
	let store = InMemoryFlagsStore(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	let coordinator = AppCoordinator()
	let routing = RoutingController(coordinator: coordinator, flags: store.load())
	let camera = MockVIRBClient()
	let actions = OnboardingActions(store: store, routing: routing, camera: camera)

	try await actions.changePassword(current: "ConnectedCam", new: "Test1234")

	#expect(camera.setWiFiPasswordCalls.count == 1)
	#expect(camera.setWiFiPasswordCalls.first?.new == "Test1234")
	#expect(coordinator.destination == .reconnect)	 // markPasswordChanged pinned the route
}

@MainActor
@Test func changePasswordRejectedRethrowsAndDoesNotRoute() async {
	let store = InMemoryFlagsStore(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	let coordinator = AppCoordinator()
	let routing = RoutingController(coordinator: coordinator, flags: store.load())
	let camera = MockVIRBClient()
	camera.setWiFiPasswordError = VIRBError.passwordRejected
	let actions = OnboardingActions(store: store, routing: routing, camera: camera)
	routing.ingest(ConnectivitySnapshot(isReachable: true, setupComplete: false)) // already on the password step

	await #expect(throws: VIRBError.passwordRejected) {
		try await actions.changePassword(current: "wrong", new: "Test1234")
	}
	#expect(coordinator.destination == .setPassword) // unchanged — still on the password step
}

@MainActor
@Test func applyConnectivityFinishesOnboardingWhenSetupComplete() async {
	let store = InMemoryFlagsStore(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	let coordinator = AppCoordinator()
	let routing = RoutingController(coordinator: coordinator, flags: store.load())
	let camera = MockVIRBClient()
	let actions = OnboardingActions(store: store, routing: routing, camera: camera)

	await actions.applyConnectivity(ConnectivitySnapshot(isReachable: true, setupComplete: true))

	#expect(camera.activateCallCount == 1)				 // claimed active phone
	#expect(store.load().hasCompletedOnboarding == true) // persisted
	#expect(coordinator.destination == .gallery)
}

@MainActor
@Test func applyConnectivityIsIdempotentAcrossRepeatedPolls() async {
	let store = InMemoryFlagsStore(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	let coordinator = AppCoordinator()
	let routing = RoutingController(coordinator: coordinator, flags: store.load())
	let camera = MockVIRBClient()
	let actions = OnboardingActions(store: store, routing: routing, camera: camera)

	await actions.applyConnectivity(ConnectivitySnapshot(isReachable: true, setupComplete: true))
	await actions.applyConnectivity(ConnectivitySnapshot(isReachable: true, setupComplete: true))

	#expect(camera.activateCallCount == 1)				  // second poll tick must not re-finalize
	#expect(store.load().hasCompletedOnboarding == true)
}

@MainActor
@Test func applyConnectivityRoutesToSetPasswordWhenSetupIncomplete() async {
	let store = InMemoryFlagsStore(OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true, locationResolved: true))
	let coordinator = AppCoordinator()
	let routing = RoutingController(coordinator: coordinator, flags: store.load())
	let camera = MockVIRBClient()
	let actions = OnboardingActions(store: store, routing: routing, camera: camera)

	await actions.applyConnectivity(ConnectivitySnapshot(isReachable: true, setupComplete: false))

	#expect(camera.activateCallCount == 0)				  // no claim until setup is done
	#expect(store.load().hasCompletedOnboarding == false)
	#expect(coordinator.destination == .setPassword)
}
