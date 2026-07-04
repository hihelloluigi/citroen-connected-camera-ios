import Testing
@testable import AppCore

@MainActor
@Test func refreshUpdatesSnapshotFromProbe() async {
    var probe = StubReachabilityProbe()
    probe.result = ConnectivitySnapshot(isReachable: true, setupComplete: true)
    let monitor = ConnectivityMonitor(probe: probe)
    #expect(monitor.snapshot.isReachable == false) // initial
    await monitor.refresh()
    #expect(monitor.snapshot.isReachable == true)
    #expect(monitor.snapshot.setupComplete == true)
}
