/// Why a proposed camera password was rejected before any network call.
///
/// A case rather than a sentence, for the same reason as `UserFacingError`: the rule is domain
/// logic, the wording is not. `CoreLocalization` turns each case into a fix-it line.
public enum PasswordRuleViolation: Equatable, Sendable {
	case tooShort
	case mismatch
}

/// Validates a new camera Wi-Fi password. Returns `nil` when the pair is acceptable.
/// Rule: at least 8 characters, and both entries match.
public enum PasswordRules {
	public static func validate(new: String, confirm: String) -> PasswordRuleViolation? {
		if new.count < 8 { return .tooShort }
		if new != confirm { return .mismatch }
		return nil
	}
}
