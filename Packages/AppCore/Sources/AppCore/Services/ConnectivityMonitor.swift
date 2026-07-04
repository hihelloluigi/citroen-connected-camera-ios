import Observation

/// A point-in-time view of the camera's reachability, plus its setup state when known.
public struct ConnectivitySnapshot: Sendable, Equatable {
    public var isReachable: Bool
    public var setupComplete: Bool?

    public init(isReachable: Bool = false, setupComplete: Bool? = nil) {
        self.isReachable = isReachable
        self.setupComplete = setupComplete
    }
}

/// One reachability check against the camera. The live probe wraps `VIRBClient`; tests use a stub.
public protocol ReachabilityProbe: Sendable {
    func probe() async -> ConnectivitySnapshot
}

/// Holds the latest `ConnectivitySnapshot`, refreshed on demand. The single source of truth for
/// whether the camera is present, so screens don't each reimplement "camera disappeared".
@MainActor
@Observable
public final class ConnectivityMonitor {
    public private(set) var snapshot: ConnectivitySnapshot
    private let probe: any ReachabilityProbe

    public init(probe: any ReachabilityProbe) {
        self.probe = probe
        self.snapshot = ConnectivitySnapshot()
    }

    public func refresh() async {
        snapshot = await probe.probe()
    }
}
