import VIRBKit

/// Reachability probe that mirrors the original app's session model: one `initialConnection`
/// handshake, then cheap `periodicUpdate` heartbeats. A heartbeat error that means the camera
/// answered (`.notActivePhone`, `.denied`, `.unexpected`, `.decoding`) proves it's still reachable,
/// so the session resets and this same `probe()` call falls through to a fresh `initialConnection`
/// handshake, whose outcome becomes the snapshot. Only transport-class errors (`.cameraUnreachable`,
/// `.transport`, or anything not a `VIRBError`) report unreachable, resetting so the next probe
/// re-handshakes — the same recovery the original app performs when its heartbeat dies.
public actor CameraSessionProbe: ReachabilityProbe {
	private let client: any VIRBClientProtocol
	/// Non-nil once a handshake succeeded. `periodicUpdate` doesn't report setup state, so the
	/// handshake's value is carried across heartbeats; setup only changes via our own onboarding.
	private var setupComplete: Bool?

	public init(client: any VIRBClientProtocol) {
		self.client = client
	}

	public func probe() async -> ConnectivitySnapshot {
		guard let setupComplete else {
			return await handshake()
		}
		do {
			_ = try await client.status()
			return ConnectivitySnapshot(isReachable: true, setupComplete: setupComplete)
		} catch {
			self.setupComplete = nil
			if cameraAnswered(error) {
				return await handshake()
			}
			return ConnectivitySnapshot(isReachable: false, setupComplete: nil)
		}
	}

	private func handshake() async -> ConnectivitySnapshot {
		do {
			let session = try await client.connect()
			setupComplete = session.isSetupComplete
			return ConnectivitySnapshot(isReachable: true, setupComplete: session.isSetupComplete)
		} catch {
			return ConnectivitySnapshot(isReachable: false, setupComplete: nil)
		}
	}

	/// Whether `error` means the camera answered (still reachable) rather than dropped off the network.
	private func cameraAnswered(_ error: any Error) -> Bool {
		switch error as? VIRBError {
		case .notActivePhone, .denied, .unexpected, .decoding:
			return true
		case .cameraUnreachable, .transport, .passwordRejected, nil:
			return false
		}
	}
}
