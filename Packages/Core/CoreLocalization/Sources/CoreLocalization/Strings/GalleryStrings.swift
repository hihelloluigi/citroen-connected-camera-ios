import Foundation

/// Copy for the media grid, the status header and the detail screen.
public enum GalleryStrings {
	public static let title = String(localized: "gallery.title", bundle: .module)
	public static let emptyTitle = String(localized: "gallery.empty_title", bundle: .module)
	public static let emptyBody = String(localized: "gallery.empty_body", bundle: .module)
	public static let takePhoto = String(localized: "gallery.take_photo", bundle: .module)
	public static let deleteOneConfirm = String(localized: "gallery.delete_one_confirm", bundle: .module)
	public static let downloading = String(localized: "gallery.downloading", bundle: .module)
	public static let video = String(localized: "gallery.video", bundle: .module)
	public static let photo = String(localized: "gallery.photo", bundle: .module)
	public static let videoPlayer = String(localized: "gallery.video_player", bundle: .module)

	/// The multi-select delete confirmation. The count drives a plural variation in the catalog,
	/// which is why the argument is interpolated into the key rather than formatted in afterwards —
	/// `String(format:)` on an already-resolved string cannot pick the right plural form.
	public static func deleteConfirm(count: Int) -> String {
		String(localized: "gallery.delete_confirm \(count)", bundle: .module)
	}

	// MARK: - Sections

	public static let sectionToday = String(localized: "gallery.section_today", bundle: .module)
	public static let sectionYesterday = String(localized: "gallery.section_yesterday", bundle: .module)
	public static let sectionUndated = String(localized: "gallery.section_undated", bundle: .module)

	// MARK: - Status header

	public static let statusSDNeedsFormat = String(localized: "gallery.status_sd_needs_format", bundle: .module)
	public static let statusSDReady = String(localized: "gallery.status_sd_ready", bundle: .module)
	public static let statusGPSFix = String(localized: "gallery.status_gps_fix", bundle: .module)
	public static let statusNoGPS = String(localized: "gallery.status_no_gps", bundle: .module)
	public static let statusAccessibilityLabel = String(localized: "gallery.status_a11y_label", bundle: .module)
	public static let statusAccessibilityHint = String(localized: "gallery.status_a11y_hint", bundle: .module)
	public static let cameraDetails = String(localized: "gallery.camera_details", bundle: .module)
	public static let firmware = String(localized: "gallery.firmware", bundle: .module)
	public static let partNumber = String(localized: "gallery.part_number", bundle: .module)
	public static let deviceID = String(localized: "gallery.device_id", bundle: .module)
	public static let readingDetails = String(localized: "gallery.reading_details", bundle: .module)

	// MARK: - Accessibility

	/// VoiceOver label for a geotagged item — "Video, geotagged".
	public static func geotagged(kind: String) -> String {
		String(format: String(localized: "gallery.a11y_geotagged", bundle: .module), kind)
	}
}
