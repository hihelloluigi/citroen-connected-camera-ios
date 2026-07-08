import Foundation

/// Where and how long to wait when talking to the camera.
public struct VIRBConfiguration: Sendable {
	/// The camera's HTTP server address. Defaults to the camera's fixed AP gateway.
	public var baseURL: URL
	/// How long to wait for a response before treating the camera as unreachable.
	public var requestTimeout: TimeInterval

	/// The camera's fixed AP gateway. The literal is constant and valid; guard guarantees no force-unwrap.
	public static let defaultBaseURL: URL = {
		guard let url = URL(string: "http://192.168.0.1") else {
			preconditionFailure("Default base URL literal is malformed")
		}
		return url
	}()

	public init(baseURL: URL = VIRBConfiguration.defaultBaseURL, requestTimeout: TimeInterval = 8) {
		self.baseURL = baseURL
		self.requestTimeout = requestTimeout
	}
}

/// The seam between `VIRBClient` and the network, so tests can substitute a mock transport.
protocol VIRBTransport: Sendable {
	func post(path: String, body: Data) async throws -> Data
	func download(from url: URL, to destination: URL) async throws -> URL
}

/// The production `VIRBTransport`: posts to the camera over `URLSession` and maps
/// connectivity failures to `VIRBError.cameraUnreachable`, other errors to `VIRBError.transport`.
struct URLSessionTransport: VIRBTransport {
	let configuration: VIRBConfiguration
	let session: URLSession

	func post(path: String, body: Data) async throws -> Data {
		var request = URLRequest(url: configuration.baseURL.appendingPathComponent(path))
		request.httpMethod = "POST"
		request.httpBody = body
		request.timeoutInterval = configuration.requestTimeout
		// The camera ignores Content-Type but expects a JSON body; mirror the app's keep-alive.
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("keep-alive", forHTTPHeaderField: "Connection")
		do {
			let (data, _) = try await session.data(for: request)
			return data
		} catch let error as URLError where error.code == .cannotConnectToHost || error.code == .timedOut {
			throw VIRBError.cameraUnreachable
		} catch {
			throw VIRBError.transport(error.localizedDescription)
		}
	}

	func download(from url: URL, to destination: URL) async throws -> URL {
		let temp: URL
		let response: URLResponse
		do {
			(temp, response) = try await session.download(from: url)
		} catch let error as URLError where error.code == .cannotConnectToHost || error.code == .timedOut {
			throw VIRBError.cameraUnreachable
		} catch {
			throw VIRBError.transport(error.localizedDescription)
		}
		if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
			try? FileManager.default.removeItem(at: temp)
			throw VIRBError.unexpected(result: http.statusCode)
		}
		try? FileManager.default.removeItem(at: destination)
		try FileManager.default.moveItem(at: temp, to: destination)
		return destination
	}
}

extension URLSession {
	/// Builds the keep-alive, no-cache session the camera needs (one connection).
	static func virb(timeout: TimeInterval) -> URLSession {
		let config = URLSessionConfiguration.ephemeral
		config.httpMaximumConnectionsPerHost = 1
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		config.timeoutIntervalForRequest = timeout
		config.waitsForConnectivity = false // Avoid indefinite waits when the camera AP has no internet connectivity.
		return URLSession(configuration: config)
	}
}
