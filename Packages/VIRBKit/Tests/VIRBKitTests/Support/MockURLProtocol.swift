import Foundation

/// Test transport stub. Set `handler` to return canned responses per request.
final class MockURLProtocol: URLProtocol {
	nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

	override class func canInit(with request: URLRequest) -> Bool { true }
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override func startLoading() {
		guard let handler = Self.handler else {
			client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse)); return
		}
		do {
			let (response, data) = try handler(request)
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: data)
			client?.urlProtocolDidFinishLoading(self)
		} catch {
			client?.urlProtocol(self, didFailWithError: error)
		}
	}

	override func stopLoading() {}

	/// A URLSession wired to this mock protocol.
	static func makeSession() -> URLSession {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [MockURLProtocol.self]
		return URLSession(configuration: config)
	}
}

extension URLRequest {
	/// Reads the request body whether set directly or via a stream (URLProtocol delivers a stream).
	var bodyData: Data? {
		if let body = httpBody { return body }
		guard let stream = httpBodyStream else { return nil }
		stream.open(); defer { stream.close() }
		var data = Data()
		let size = 4096
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
		defer { buffer.deallocate() }
		while stream.hasBytesAvailable {
			let read = stream.read(buffer, maxLength: size)
			if read <= 0 { break }
			data.append(buffer, count: read)
		}
		return data
	}
}
