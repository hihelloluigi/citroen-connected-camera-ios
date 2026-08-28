import Foundation

/// One photo or video on the camera's SD card, in the shape the gallery actually uses.
///
/// Deliberately narrower than `MediaItemDTO`: the wire type also carries `sessionId` and
/// `videoType`, two camera-internal classifications no screen reads. Keeping them out is the point
/// of the boundary — a field the UI never shows is a field the UI can't accidentally start
/// depending on.
public struct MediaEntity: Sendable, Equatable, Hashable, Identifiable {
	/// Whether the item is a video or a still photo.
	public enum Kind: Sendable, Equatable, Hashable { case video, photo }

	public var id: String { name }
	public let kind: Kind
	/// Absolute URL on the camera's HTTP server where the full file can be downloaded.
	public let url: URL
	/// Absolute URL on the camera's HTTP server for the item's thumbnail image.
	public let thumbURL: URL
	/// The file name as stored on the SD card.
	public let name: String
	/// File size in bytes, when the camera reports it.
	public let fileSize: Int64?
	/// When the item was recorded, when the camera reports it.
	public let date: Date?
	/// GPS latitude at capture time, when the camera had a fix.
	public let gpsLatitude: Double?
	/// GPS longitude at capture time, when the camera had a fix.
	public let gpsLongitude: Double?

	public init(kind: Kind, url: URL, thumbURL: URL, name: String, fileSize: Int64? = nil,
				date: Date? = nil, gpsLatitude: Double? = nil, gpsLongitude: Double? = nil) {
		self.kind = kind
		self.url = url
		self.thumbURL = thumbURL
		self.name = name
		self.fileSize = fileSize
		self.date = date
		self.gpsLatitude = gpsLatitude
		self.gpsLongitude = gpsLongitude
	}
}
