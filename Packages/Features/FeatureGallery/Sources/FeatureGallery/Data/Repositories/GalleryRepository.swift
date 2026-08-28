import CoreCamera
import Foundation

/// The live `GalleryRepositoryProtocol`, and the only type in the feature that sees a DTO.
///
/// `delete` and `download` address an item by its `url`, so they reconstruct a minimal DTO from the
/// entity rather than caching one between calls.
public struct GalleryRepository: GalleryRepositoryProtocol {
	private let client: any VIRBClientProtocol

	public init(client: any VIRBClientProtocol) {
		self.client = client
	}

	public func media() async throws -> [MediaEntity] {
		try await client.mediaList().map(Self.entity(from:))
	}

	public func status() async throws -> CameraStatusEntity {
		let dto = try await client.status()
		return CameraStatusEntity(needsFormat: dto.needsFormat, hasGPSFix: dto.gpsLatitude != nil)
	}

	public func device() async throws -> DeviceInfoEntity {
		let dto = try await client.connect().device
		return DeviceInfoEntity(firmware: dto.firmware, partNumber: dto.partNumber, deviceId: dto.deviceId)
	}

	public func snapshot() async throws -> MediaEntity {
		Self.entity(from: try await client.snapPicture())
	}

	public func delete(_ items: [MediaEntity]) async throws {
		try await client.delete(items.map(Self.dto(from:)))
	}

	public func download(_ item: MediaEntity, to destination: URL,
						 progress: @escaping @Sendable (Double) -> Void) async throws -> URL {
		try await client.download(Self.dto(from: item), to: destination, progress: progress)
	}

	// MARK: - Mapping

	private static func entity(from dto: MediaItemDTO) -> MediaEntity {
		MediaEntity(
			kind: dto.kind == .video ? .video : .photo,
			url: dto.url,
			thumbURL: dto.thumbURL,
			name: dto.name,
			fileSize: dto.fileSize,
			date: dto.date,
			gpsLatitude: dto.gpsLatitude,
			gpsLongitude: dto.gpsLongitude
		)
	}

	private static func dto(from entity: MediaEntity) -> MediaItemDTO {
		MediaItemDTO(
			kind: entity.kind == .video ? .video : .photo,
			url: entity.url,
			thumbURL: entity.thumbURL,
			name: entity.name,
			fileSize: entity.fileSize,
			date: entity.date,
			gpsLatitude: entity.gpsLatitude,
			gpsLongitude: entity.gpsLongitude
		)
	}
}
