import Foundation

/// Serves the bundled sample frames for the scripted camera's media URLs.
///
/// `ScriptedVIRBClient` answers the control protocol, but nothing routes through it to draw a cell:
/// the grid hands `thumbURL` to `AsyncImage`, which is a `URLSession.shared` GET to `192.168.0.1` —
/// an address that resolves to nothing in the Simulator. Every cell therefore rendered its failure
/// placeholder, so the one screen the app exists for was the one screen you could not look at, in a
/// UI test, in a screenshot, or in front of a reviewer.
///
/// Registered by `AppComposition` only under `-uiTestMode`, and narrow by construction: it claims
/// GETs to the camera's two media path prefixes and nothing else, so `POST /virb` is untouched and
/// a normal launch never reaches this class at all.
///
/// **Stills only.** A video's `url` gets a frame too, which is what the grid and the share sheet
/// need, but it is a JPEG under an `.MP4` name — `MediaDetailView`'s player cannot play it. Demo
/// video playback needs a real encoded clip; see `docs/NOTES.md`.
public final class ScriptedCameraURLProtocol: URLProtocol {
	private static let cameraHost = "192.168.0.1"
	private static let mediaPathPrefixes = ["/thumb/", "/DCIM/"]
	private static let frameNames = ["frame-1", "frame-2", "frame-3"]

	/// Read once. Three small JPEGs re-read on every cell draw would make scrolling do file I/O
	/// for no reason.
	private static let frames: [Data] = frameNames.compactMap { name in
		guard let url = Bundle.module.url(forResource: name, withExtension: "jpg") else {
			return nil
		}

		return try? Data(contentsOf: url)
	}

	/// Installs the stub globally. `AsyncImage` uses `URLSession.shared`, which honours protocols
	/// registered here — there is no session to inject into it.
	public static func register() {
		URLProtocol.registerClass(Self.self)
	}

	override public static func canInit(with request: URLRequest) -> Bool {
		guard request.httpMethod == "GET", let url = request.url, url.host == cameraHost else { return false }

		return mediaPathPrefixes.contains { url.path.hasPrefix($0) }
	}

	override public static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

	override public func startLoading() {
		guard
			let url = request.url,
			let data = Self.frame(for: url),
			let response = HTTPURLResponse(
				url: url,
				statusCode: 200,
				httpVersion: "HTTP/1.1",
				headerFields: ["Content-Type": "image/jpeg", "Content-Length": "\(data.count)"]
			)
		else {
			client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
			return
		}

		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: data)
		client?.urlProtocolDidFinishLoading(self)
	}

	override public func stopLoading() {}

	/// The frame for a media URL, chosen by name so a given file is always the same picture — a
	/// thumbnail and its full-size still have to match, and a grid that reshuffled on every reload
	/// would look like a bug.
	static func frame(for url: URL) -> Data? {
		guard !frames.isEmpty else { return nil }

		let key = url.deletingPathExtension().lastPathComponent
		let index = key.utf8.reduce(0) { $0 &+ Int($1) } % frames.count

		return frames[index]
	}
}
