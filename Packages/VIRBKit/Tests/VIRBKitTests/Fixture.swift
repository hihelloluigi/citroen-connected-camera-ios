import Foundation
import Testing

enum Fixture {
	/// Loads a bundled JSON fixture by file name (without extension).
	static func load(_ name: String) throws -> Data {
		guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures") else {
			throw FixtureError.missing(name)
		}
		return try Data(contentsOf: url)
	}

	enum FixtureError: Error { case missing(String) }
}
