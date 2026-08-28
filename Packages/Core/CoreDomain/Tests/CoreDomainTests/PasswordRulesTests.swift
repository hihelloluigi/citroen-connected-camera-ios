import Testing
@testable import CoreDomain

@Test func validPasswordReturnsNil() {
	#expect(PasswordRules.validate(new: "Test1234", confirm: "Test1234") == nil)
}

@Test func tooShortIsRejected() {
	#expect(PasswordRules.validate(new: "short", confirm: "short") == .tooShort)
}

@Test func mismatchIsRejected() {
	#expect(PasswordRules.validate(new: "Test1234", confirm: "Test9999") == .mismatch)
}

@Test func lengthIsCheckedBeforeTheMatch() {
	// Both rules fail here; reporting "too short" first is what makes the fix-it line actionable.
	#expect(PasswordRules.validate(new: "short", confirm: "other") == .tooShort)
}

@Test func exactlyEightCharactersIsAccepted() {
	#expect(PasswordRules.validate(new: "12345678", confirm: "12345678") == nil)
}
