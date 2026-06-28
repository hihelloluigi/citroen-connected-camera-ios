import Foundation

public struct MediaItem: Sendable, Equatable, Identifiable, Decodable {
    public enum Kind: String, Sendable, Decodable { case video, photo }

    public var id: String { name }
    public let kind: Kind
    public let url: URL
    public let thumbURL: URL
    public let name: String
    public let fileSize: Int64?
    public let date: Date
    public let sessionId: Int?
    public let videoType: Int?
    public let gpsLatitude: Double?
    public let gpsLongitude: Double?

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
        let epoch = try container.decode(TimeInterval.self, forKey: .date)
        date = Date(timeIntervalSince1970: epoch)
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
