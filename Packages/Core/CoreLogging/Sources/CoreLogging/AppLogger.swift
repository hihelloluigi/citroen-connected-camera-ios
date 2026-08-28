import Foundation
import os.log

/// The app's logging front door. One `AppLogger` per category; the subsystem is resolved once.
///
/// It exists so no call site has to name the bundle identifier. Two of them used to, each with its
/// own `?? "me.luigiaiello.ccam"` fallback — which is wrong in two ways: a hardcoded identifier
/// silently disagrees with the Development and Staging builds, whose bundle ids differ, so their
/// log lines file themselves under the Production subsystem and Console's subsystem filter stops
/// working for exactly the builds you debug most.
public struct AppLogger: Sendable {
	// MARK: - Stored Properties

	private let logger: os.Logger
	private let minimumLevel: Level

	// MARK: - Static Properties

	/// The subsystem every logger files under: the running bundle's identifier, so Development,
	/// Staging and Production each get their own in Console without anyone configuring it.
	/// `Bundle.main` has no identifier in a command-line test runner, hence the literal fallback —
	/// the one place in the app it is acceptable, because nothing reads it back.
	public static let subsystem = Bundle.main.bundleIdentifier ?? "CitroenConnectedCamera"

	/// The floor for this build, read once from `Info.plist`'s `CCAMLogLevel`. Absent or
	/// unrecognised means `.info`.
	public static let buildLevel: Level = {
		guard let raw = Bundle.main.object(forInfoDictionaryKey: "CCAMLogLevel") as? String,
			  let level = Level(name: raw) else {
			return .info
		}

		return level
	}()

	// MARK: - Init

	/// - Parameters:
	///   - category: Groups related lines in Console — one per concern, not one per type.
	///   - minimumLevel: Anything below this is dropped. Defaults to the build's level.
	public init(category: String, minimumLevel: Level = Self.buildLevel) {
		self.logger = os.Logger(subsystem: Self.subsystem, category: category)
		self.minimumLevel = minimumLevel
	}

	// MARK: - Logging

	public func debug(_ message: @autoclosure () -> String) { log(.debug, message()) }

	public func info(_ message: @autoclosure () -> String) { log(.info, message()) }

	public func warning(_ message: @autoclosure () -> String) { log(.warning, message()) }

	public func error(_ message: @autoclosure () -> String) { log(.error, message()) }

	public func fault(_ message: @autoclosure () -> String) { log(.fault, message()) }

	// MARK: - Private Helpers

	/// Everything is logged `.public`. This app has no accounts, no tokens and no personal data —
	/// the only things it ever logs are camera protocol failures and Keychain status codes, and
	/// redacting those would make the log useless for the one thing it is for.
	private func log(_ level: Level, _ message: String) {
		guard level >= minimumLevel else { return }

		logger.log(level: level.osLogType, "\(message, privacy: .public)")
	}
}
