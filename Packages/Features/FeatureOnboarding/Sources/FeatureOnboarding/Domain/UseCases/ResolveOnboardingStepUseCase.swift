//
//  ResolveOnboardingStepUseCase.swift
//  FeatureOnboarding
//

/// Everything the flow needs to decide which onboarding screen to show. The values are resolved
/// facts — permission decisions, reachability, camera setup state; how they are derived from the OS
/// and the camera is the app shell's job, not this machine's.
public struct OnboardingRoutingInput: Equatable, Sendable {
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
	/// Set immediately after a password change so the flow pins to Reconnect (the camera kicks
	/// clients off the Wi-Fi when the password changes).
	public var didJustChangePassword: Bool

	public init(hasCompletedOnboarding: Bool = false, hasTappedGetStarted: Bool = false,
				localNetworkResolved: Bool = false, locationResolved: Bool = false,
				isReachable: Bool = false, setupComplete: Bool? = nil,
				didJustChangePassword: Bool = false) {
		self.hasCompletedOnboarding = hasCompletedOnboarding
		self.hasTappedGetStarted = hasTappedGetStarted
		self.localNetworkResolved = localNetworkResolved
		self.locationResolved = locationResolved
		self.isReachable = isReachable
		self.setupComplete = setupComplete
		self.didJustChangePassword = didJustChangePassword
	}
}

/// Resolves the onboarding flow's current step, or `nil` when the flow is finished and the app
/// should show the gallery instead.
public protocol ResolveOnboardingStepUseCaseProtocol: Sendable {
	func callAsFunction(_ input: OnboardingRoutingInput) -> OnboardingStep?
}

/// The onboarding state machine. A total function: every input yields exactly one answer, so
/// nothing above it ever has to guess.
///
/// This is the feature's decision to own, not the app shell's — the shell only asks "onboarding or
/// gallery", and a `nil` here is what answers it.
public struct ResolveOnboardingStepUseCase: ResolveOnboardingStepUseCaseProtocol {
	public init() {}

	public func callAsFunction(_ input: OnboardingRoutingInput) -> OnboardingStep? {
		if input.hasCompletedOnboarding {
			// Onboarding is done, but the camera can still go away; falling back to Reconnect is
			// what gets the user rejoined rather than staring at an empty grid.
			return (input.isReachable && input.setupComplete == true) ? nil : .reconnect
		}
		if !input.hasTappedGetStarted { return .welcome }
		if !input.localNetworkResolved { return .localNetworkPermission }
		if !input.locationResolved { return .locationPermission }
		// A password change kicks clients off the Wi-Fi; stay on Reconnect (rejoin with the new
		// password) until the caller clears the flag after a successful reconnect — even while
		// unreachable.
		if input.didJustChangePassword { return .reconnect }
		if !input.isReachable { return .connectWiFi }
		switch input.setupComplete {
		case .none: return .connectWiFi
		case .some(false): return .setPassword
		case .some(true): return nil
		}
	}
}
