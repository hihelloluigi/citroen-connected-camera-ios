import AppCore
import Observation

@MainActor
@Observable
final class LocationPermissionViewModel {
    private let permissions: any PermissionsService
    private let actions: OnboardingActions
    private(set) var isRequesting = false

    init(permissions: any PermissionsService, actions: OnboardingActions) {
        self.permissions = permissions
        self.actions = actions
    }

    /// Requests When-In-Use, then resolves the step regardless of the answer (Location is optional —
    /// without it the app just can't show the network name).
    func request() async {
        isRequesting = true
        _ = await permissions.requestLocation()
        isRequesting = false
        actions.markLocationResolved()
    }

    func skip() { actions.markLocationResolved() }
}
