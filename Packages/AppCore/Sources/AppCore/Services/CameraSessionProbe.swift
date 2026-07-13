import VIRBKit

/// Reachability probe that mirrors the original app's session model: one `initialConnection`
/// handshake, then cheap `periodicUpdate` heartbeats. Any failure resets the session, so the next
/// probe re-handshakes — the same recovery the original app performs when its heartbeat dies.
public actor CameraSessionProbe: ReachabilityProbe {
	private let client: any VIRBClientProtocol
	/// Non-nil once a handshake succeeded. `periodicUpdate` doesn't report setup state, so the
	/// handshake's value is carried across heartbeats; setup only changes via our own onboarding.
	private var setupComplete: Bool?

	public init(client: any VIRBClientProtocol) {
		self.client = client
	}

	public func probe() async -> ConnectivitySnapshot {
		if let setupComplete {
			do {
				_ = try await client.status()
				return ConnectivitySnapshot(isReachable: true, setupComplete: setupComplete)
			} catch {
				self.setupComplete = nil
				return ConnectivitySnapshot(isReachable: false, setupComplete: nil)
			}
		}
		do {
			let session = try await client.connect()
			setupComplete = session.isSetupComplete
			return ConnectivitySnapshot(isReachable: true, setupComplete: session.isSetupComplete)
		} catch {
			return ConnectivitySnapshot(isReachable: false, setupComplete: nil)
		}
	}
}
