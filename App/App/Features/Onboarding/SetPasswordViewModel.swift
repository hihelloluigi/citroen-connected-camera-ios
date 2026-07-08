import AppCore
import VIRBKit
import Observation

@MainActor
@Observable
final class SetPasswordViewModel {
	private let actions: OnboardingActions
	var newPassword = ""
	var confirmPassword = ""
	/// The current password. Defaults to the factory password; revealed for editing only after the
	/// camera rejects it, so a returning user who already changed it can supply the real one.
	var currentPassword = "ConnectedCam"
	private(set) var showCurrentPasswordField = false
	private(set) var validationError: String?
	private(set) var submissionError: String?
	private(set) var isSubmitting = false

	init(actions: OnboardingActions) { self.actions = actions }

	/// Validates locally, then asks the camera to change the password. On `.passwordRejected` we surface
	/// the current-password field; on success routing moves to Reconnect (no local navigation here).
	func submit() async {
		submissionError = nil
		validationError = PasswordRules.validate(new: newPassword, confirm: confirmPassword)
		guard validationError == nil else { return }

		isSubmitting = true
		defer { isSubmitting = false }
		do {
			try await actions.changePassword(current: currentPassword, new: newPassword)
		} catch VIRBError.passwordRejected {
			showCurrentPasswordField = true
			submissionError = "That current password wasn't accepted. " +
				"Enter the camera's current password and try again."
		} catch {
			submissionError = "Couldn't reach the camera. Check you're on its Wi‑Fi and try again."
		}
	}
}
