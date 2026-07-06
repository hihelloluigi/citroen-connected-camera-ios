/// The onboarding flag mutations the screens trigger. Each persists the new flags and pushes them into
/// routing, so a tap both survives relaunch and moves the flow forward. Pure of any UI.
@MainActor
public final class OnboardingActions {
    private let store: any OnboardingFlagsStore
    private let routing: RoutingController

    public init(store: any OnboardingFlagsStore, routing: RoutingController) {
        self.store = store
        self.routing = routing
    }

    public func markGetStarted() { mutate { $0.hasTappedGetStarted = true } }
    public func markLocalNetworkResolved() { mutate { $0.localNetworkResolved = true } }
    public func markLocationResolved() { mutate { $0.locationResolved = true } }

    private func mutate(_ change: (inout OnboardingFlags) -> Void) {
        var flags = store.load()
        change(&flags)
        store.save(flags)
        routing.update(flags: flags)
    }
}
