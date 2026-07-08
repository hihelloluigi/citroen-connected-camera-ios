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
		// A password change kicks clients off the Wi‑Fi; keep routing to Reconnect (rejoin with the new
		// password) until the caller clears this flag after a successful reconnect — even while unreachable.
		if input.didJustChangePassword { return .reconnect }
		if !input.isReachable { return .connectWiFi }
		switch input.setupComplete {
		case .none: return .connectWiFi
		case .some(false): return .setPassword
		case .some(true): return .gallery
		}
	}
}
