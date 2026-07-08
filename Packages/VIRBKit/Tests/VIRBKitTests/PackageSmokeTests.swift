import Testing
@testable import VIRBKit

@Test func moduleImports() {
	#expect(true)
}

@Test func fixturesLoad() throws {
	let data = try Fixture.load("mediaList")
	#expect(!data.isEmpty)
}
