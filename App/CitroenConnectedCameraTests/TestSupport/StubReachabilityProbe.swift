import CoreConnectivity

/// Reusable reachability probe stub for tests. Configure `result` before handing this to a
/// `ConnectivityMonitor` to control what `refresh()` observes.
struct StubReachabilityProbe: ReachabilityProbe {
	// MARK: - Stored Properties

	var result = ConnectivitySnapshot()

	// MARK: - ReachabilityProbe

	func probe() async -> ConnectivitySnapshot { result }
}
