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

    // Stubs for methods implemented in Tasks 9 and 10.
    public func mediaList() async throws -> [MediaItem] { throw VIRBError.unexpected(result: -1) }
    public func snapPicture() async throws -> MediaItem { throw VIRBError.unexpected(result: -1) }
    public func delete(_ items: [MediaItem]) async throws { throw VIRBError.unexpected(result: -1) }
    public func setWiFiPassword(current: String, new: String) async throws { throw VIRBError.unexpected(result: -1) }
    public func download(_ item: MediaItem, to destination: URL,
                         progress: (@Sendable (Double) -> Void)?) async throws -> URL {
        throw VIRBError.unexpected(result: -1)
    }
    public func isReachable() async -> Bool { false }

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

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}
