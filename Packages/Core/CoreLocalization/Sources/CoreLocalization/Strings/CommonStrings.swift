import Foundation

/// Strings used by more than one feature.
public enum CommonStrings {
	public static let ok = String(localized: "common.ok", bundle: .module)
	public static let cancel = String(localized: "common.cancel", bundle: .module)
	public static let delete = String(localized: "common.delete", bundle: .module)
	public static let done = String(localized: "common.done", bundle: .module)
	public static let save = String(localized: "common.save", bundle: .module)
	public static let saved = String(localized: "common.saved", bundle: .module)
	public static let share = String(localized: "common.share", bundle: .module)
	public static let select = String(localized: "common.select", bundle: .module)
	public static let download = String(localized: "common.download", bundle: .module)
	public static let `continue` = String(localized: "common.continue", bundle: .module)
	public static let notNow = String(localized: "common.not_now", bundle: .module)
	/// Sends the user to the app's Settings page for a permission the app can't re-prompt for.
	public static let openSettings = String(localized: "common.open_settings", bundle: .module)
	/// Title for the alert shown when a camera action fails.
	public static let actionFailedTitle = String(localized: "common.action_failed_title", bundle: .module)
	/// The fallback message for a failure that isn't a known camera error.
	public static let genericCameraError = String(localized: "common.generic_camera_error", bundle: .module)
}
