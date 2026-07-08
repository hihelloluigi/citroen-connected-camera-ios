import AppCore
import VIRBKit

/// Live reachability probe: asks the camera to connect. `connect()` returns a session even when setup
/// is incomplete (result 9), so a successful call means reachable; the session tells us `setupComplete`.
/// Verified on device — there is no camera in the CLI/simulator environment.
struct CameraReachabilityProbe: ReachabilityProbe {
	let client: any VIRBClientProtocol

	func probe() async -> ConnectivitySnapshot {
		do {
			let session = try await client.connect()
			return ConnectivitySnapshot(isReachable: true, setupComplete: session.isSetupComplete)
		} catch {
			return ConnectivitySnapshot(isReachable: false, setupComplete: nil)
		}
	}
}
