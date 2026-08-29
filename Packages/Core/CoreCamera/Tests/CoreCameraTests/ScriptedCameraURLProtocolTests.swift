import Foundation
import Testing
@testable import CoreCamera

private func request(_ urlString: String, method: String = "GET") -> URLRequest {
	var request = URLRequest(url: URL(string: urlString) ?? URL(fileURLWithPath: "/"))
	request.httpMethod = method

	return request
}

@Test func claimsThumbnailAndMediaGets() {
	#expect(ScriptedCameraURLProtocol.canInit(with: request("http://192.168.0.1/thumb/VIDG0001.MP4")))
	#expect(ScriptedCameraURLProtocol.canInit(with: request("http://192.168.0.1/DCIM/PICT0003.JPG")))
}

@Test func leavesTheControlEndpointAlone() {
	// The whole point of the path and method narrowing: a scripted run must not have its command
	// traffic silently answered with a JPEG.
	#expect(!ScriptedCameraURLProtocol.canInit(with: request("http://192.168.0.1/virb", method: "POST")))
	#expect(!ScriptedCameraURLProtocol.canInit(with: request("http://192.168.0.1/virb")))
}

@Test func ignoresOtherHosts() {
	#expect(!ScriptedCameraURLProtocol.canInit(with: request("http://example.com/thumb/VIDG0001.MP4")))
}

@Test func servesAFrameForEveryScriptedItem() throws {
	for name in ["VIDG0001.MP4", "VIDG0002.MP4", "PICT0003.JPG", "SNAP0001.JPG"] {
		let url = try #require(URL(string: "http://192.168.0.1/thumb/\(name)"))
		let data = try #require(ScriptedCameraURLProtocol.frame(for: url))
		#expect(!data.isEmpty)
		// JPEG SOI marker — proves a real image reached the bundle rather than an empty file.
		#expect(data.prefix(2) == Data([0xFF, 0xD8]))
	}
}

@Test func aThumbnailAndItsFullSizeAreTheSamePicture() throws {
	let thumb = try #require(URL(string: "http://192.168.0.1/thumb/PICT0003.JPG"))
	let full = try #require(URL(string: "http://192.168.0.1/DCIM/PICT0003.JPG"))
	#expect(ScriptedCameraURLProtocol.frame(for: thumb) == ScriptedCameraURLProtocol.frame(for: full))
}

@Test func differentItemsGetDifferentPictures() throws {
	// A grid where every cell is the same image reads as a rendering bug rather than a demo.
	let first = try #require(URL(string: "http://192.168.0.1/thumb/VIDG0001.MP4"))
	let second = try #require(URL(string: "http://192.168.0.1/thumb/VIDG0002.MP4"))
	#expect(ScriptedCameraURLProtocol.frame(for: first) != ScriptedCameraURLProtocol.frame(for: second))
}
