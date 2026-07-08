import Testing
@testable import AppCore

@Test func validPasswordReturnsNil() {
	#expect(PasswordRules.validate(new: "Test1234", confirm: "Test1234") == nil)
}

@Test func tooShortIsRejected() {
	#expect(PasswordRules.validate(new: "short", confirm: "short") != nil)
}

@Test func mismatchIsRejected() {
	#expect(PasswordRules.validate(new: "Test1234", confirm: "Test9999") != nil)
}
