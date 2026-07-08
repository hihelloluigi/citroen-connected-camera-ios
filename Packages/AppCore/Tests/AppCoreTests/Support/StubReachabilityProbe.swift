@testable import AppCore

/// Reusable reachability probe stub for tests. Configure `result` before handing this to a
/// `ConnectivityMonitor` to control what `refresh()` observes.
struct StubReachabilityProbe: ReachabilityProbe {
	var result = ConnectivitySnapshot()

	func probe() async -> ConnectivitySnapshot { result }
}
