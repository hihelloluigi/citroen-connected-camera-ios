import CoreCamera
import Foundation

/// Scriptable `VIRBClientProtocol` for the repository tests.
///
/// Unlike the fake used by the ViewModel tests, this one sits *below* `GalleryRepository` so the
/// DTO↔entity mapping runs for real. It records the urls the camera was actually addressed with,
/// which is the detail the mapping has to preserve.
final class MockVIRBClient: VIRBClientProtocol, @unchecked Sendable {
	var mediaListResult: [MediaItemDTO] = []
	var mediaListError: (any Error)?
	var statusResult: Result<CameraStatusDTO, any Error> = .success(.stub())
	var connectResult: Result<CameraSessionDTO, any Error> = .success(.stub())
	var snapResult: Result<MediaItemDTO, any Error> = .success(.stub(name: "SNAP.JPG", kind: .photo))
	private(set) var deletedURLs: [URL] = []
	private(set) var downloadedURLs: [URL] = []

	func connect() async throws -> CameraSessionDTO { try connectResult.get() }
	func activate() async throws {}
	func status() async throws -> CameraStatusDTO { try statusResult.get() }
	func mediaList() async throws -> [MediaItemDTO] {
		if let mediaListError { throw mediaListError }
		return mediaListResult
	}
	func snapPicture() async throws -> MediaItemDTO { try snapResult.get() }
	func delete(_ items: [MediaItemDTO]) async throws { deletedURLs = items.map(\.url) }
	func setWiFiPassword(current: String, new: String) async throws {}
	func download(_ item: MediaItemDTO, to destination: URL,
				  progress: (@Sendable (Double) -> Void)?) async throws -> URL {
		downloadedURLs.append(item.url)
		progress?(1)
		return destination
	}
	func isReachable() async -> Bool { true }
}

extension MediaItemDTO {
	/// A wire item carrying the camera-internal fields the entity deliberately drops, so a test can
	/// tell "mapped correctly" from "passed straight through".
	static func stub(name: String, kind: Kind = .video, fileSize: Int64? = nil, date: Date? = nil,
					 latitude: Double? = nil, longitude: Double? = nil) -> MediaItemDTO {
		MediaItemDTO(
			kind: kind,
			url: cameraURL("/DCIM/\(name)"),
			thumbURL: cameraURL("/thumb/\(name)"),
			name: name,
			fileSize: fileSize,
			date: date,
			sessionId: 7,
			videoType: 3,
			gpsLatitude: latitude,
			gpsLongitude: longitude
		)
	}

	private static func cameraURL(_ path: String) -> URL {
		var components = URLComponents()
		components.scheme = "http"
		components.host = "192.168.0.1"
		components.path = path
		return components.url ?? URL(fileURLWithPath: path)
	}
}

extension CameraStatusDTO {
	static func stub(needsFormat: Bool = false, latitude: Double? = nil) -> CameraStatusDTO {
		CameraStatusDTO(activePhoneId: nil, primaryPhoneId: nil, numberOfConnections: 1,
						saveVideoDuration: 20, needsFormat: needsFormat, incidentDetected: false,
						faultDescription: "No Fault", gpsLatitude: latitude, gpsLongitude: nil)
	}
}

extension CameraSessionDTO {
	static func stub(setupComplete: Bool = true) -> CameraSessionDTO {
		CameraSessionDTO(isSetupComplete: setupComplete, activePhoneId: nil,
						 device: DeviceInfoDTO(wifiSSID: "ConnectedCAM0000", firmware: 200,
											   vimVersion: 140, partNumber: "006-B2465-00", deviceId: 1))
	}
}
