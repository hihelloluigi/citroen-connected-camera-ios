//
//  AppSettings.swift
//  CoreUI
//

#if canImport(UIKit)
import UIKit

/// Opens the app's page in the system Settings, where the user can change a permission the app
/// can't re-prompt for (Local Network can never be re-prompted; Location/Photos can't once denied).
///
/// Guarded rather than made iOS-only at the package level: CoreUI is the one module both features
/// and the app share, and keeping it buildable for macOS is what lets its token and formatter tests
/// run under `swift test` without a simulator.
public enum AppSettings {
	@MainActor
	public static func open() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
		UIApplication.shared.open(url)
	}
}
#endif
