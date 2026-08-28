import Testing
@testable import CoreLogging

@Test func levelsAreOrderedFromDebugToFault() {
	#expect(AppLogger.Level.debug < .info)
	#expect(AppLogger.Level.info < .warning)
	#expect(AppLogger.Level.warning < .error)
	#expect(AppLogger.Level.error < .fault)
}

@Test func levelParsesItsOwnLabelCaseInsensitively() {
	#expect(AppLogger.Level(name: "warning") == .warning)
	#expect(AppLogger.Level(name: "WARNING") == .warning)
	#expect(AppLogger.Level(name: "Error") == .error)
}

@Test func unrecognisedLevelNameIsNil() {
	// The caller picks the fallback, so a typo in an xcconfig makes a build quieter rather than
	// unexpectedly chatty.
	#expect(AppLogger.Level(name: "chatty") == nil)
	#expect(AppLogger.Level(name: "") == nil)
}

@Test func everyLevelHasADistinctLabel() {
	let labels = AppLogger.Level.allCases.map(\.label)
	#expect(Set(labels).count == labels.count)
}

@Test func subsystemIsNeverEmpty() {
	// Console's subsystem filter is useless if this is blank.
	#expect(!AppLogger.subsystem.isEmpty)
}
