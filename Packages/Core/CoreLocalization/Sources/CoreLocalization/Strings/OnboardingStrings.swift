//
//  OnboardingStrings.swift
//  CoreLocalization
//

import Foundation

/// Copy for the six onboarding screens.
public enum OnboardingStrings {
	// MARK: - Welcome

	public static let welcomeTitle = String(localized: "onboarding.welcome_title", bundle: .module)
	public static let welcomeBody = String(localized: "onboarding.welcome_body", bundle: .module)
	public static let getStarted = String(localized: "onboarding.get_started", bundle: .module)

	// MARK: - Local Network

	public static let localNetworkTitle = String(localized: "onboarding.local_network_title", bundle: .module)
	public static let localNetworkBody = String(localized: "onboarding.local_network_body", bundle: .module)

	// MARK: - Location

	public static let locationTitle = String(localized: "onboarding.location_title", bundle: .module)
	public static let locationBody = String(localized: "onboarding.location_body", bundle: .module)
	public static let locationAllow = String(localized: "onboarding.location_allow", bundle: .module)

	// MARK: - Connect Wi-Fi

	public static let connectTitle = String(localized: "onboarding.connect_title", bundle: .module)
	public static let connectBody = String(localized: "onboarding.connect_body", bundle: .module)
	public static let connectResetHint = String(localized: "onboarding.connect_reset_hint", bundle: .module)
	public static let waitingForCamera = String(localized: "onboarding.waiting_for_camera", bundle: .module)
	public static let cameraDetected = String(localized: "onboarding.camera_detected", bundle: .module)
	public static let connectJoinPrompt = String(localized: "onboarding.connect_join_prompt", bundle: .module)

	/// Shown once the SSID is known. Without Location the name is unavailable, and the screen falls
	/// back to `connectJoinPrompt`.
	public static func connectOnNetwork(ssid: String) -> String {
		String(format: String(localized: "onboarding.connect_on_network", bundle: .module), ssid)
	}

	// MARK: - Set password

	public static let setPasswordTitle = String(localized: "onboarding.set_password_title", bundle: .module)
	public static let setPasswordBody = String(localized: "onboarding.set_password_body", bundle: .module)
	public static let newPassword = String(localized: "onboarding.new_password", bundle: .module)
	public static let newPasswordPlaceholder = String(localized: "onboarding.new_password_placeholder", bundle: .module)
	public static let confirmPassword = String(localized: "onboarding.confirm_password", bundle: .module)
	public static let currentPassword = String(localized: "onboarding.current_password", bundle: .module)
	public static let setPasswordAction = String(localized: "onboarding.set_password_action", bundle: .module)
	public static let passwordRejected = String(localized: "onboarding.password_rejected", bundle: .module)
	public static let cameraUnreachable = String(localized: "onboarding.camera_unreachable", bundle: .module)
	public static let passwordTooShort = String(localized: "onboarding.password_too_short", bundle: .module)
	public static let passwordsDontMatch = String(localized: "onboarding.passwords_dont_match", bundle: .module)

	// MARK: - Reconnect

	public static let reconnectTitle = String(localized: "onboarding.reconnect_title", bundle: .module)
	public static let reconnectBody = String(localized: "onboarding.reconnect_body", bundle: .module)
}
