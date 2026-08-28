import Foundation

/// A `VIRBClientProtocol` that answers from a script instead of a camera.
///
/// The app is unusable without a physical ConnectedCAM on its own Wi-Fi, which makes every screen
/// past the welcome step unreachable in the Simulator — and therefore unreachable to a UI test, and
/// to App Review. This is what makes them reachable. It ships in the binary deliberately, the way
/// beam ships `ScriptedDropRepository`; `AppComposition` only ever selects it when the process was
/// launched with `-uiTestMode`, so a normal launch can never reach it.
public struct ScriptedVIRBClient: VIRBClientProtocol {
	/// What the scripted camera pretends to be.
	public enum Scenario: String, Sendable {
		/// Not on the network at all — every call fails as unreachable.
		case absent
		/// Reachable, but the camera has not completed its first-time setup: the flow stops at the
		/// set-password step.
		case fresh
		/// Reachable and set up, with media on the card. The flow lands in the gallery.
		case ready
	}

	private let scenario: Scenario

	public init(scenario: Scenario) {
		self.scenario = scenario
	}

	public func connect() async throws -> CameraSessionDTO {
		guard scenario != .absent else { throw VIRBError.cameraUnreachable }
		return CameraSessionDTO(
			isSetupComplete: scenario == .ready,
			activePhoneId: nil,
			device: DeviceInfoDTO(wifiSSID: "ConnectedCAM0000", firmware: 200, vimVersion: 140,
								  partNumber: "006-B2465-00", deviceId: 1_234_567_890)
		)
	}

	public func activate() async throws {
		guard scenario != .absent else { throw VIRBError.cameraUnreachable }
	}

	public func status() async throws -> CameraStatusDTO {
		guard scenario != .absent else { throw VIRBError.cameraUnreachable }
		return CameraStatusDTO(activePhoneId: nil, primaryPhoneId: nil, numberOfConnections: 1,
							   saveVideoDuration: 20, needsFormat: false, incidentDetected: false,
							   faultDescription: "No Fault", gpsLatitude: 45.464200, gpsLongitude: 9.189600)
	}

	public func mediaList() async throws -> [MediaItemDTO] {
		guard scenario == .ready else { return [] }
		return Self.script
	}

	public func snapPicture() async throws -> MediaItemDTO {
		guard scenario == .ready else { throw VIRBError.cameraUnreachable }
		return Self.item(name: "SNAP0001.JPG", kind: .photo, minutesAgo: 0)
	}

	public func delete(_ items: [MediaItemDTO]) async throws {}

	/// Accepts the factory password and rejects anything else, so a UI test can exercise both the
	/// success path and the current-password recovery field.
	public func setWiFiPassword(current: String, new: String) async throws {
		guard current == "ConnectedCam" else { throw VIRBError.passwordRejected }
	}

	public func download(
		_ item: MediaItemDTO,
		to destination: URL,
		progress: (@Sendable (Double) -> Void)?
	) async throws -> URL {
		progress?(1)
		return destination
	}

	public func isReachable() async -> Bool { scenario != .absent }

	// MARK: - The script

	/// A fixed card: two clips and a geotagged photo, spread across today and yesterday so the
	/// grid's day sections and its GPS badge both have something to render.
	private static let script: [MediaItemDTO] = [
		item(name: "VIDG0001.MP4", kind: .video, minutesAgo: 30, size: 148_000_000),
		item(name: "VIDG0002.MP4", kind: .video, minutesAgo: 95, size: 132_000_000),
		item(name: "PICT0003.JPG", kind: .photo, minutesAgo: 1_500, size: 3_100_000,
			 latitude: 45.464200, longitude: 9.189600)
	]

	private static func item(
		name: String,
		kind: MediaItemDTO.Kind,
		minutesAgo: Int,
		size: Int64 = 1_000_000,
		latitude: Double? = nil,
		longitude: Double? = nil
	) -> MediaItemDTO {
		MediaItemDTO(
			kind: kind,
			url: cameraURL("/DCIM/\(name)"),
			thumbURL: cameraURL("/thumb/\(name)"),
			name: name,
			fileSize: size,
			date: Date(timeIntervalSinceNow: TimeInterval(-minutesAgo * 60)),
			gpsLatitude: latitude,
			gpsLongitude: longitude
		)
	}

	private static func cameraURL(_ path: String) -> URL {
		var components = URLComponents()
		components.scheme = "http"
		components.host = "192.168.0.1"
		components.path = path
		// A fixed scheme/host/path always resolves; the fallback keeps this non-throwing.
		return components.url ?? URL(fileURLWithPath: path)
	}
}
