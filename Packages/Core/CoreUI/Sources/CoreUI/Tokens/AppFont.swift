import SwiftUI

/// The app's type roles. UI uses the system face; telemetry uses monospaced with tabular figures.
///
/// Each role maps to the `Font.TextStyle` that renders at the size it names, which is why the
/// mapping is not always the obvious one — `callout` is a `.subheadline` (15pt), `caption` a
/// `.footnote` (13pt).
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
	/// 15pt monospaced, for telemetry. The one role whose size moved (from 14pt) — there is no 14pt
	/// system text style.
	public static let mono = Font.system(.subheadline, design: .monospaced, weight: .medium)
}
