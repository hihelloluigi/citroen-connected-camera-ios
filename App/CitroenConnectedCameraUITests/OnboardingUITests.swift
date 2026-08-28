//
//  OnboardingUITests.swift
//  CitroenConnectedCameraUITests
//

import CoreUI
import XCTest

/// Walks the onboarding flow against a scripted camera.
///
/// These are the tests the app could not have before: every screen past Welcome needs a camera to
/// answer, and there is none in a simulator. `ScriptedVIRBClient` supplies the answers, so the flow
/// the user actually walks — and the routing decisions behind it — run end to end here rather than
/// only in unit tests of the state machine.
final class OnboardingUITests: XCTestCase {
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
	}

	/// The happy path: a camera that is present and already set up carries the user all the way to
	/// the gallery. Location is skipped, which is the supported choice, not a degraded one.
	@MainActor
	func testWalksFromWelcomeToTheGallery() {
		let app = UITestApp.launch(.ready)

		tapGetStarted(in: app)
		tapContinueOnLocalNetwork(in: app)
		skipLocation(in: app)

		app.screen(AccessibilityID.Gallery.grid).awaitExistence("the media grid", timeout: 20)
		XCTAssertTrue(app.buttons[AccessibilityID.Gallery.snapshot].exists,
					  "the shutter button should be in the toolbar once the grid is up")
	}

	/// A camera that is reachable but not yet set up stops the flow at the password step instead of
	/// letting it fall through to the gallery.
	@MainActor
	func testFreshCameraStopsAtTheSetPasswordStep() {
		let app = UITestApp.launch(.fresh)

		tapGetStarted(in: app)
		tapContinueOnLocalNetwork(in: app)
		skipLocation(in: app)

		app.screen(AccessibilityID.Onboarding.setPassword)
			.awaitExistence("the set-password screen", timeout: 20)
		XCTAssertFalse(app.screen(AccessibilityID.Gallery.grid).exists)
	}

	/// With no camera on the network the flow waits on the connect step rather than advancing or
	/// showing an error the user can do nothing about.
	@MainActor
	func testAbsentCameraWaitsOnTheConnectStep() {
		let app = UITestApp.launch(.absent)

		tapGetStarted(in: app)
		tapContinueOnLocalNetwork(in: app)
		skipLocation(in: app)

		app.screen(AccessibilityID.Onboarding.connectWiFi)
			.awaitExistence("the connect-to-Wi-Fi screen", timeout: 20)
	}

	// MARK: - Steps

	@MainActor
	private func tapGetStarted(in app: XCUIApplication) {
		let button = app.buttons[AccessibilityID.Onboarding.getStarted]
		button.awaitExistence("the get-started button")
		button.tap()
	}

	@MainActor
	private func tapContinueOnLocalNetwork(in app: XCUIApplication) {
		let button = app.buttons[AccessibilityID.Onboarding.localNetworkContinue]
		button.awaitExistence("the Local Network continue button")
		button.tap()
	}

	/// Skips Location rather than granting it. Granting would raise the system permission alert,
	/// which is outside the app and would make these tests depend on springboard's copy.
	@MainActor
	private func skipLocation(in app: XCUIApplication) {
		let button = app.buttons[AccessibilityID.Onboarding.locationSkip]
		button.awaitExistence("the not-now button")
		button.tap()
	}
}
