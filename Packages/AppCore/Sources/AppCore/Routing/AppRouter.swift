/// Pure onboarding/routing state machine. Total function: every `RoutingInput` yields exactly one
/// destination, so the coordinator never has to guess. Unit-tested exhaustively.
public enum AppRouter {
    public static func destination(for input: RoutingInput) -> AppDestination {
        if input.hasCompletedOnboarding {
            return (input.isReachable && input.setupComplete == true) ? .gallery : .reconnect
        }
        if !input.hasTappedGetStarted { return .welcome }
        if !input.localNetworkResolved { return .localNetworkPermission }
        if !input.locationResolved { return .locationPermission }
        if !input.isReachable { return .connectWiFi }
        if input.didJustChangePassword { return .reconnect }
        switch input.setupComplete {
        case .none: return .connectWiFi
        case .some(false): return .setPassword
        case .some(true): return .gallery
        }
    }
}
