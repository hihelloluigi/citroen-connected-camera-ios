import Testing
import VIRBKit
@testable import AppCore

@Test func firstProbeHandshakesWithInitialConnection() async {
	let client = MockVIRBClient()
	client.connectResult = .success(.stub(setupComplete: true))
	let probe = CameraSessionProbe(client: client)
	let snapshot = await probe.probe()
	#expect(client.sessionCommands == ["initialConnection"])
	#expect(snapshot == ConnectivitySnapshot(isReachable: true, setupComplete: true))
}

@Test func laterProbesHeartbeatWithPeriodicUpdate() async {
	let client = MockVIRBClient()
	client.connectResult = .success(.stub(setupComplete: false))
	client.statusResult = .success(.stub())
	let probe = CameraSessionProbe(client: client)
	_ = await probe.probe()
	let second = await probe.probe()
	#expect(client.sessionCommands == ["initialConnection", "periodicUpdate"])
	// periodicUpdate doesn't report setupComplete; the handshake's value is carried forward.
	#expect(second == ConnectivitySnapshot(isReachable: true, setupComplete: false))
}

@Test func failedHeartbeatReportsUnreachableThenRehandshakes() async {
	let client = MockVIRBClient()
	client.connectResult = .success(.stub(setupComplete: true))
	// statusResult keeps its default .failure — the heartbeat dies after the handshake.
	let probe = CameraSessionProbe(client: client)
	_ = await probe.probe()
	let dropped = await probe.probe()
	#expect(dropped == ConnectivitySnapshot(isReachable: false, setupComplete: nil))
	let recovered = await probe.probe()
	#expect(client.sessionCommands == ["initialConnection", "periodicUpdate", "initialConnection"])
	#expect(recovered == ConnectivitySnapshot(isReachable: true, setupComplete: true))
}

@Test func failedHandshakeReportsUnreachable() async {
	let client = MockVIRBClient()  // connectResult defaults to .failure
	let probe = CameraSessionProbe(client: client)
	let snapshot = await probe.probe()
	#expect(snapshot == ConnectivitySnapshot(isReachable: false, setupComplete: nil))
	#expect(client.sessionCommands == ["initialConnection"])
}
