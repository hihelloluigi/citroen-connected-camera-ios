import VIRBKit

/// Builds the VoiceOver label for a media cell: the kind, plus a note when the item is geotagged. Pure,
/// so the spoken description is unit-tested and the view just applies it.
public enum GalleryAccessibility {
	public static func label(for item: MediaItem) -> String {
		let kind = item.kind == .video ? "Video" : "Photo"
		return item.gpsLatitude != nil ? "\(kind), geotagged" : kind
	}
}
