/// Everything the router needs to decide the current screen. The values are resolved facts
/// (permission decisions, reachability, camera setup state); how they're derived from the OS and
/// the camera is the job of the services layer, not the router.
public struct RoutingInput: Equatable, Sendable {
	/// The user finished setup at least once on this device (a persisted local flag).
	public var hasCompletedOnboarding: Bool
	/// The user tapped "Get started" on the welcome screen.
	public var hasTappedGetStarted: Bool
	/// Local Network access has been confirmed (the app has reached the camera at least once).
	public var localNetworkResolved: Bool
	/// The user has made any choice about Location (grant or deny); Location is optional.
	public var locationResolved: Bool
	/// The camera is currently reachable at its base URL.
	public var isReachable: Bool
	/// From `connect()`: `nil` until the app has connected this session.
	public var setupComplete: Bool?
	/// Set immediately after a password change so the flow routes to Reconnect (the camera kicks clients).
	public var didJustChangePassword: Bool

	public init(hasCompletedOnboarding: Bool = false, hasTappedGetStarted: Bool = false,
				localNetworkResolved: Bool = false, locationResolved: Bool = false,
				isReachable: Bool = false, setupComplete: Bool? = nil, didJustChangePassword: Bool = false) {
		self.hasCompletedOnboarding = hasCompletedOnboarding
		self.hasTappedGetStarted = hasTappedGetStarted
		self.localNetworkResolved = localNetworkResolved
		self.locationResolved = locationResolved
		self.isReachable = isReachable
		self.setupComplete = setupComplete
		self.didJustChangePassword = didJustChangePassword
	}
}
