import Testing
@testable import AppCore

@MainActor
@Test func getStartedPersistsFlagAndRoutes() {
    let store = InMemoryFlagsStore()
    let coordinator = AppCoordinator()
    let routing = RoutingController(coordinator: coordinator, flags: store.load())
    let actions = OnboardingActions(store: store, routing: routing)

    actions.markGetStarted()

    #expect(store.load().hasTappedGetStarted == true)     // persisted
    #expect(routing.flags.hasTappedGetStarted == true)    // routing updated
    #expect(coordinator.destination == .localNetworkPermission)
}
