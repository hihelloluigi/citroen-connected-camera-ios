import Testing
@testable import AppCore

@Test func environmentHoldsInjectedDependencies() {
    let env = AppEnvironment(camera: MockVIRBClient(), phoneId: "ABC-123")
    #expect(env.phoneId == "ABC-123")
}
