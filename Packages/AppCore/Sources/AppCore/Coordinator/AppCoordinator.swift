import Observation

/// Owns the current root destination and recomputes it from the latest routing input via `AppRouter`.
/// Views observe `destination`; they never make navigation decisions themselves.
@MainActor
@Observable
public final class AppCoordinator {
    public private(set) var destination: AppDestination

    public init(initial: RoutingInput = RoutingInput()) {
        self.destination = AppRouter.destination(for: initial)
    }

    public func update(with input: RoutingInput) {
        destination = AppRouter.destination(for: input)
    }
}
