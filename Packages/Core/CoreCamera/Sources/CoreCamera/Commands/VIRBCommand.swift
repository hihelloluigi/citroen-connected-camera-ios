import Foundation

/// A typed value for one field of a `VIRBCommand` request body.
enum VIRBValue: Sendable {
	case string(String)
	case int(Int)
	case strings([String])

	var jsonValue: Any {
		switch self {
		case .string(let value): return value
		case .int(let value): return value
		case .strings(let value): return value
		}
	}
}

enum VIRBCommand {
	/// Builds a `/virb` request body: a JSON object with `command` plus the given fields.
	static func body(_ name: String, _ fields: [String: VIRBValue] = [:]) -> Data {
		var object: [String: Any] = ["command": name]
		for (key, value) in fields { object[key] = value.jsonValue }
		// The camera tolerates key order; JSONSerialization is fine here.
		return (try? JSONSerialization.data(withJSONObject: object)) ?? Data()
	}
}
