//
//  AccessibilityID.swift
//  CoreUI
//

/// The identifiers UI tests address the app by.
///
/// They live here, shared between the features that set them and the test bundle that reads them,
/// because the alternative is a string literal duplicated in two targets that drift apart silently
/// — a UI test querying an identifier nobody sets any more doesn't fail loudly, it hangs until the
/// existence timeout. Identifiers are also the only stable handle now that every visible string is
/// localized: a test that matched on "Get started" would break the moment it ran in Italian.
public enum AccessibilityID {
	public enum Onboarding {
		public static let welcome = "onboarding.welcome"
		public static let getStarted = "onboarding.getStarted"
		public static let localNetwork = "onboarding.localNetwork"
		public static let localNetworkContinue = "onboarding.localNetwork.continue"
		public static let location = "onboarding.location"
		public static let locationAllow = "onboarding.location.allow"
		public static let locationSkip = "onboarding.location.skip"
		public static let connectWiFi = "onboarding.connectWiFi"
		public static let setPassword = "onboarding.setPassword"
		public static let reconnect = "onboarding.reconnect"
	}

	public enum Gallery {
		public static let grid = "gallery.grid"
		public static let empty = "gallery.empty"
		public static let snapshot = "gallery.snapshot"
		public static let select = "gallery.select"
	}
}
