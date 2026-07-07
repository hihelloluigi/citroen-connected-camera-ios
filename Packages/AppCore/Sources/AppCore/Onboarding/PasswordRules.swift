/// Validates a new camera Wi‑Fi password before any network call. Returns `nil` when the pair is
/// acceptable, otherwise a human-voiced fix-it line. Rule: at least 8 characters and both entries match.
public enum PasswordRules {
    public static func validate(new: String, confirm: String) -> String? {
        if new.count < 8 { return "Use at least 8 characters." }
        if new != confirm { return "The two passwords don't match." }
        return nil
    }
}
