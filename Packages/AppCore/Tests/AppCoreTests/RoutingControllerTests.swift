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
