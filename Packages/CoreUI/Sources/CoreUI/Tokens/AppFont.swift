import SwiftUI

/// The app's type roles. UI uses the system face; telemetry (coords, timestamps, file sizes) uses a
/// monospaced face with tabular figures — the identity's signature treatment.
public enum AppFont {
    public static let displayLarge = Font.system(size: 34, weight: .bold)
    public static let title = Font.system(size: 22, weight: .semibold)
    public static let headline = Font.system(size: 17, weight: .semibold)
    public static let body = Font.system(size: 17, weight: .regular)
    public static let callout = Font.system(size: 15, weight: .regular)
    public static let caption = Font.system(size: 13, weight: .regular)
    public static let mono = Font.system(size: 14, weight: .medium, design: .monospaced)
}
