import Foundation
import Testing
@testable import VIRBKit

extension VIRBClientTests {
	// Tests share a global MockURLProtocol.handler, so they must run serially.
	@Suite(.serialized)
	struct VIRBClientMediaTests {
		@Test func mediaListReturnsItems() async throws {
			let client = try makeClient(fixture: "mediaList")
			let items = try await client.mediaList()
			#expect(items.count == 2)
			#expect(items.first?.kind == .video)
		}

		@Test func snapPictureReturnsItem() async throws {
			let client = try makeClient(fixture: "snapPicture")
			let item = try await client.snapPicture()
			#expect(item.kind == .photo)
			#expect(item.name == "2026_06_27_13h06_1.JPG")
		}

		@Test func notActivePhoneSurfacesError() async throws {
			let client = try makeClient(fixture: "error_notActive")
			await #expect(throws: VIRBError.notActivePhone) {
				_ = try await client.snapPicture()
			}
		}
	}
}
