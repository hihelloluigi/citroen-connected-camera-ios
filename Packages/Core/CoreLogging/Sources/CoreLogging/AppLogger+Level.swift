import os.log

public extension AppLogger {
	/// How much detail a build emits. Ordered, so a level gate is a comparison.
	enum Level: Int, CaseIterable, Comparable, Sendable {
		case debug = 0
		case info = 1
		case warning = 2
		case error = 3
		case fault = 4

		// MARK: - Parsing

		/// Builds a level from its lowercase name, for reading a build-time level out of
		/// Info.plist. Returns `nil` for anything unrecognised so the caller picks the fallback —
		/// a typo in an xcconfig should make a build quieter, not unexpectedly chatty.
		public init?(name: String) {
			guard let match = Self.allCases.first(where: { $0.label.lowercased() == name.lowercased() }) else {
				return nil
			}

			self = match
		}

		// MARK: - OSLogType Mapping

		var osLogType: OSLogType {
			switch self {
			case .debug: .debug
			case .info: .info
			case .warning: .default
			case .error: .error
			case .fault: .fault
			}
		}

		// MARK: - Display

		var label: String {
			switch self {
			case .debug: "DEBUG"
			case .info: "INFO"
			case .warning: "WARNING"
			case .error: "ERROR"
			case .fault: "FAULT"
			}
		}

		// MARK: - Comparable

		public static func < (lhs: Self, rhs: Self) -> Bool {
			lhs.rawValue < rhs.rawValue
		}
	}
}
