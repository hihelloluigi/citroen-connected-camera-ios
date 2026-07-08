import Foundation

/// The primary camera client. Holds a single transport and serialises all commands through it.
public actor VIRBClient: VIRBClientProtocol {
	private let phoneId: String
	private let transport: any VIRBTransport

	/// Creates a client that opens its own URLSession using the supplied configuration.
	public init(phoneId: String, configuration: VIRBConfiguration = .init()) {
		self.phoneId = phoneId
		self.transport = URLSessionTransport(
			configuration: configuration,
			session: .virb(timeout: configuration.requestTimeout)
		)
	}

	/// Test seam: inject a transport directly.
	init(phoneId: String, transport: any VIRBTransport) {
		self.phoneId = phoneId
		self.transport = transport
	}

	// MARK: - VIRBClientProtocol

	/// Registers this phone with the camera and returns the resulting session.
	public func connect() async throws -> CameraSession {
		let body = VIRBCommand.body("initialConnection", [
			"phoneId": .string(phoneId),
			"timestamp": .string(Self.timestamp())
		])
		let data = try await transport.post(path: "/virb", body: body)
		let response = try ConnectResponse.decode(from: data)
		// initialConnection returns deviceInfo even with result 9 (setup incomplete); don't treat 9 as fatal here.
		return try response.session()
	}

	/// Returns the camera's current operational status.
	public func status() async throws -> CameraStatus {
		let data = try await send("periodicUpdate", ["phoneId": .string(phoneId)])
		return try StatusResponse.decode(from: data).status()
	}

	/// Registers this phone as the active controller so the camera accepts commands.
	public func activate() async throws {
		try await send("activePhoneRequest", ["phoneId": .string(phoneId)])
	}

	/// Returns the list of media items stored on the camera's SD card.
	public func mediaList() async throws -> [MediaItem] {
		let data = try await send("mediaList")
		return try JSONDecoder.virb.decode(MediaListResponse.self, from: data).media
	}

	/// Triggers the camera shutter and returns the captured photo item.
	public func snapPicture() async throws -> MediaItem {
		let data = try await send("snapPicture")
		return try JSONDecoder.virb.decode(SnapResponse.self, from: data).media
	}

	/// Deletes the given media items from the camera's SD card.
	public func delete(_ items: [MediaItem]) async throws {
		let urls = items.map { $0.url.absoluteString }
		try await send("deleteFile", ["files": .strings(urls)])
	}

	/// Changes the camera's Wi-Fi password. Throws `VIRBError.passwordRejected` when the
	/// camera rejects the current password.
	public func setWiFiPassword(current: String, new: String) async throws {
		do {
			try await send("setWifiPassword", [
				"oldPassword": .string(current),
				"newPassword": .string(new),
				"phoneId": .string(phoneId)
			])
		} catch VIRBError.unexpected, VIRBError.denied {
			throw VIRBError.passwordRejected
		}
	}

	/// Downloads a media item to `destination`, moving the camera's file there atomically.
	///
	/// Progress is reported as a value in `0...1`. The v1 implementation reports completion
	/// once the file is on disk; streaming progress will be wired when the gallery is built.
	/// Throws `VIRBError` on transport or non-2xx responses.
	public func download(
		_ item: MediaItem,
		to destination: URL,
		progress: (@Sendable (Double) -> Void)? = nil
	) async throws -> URL {
		let result = try await transport.download(from: item.url, to: destination)
		progress?(1)
		return result
	}

	/// Returns `true` if the camera responds to a connection attempt.
	public func isReachable() async -> Bool {
		(try? await connect()) != nil
	}

	// MARK: - Internal seam

	/// Posts a command and throws if the camera reports a non-success `result`.
	@discardableResult
	func send(_ name: String, _ fields: [String: VIRBValue] = [:]) async throws -> Data {
		let data = try await transport.post(path: "/virb", body: VIRBCommand.body(name, fields))
		if let result = try? Self.result(in: data), let error = VIRBError.map(result: result) {
			throw error
		}
		return data
	}

	// MARK: - Helpers

	private static func result(in data: Data) throws -> Int? {
		(try JSONSerialization.jsonObject(with: data) as? [String: Any])?["result"] as? Int
	}

	private static let timestampFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()

	private static func timestamp() -> String {
		timestampFormatter.string(from: Date())
	}
}
