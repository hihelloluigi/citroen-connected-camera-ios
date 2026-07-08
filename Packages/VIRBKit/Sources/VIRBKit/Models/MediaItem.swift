import Foundation

/// A photo or video stored on the camera's SD card, as returned by `mediaList` or `snapPicture`.
public struct MediaItem: Sendable, Equatable, Hashable, Identifiable, Decodable {
	/// Whether the item is a video or a still photo.
	public enum Kind: String, Sendable, Decodable { case video, photo }

	public var id: String { name }
	public let kind: Kind
	/// Absolute URL on the camera's Wi-Fi HTTP server where the full file can be downloaded.
	public let url: URL
	/// Absolute URL on the camera's Wi-Fi HTTP server for the item's thumbnail image.
	public let thumbURL: URL
	/// The file name as stored on the SD card.
	public let name: String
	/// File size in bytes, when the camera reports it.
	public let fileSize: Int64?
	/// When the item was recorded, when the camera reports it.
	public let date: Date?
	/// The recording session this item belongs to. Nil for kinds the camera doesn't group into sessions (e.g. photos).
	public let sessionId: Int?
	/// The camera's internal video classification. Nil for photos.
	public let videoType: Int?
	/// GPS latitude at capture time, when the camera has a fix and reports it for this kind.
	public let gpsLatitude: Double?
	/// GPS longitude at capture time, when the camera has a fix and reports it for this kind.
	public let gpsLongitude: Double?

	public init(kind: Kind, url: URL, thumbURL: URL, name: String, fileSize: Int64? = nil,
				date: Date? = nil, sessionId: Int? = nil, videoType: Int? = nil,
				gpsLatitude: Double? = nil, gpsLongitude: Double? = nil) {
		self.kind = kind
		self.url = url
		self.thumbURL = thumbURL
		self.name = name
		self.fileSize = fileSize
		self.date = date
		self.sessionId = sessionId
		self.videoType = videoType
		self.gpsLatitude = gpsLatitude
		self.gpsLongitude = gpsLongitude
	}

	private enum CodingKeys: String, CodingKey {
		case kind = "type", url, thumbURL = "thumbUrl", name, fileSize, date
		case sessionId, videoType, gpsLatitude, gpsLongitude
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		kind = try container.decode(Kind.self, forKey: .kind)
		url = try container.decode(URL.self, forKey: .url)
		thumbURL = try container.decode(URL.self, forKey: .thumbURL)
		name = try container.decode(String.self, forKey: .name)
		fileSize = try container.decodeIfPresent(Int64.self, forKey: .fileSize)
		date = try container.decodeIfPresent(TimeInterval.self, forKey: .date)
			.map { Date(timeIntervalSince1970: $0) }
		sessionId = try container.decodeIfPresent(Int.self, forKey: .sessionId)
		videoType = try container.decodeIfPresent(Int.self, forKey: .videoType)
		gpsLatitude = try container.decodeIfPresent(Double.self, forKey: .gpsLatitude)
		gpsLongitude = try container.decodeIfPresent(Double.self, forKey: .gpsLongitude)
	}
}

/// Response wrapper for `mediaList`.
public struct MediaListResponse: Sendable, Decodable {
	public let media: [MediaItem]
}

/// Response wrapper for `snapPicture`.
public struct SnapResponse: Sendable, Decodable {
	public let result: Int
	public let media: MediaItem
}
