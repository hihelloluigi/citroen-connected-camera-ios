//
//  AppFont.swift
//  CoreUI
//

import SwiftUI

/// The app's type roles. UI uses the system face; telemetry (coords, timestamps, file sizes) uses a
/// monospaced face with tabular figures — the identity's signature treatment.
///
/// Every role is built from a `Font.TextStyle`, not a fixed point size, so all of it scales with the
/// user's Dynamic Type setting. `Font.system(size:)` — what these used to be — renders at one size
/// forever and leaves anyone who has raised their text size reading 13pt captions.
///
/// The style each role maps to was chosen to preserve the size it already rendered at, which is why
/// the mapping is not always the obvious one: `callout` is a `.subheadline` because that is the
/// 15pt style, and `caption` is a `.footnote` because that is the 13pt one. The names describe this
/// design system's roles; the styles supply Apple's metrics for them.
public enum AppFont {
	/// 34pt bold — the welcome screen's headline, and nothing else.
	public static let displayLarge = Font.system(.largeTitle, design: .default, weight: .bold)
	/// 22pt semibold — screen titles.
	public static let title = Font.system(.title2, design: .default, weight: .semibold)
	/// 17pt semibold — button labels and section headers.
	public static let headline = Font.system(.headline, design: .default, weight: .semibold)
	/// 17pt — body copy.
	public static let body = Font.system(.body, design: .default, weight: .regular)
	/// 15pt — secondary explanatory copy.
	public static let callout = Font.system(.subheadline, design: .default, weight: .regular)
	/// 13pt — labels and badges.
	public static let caption = Font.system(.footnote, design: .default, weight: .regular)
	/// Monospaced, for telemetry. The one role whose base size moved — 14pt to 15pt — because there
	/// is no 14pt system text style to hang it on, and inventing one with `.custom` would give up
	/// the platform's own scaling curve to save a point.
	public static let mono = Font.system(.subheadline, design: .monospaced, weight: .medium)
}
