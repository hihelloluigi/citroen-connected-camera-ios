import CoreUI
import XCTest

/// The backend-independent proof that the app boots and renders its first screen.
///
/// This is the one UI test that needs nothing from the camera at all — `absent` is what a real
/// simulator launch looks like — so it is the test CI can always run.
final class SmokeTests: XCTestCase {
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
	}

	@MainActor
	func testAppLaunchesToTheWelcomeScreen() {
		let app = UITestApp.launch(.absent)

		app.screen(AccessibilityID.Onboarding.welcome).awaitExistence("the welcome screen")
		XCTAssertTrue(app.buttons[AccessibilityID.Onboarding.getStarted].exists)
	}

	@MainActor
	func testWelcomeAdvancesToTheLocalNetworkExplainer() {
		let app = UITestApp.launch(.absent)
		app.buttons[AccessibilityID.Onboarding.getStarted].awaitExistence("the get-started button")

		app.buttons[AccessibilityID.Onboarding.getStarted].tap()

		app.screen(AccessibilityID.Onboarding.localNetwork).awaitExistence("the Local Network screen")
	}

	@MainActor
	func testOnboardingProgressSurvivesRelaunch() {
		let app = UITestApp.launch(.absent)
		app.buttons[AccessibilityID.Onboarding.getStarted].awaitExistence("the get-started button")
		app.buttons[AccessibilityID.Onboarding.getStarted].tap()
		app.screen(AccessibilityID.Onboarding.localNetwork).awaitExistence("the Local Network screen")

		// Relaunching WITHOUT the reset flag: the persisted flag should carry the flow forward
		// rather than dropping the user back at Welcome.
		app.terminate()
		let relaunched = UITestApp.launch(.absent, resetState: false)

		relaunched.screen(AccessibilityID.Onboarding.localNetwork)
			.awaitExistence("the Local Network screen after relaunch")
	}
}
