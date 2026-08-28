//
//  AdvanceOnboardingUseCaseTests.swift
//  FeatureOnboardingTests
//

import CoreCamera
import CoreConnectivity
import CoreDomain
import Testing
@testable import FeatureOnboarding

/// Collects the navigation actions a use case emits, standing in for the app shell's
/// `RoutingController`. What the shell then does with them is covered by
/// `RoutingControllerTests` in the app target; these tests only assert what the feature reports.
@MainActor
private final class ActionRecorder {
	private(set) var actions: [OnboardingNavigationAction] = []
	func record(_ action: OnboardingNavigationAction) { actions.append(action) }
}

/// One assembled use case plus the doubles behind it. A named type rather than a 4-tuple, which
/// the lint config rejects.
@MainActor
private struct Subject {
	let useCase: AdvanceOnboardingUseCase
	let store: InMemoryFlagsStore
	let camera: MockVIRBClient
	let recorder: ActionRecorder

	init(flags: OnboardingFlags = OnboardingFlags(), camera: MockVIRBClient = MockVIRBClient()) {
		let store = InMemoryFlagsStore(flags)
		let recorder = ActionRecorder()
		self.store = store
		self.camera = camera
		self.recorder = recorder
		self.useCase = AdvanceOnboardingUseCase(store: store, camera: camera,
												onAction: { recorder.record($0) })
	}
}

@MainActor
@Test func getStartedPersistsFlagAndReportsIt() {
	let subject = Subject()

	subject.useCase.markGetStarted()

	#expect(subject.store.load().hasTappedGetStarted == true)
	#expect(subject.recorder.actions == [.flagsUpdated(OnboardingFlags(hasTappedGetStarted: true))])
}

@MainActor
@Test func localNetworkAndLocationStepsEachPersistAndReport() {
	let subject = Subject()

	subject.useCase.markLocalNetworkResolved()
	subject.useCase.markLocationResolved()

	#expect(subject.store.load().localNetworkResolved == true)
	#expect(subject.store.load().locationResolved == true)
	#expect(subject.recorder.actions.count == 2)
}

@MainActor
@Test func changePasswordSucceedsThenReportsPasswordChanged() async throws {
	let subject = Subject(flags: .midFlow)

	try await subject.useCase.changePassword(current: "ConnectedCam", new: "Test1234")

	#expect(subject.camera.setWiFiPasswordCalls.count == 1)
	#expect(subject.camera.setWiFiPasswordCalls.first?.new == "Test1234")
	#expect(subject.recorder.actions == [.passwordChanged])
}

@MainActor
@Test func changePasswordRejectedRethrowsAndReportsNothing() async {
	let camera = MockVIRBClient()
	camera.setWiFiPasswordError = VIRBError.passwordRejected
	let subject = Subject(flags: .midFlow, camera: camera)

	await #expect(throws: VIRBError.passwordRejected) {
		try await subject.useCase.changePassword(current: "wrong", new: "Test1234")
	}
	// Nothing reported: the flow must stay on the password step so the screen can offer the
	// current-password recovery field.
	#expect(subject.recorder.actions.isEmpty)
}

@MainActor
@Test func finishReconnectReportsTheReleasedPin() {
	let subject = Subject(flags: .midFlow)

	subject.useCase.finishReconnect()

	#expect(subject.recorder.actions == [.reconnectFinished])
}

@MainActor
@Test func applyConnectivityFinishesOnboardingWhenSetupComplete() async {
	let subject = Subject(flags: .midFlow)
	let ready = ConnectivitySnapshot(isReachable: true, setupComplete: true)

	await subject.useCase.applyConnectivity(ready)

	#expect(subject.camera.activateCallCount == 1)					// claimed the active-phone slot
	#expect(subject.store.load().hasCompletedOnboarding == true)		// persisted
	#expect(subject.recorder.actions.first == .connectivityUpdated(ready))
	#expect(subject.recorder.actions.count == 2)					// the reading, then the flags
}

@MainActor
@Test func applyConnectivityIsIdempotentAcrossRepeatedPolls() async {
	let subject = Subject(flags: .midFlow)
	let ready = ConnectivitySnapshot(isReachable: true, setupComplete: true)

	await subject.useCase.applyConnectivity(ready)
	await subject.useCase.applyConnectivity(ready)

	#expect(subject.camera.activateCallCount == 1)					// a second poll must not re-finalize
	#expect(subject.store.load().hasCompletedOnboarding == true)
}

@MainActor
@Test func applyConnectivityDoesNotFinishWhileSetupIncomplete() async {
	let subject = Subject(flags: .midFlow)
	let notReady = ConnectivitySnapshot(isReachable: true, setupComplete: false)

	await subject.useCase.applyConnectivity(notReady)

	#expect(subject.camera.activateCallCount == 0)					// no claim until setup is done
	#expect(subject.store.load().hasCompletedOnboarding == false)
	#expect(subject.recorder.actions == [.connectivityUpdated(notReady)])
}

private extension OnboardingFlags {
	/// Past the three flag steps, at the point where the camera drives the rest of the flow.
	static let midFlow = OnboardingFlags(hasTappedGetStarted: true, localNetworkResolved: true,
										 locationResolved: true)
}
