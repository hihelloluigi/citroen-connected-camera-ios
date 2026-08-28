//
//  PasswordRules+Localization.swift
//  CoreLocalization
//

import CoreDomain

public extension PasswordRuleViolation {
	/// The fix-it line shown under the password field.
	var message: String {
		switch self {
		case .tooShort: OnboardingStrings.passwordTooShort
		case .mismatch: OnboardingStrings.passwordsDontMatch
		}
	}
}
