import AppCore
import Observation

@MainActor
@Observable
final class LocationPermissionViewModel {
	private let permissions: any PermissionsService
	private let actions: OnboardingActions
	private(set) var isRequesting = false
	private(set) var isDenied = false

	init(permissions: any PermissionsService, actions: OnboardingActions) {
		self.permissions = permissions
		self.actions = actions
	}

	/// Reads the current status on appear so the screen can show "Open Settings" when Location was
	/// previously denied (iOS won't show the prompt again in that case).
	func onAppear() async {
		isDenied = await permissions.locationStatus() == .denied
	}

	/// Requests When-In-Use, then resolves the step regardless of the answer (Location is optional —
	/// without it the app just can't show the network name).
	func request() async {
		isRequesting = true
		let result = await permissions.requestLocation()
		isRequesting = false
		if result == .denied {
			isDenied = true			 // system didn't grant it; offer Settings, don't advance yet
			return
		}
		actions.markLocationResolved()
	}

	func skip() { actions.markLocationResolved() }
}
