import Testing
@testable import AppCore

@MainActor
@Test func environmentBuildsRoutingControllerFromStoredFlags() {
    let store = InMemoryFlagsStore(OnboardingFlags(hasCompletedOnboarding: true))
    let coordinator = AppCoordinator()
    let env = AppEnvironment(
        camera: MockVIRBClient(), phoneId: "P",
        flagsStore: store, permissions: MockPermissionsService(),
        wifiInfo: MockWiFiInfoService(),
        connectivity: ConnectivityMonitor(probe: StubReachabilityProbe()),
        coordinator: coordinator)
    // A completed-onboarding user with no camera routes to reconnect at launch.
    #expect(coordinator.destination == .reconnect)
    #expect(env.routing.flags.hasCompletedOnboarding == true)
}
