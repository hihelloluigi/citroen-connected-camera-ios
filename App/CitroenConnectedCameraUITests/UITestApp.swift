import XCTest

/// Launches the app with a scripted camera.
///
/// Every test here goes through this rather than `XCUIApplication().launch()`, because a launch
/// without `-uiTestResetState` inherits whatever onboarding flags the previous test persisted —
/// the flags survive in the simulator's UserDefaults, so a suite that passes in isolation can fail
/// when run in a different order. Resetting is not optional tidiness; it is what makes these
/// deterministic.
enum UITestApp {
	/// What the scripted camera should pretend to be — mirrors `ScriptedVIRBClient.Scenario`.
	enum Scenario: String {
		case absent, fresh, ready
	}

	@MainActor
	static func launch(_ scenario: Scenario, resetState: Bool = true) -> XCUIApplication {
		let app = XCUIApplication()
		app.launchArguments = ["-uiTestMode", scenario.rawValue]
		if resetState {
			app.launchArguments.append("-uiTestResetState")
		}
		// Keeps the run locale-independent: the assertions below address identifiers, never text,
		// but a system alert's buttons are still localized by the device language.
		app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
		app.launch()
		return app
	}
}

extension XCUIApplication {
	/// Finds a screen container by identifier without asserting its element type.
	///
	/// SwiftUI decides that type from the container it happens to wrap — the onboarding screens
	/// come back as `Other`, the gallery's grid as a `ScrollView` because a `ScrollView` is its
	/// outermost view. Querying `app.otherElements[...]` therefore finds five of the six screens
	/// and silently hangs on the sixth, which is exactly the kind of failure that reads as a bug in
	/// the app rather than in the test.
	func screen(_ identifier: String) -> XCUIElement {
		descendants(matching: .any).matching(identifier: identifier).firstMatch
	}
}

extension XCUIElement {
    /// Waits for the element, failing the test with a useful message rather than a bare
    /// "element does not exist" when it never appears.
	@discardableResult
	func awaitExistence(
		_ description: String,
		timeout: TimeInterval = 10,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> Bool {
		let appeared = waitForExistence(timeout: timeout)
		XCTAssertTrue(appeared, "\(description) never appeared within \(Int(timeout))s",
					  file: file, line: line)
		return appeared
	}
}
