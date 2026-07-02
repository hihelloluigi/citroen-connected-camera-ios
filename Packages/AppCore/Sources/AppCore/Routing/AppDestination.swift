/// The single root screen the app shows. Onboarding is a linear, root-replacing flow, so the
/// coordinator drives one destination at a time; feature-internal navigation (e.g. gallery push)
/// uses its own NavigationStack later.
public enum AppDestination: Equatable, Hashable, Sendable {
    case welcome
    case localNetworkPermission
    case locationPermission
    case connectWiFi
    case setPassword
    case reconnect
    case gallery
}
