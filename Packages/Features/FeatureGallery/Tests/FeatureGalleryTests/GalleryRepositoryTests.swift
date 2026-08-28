//
//  GalleryRepositoryTests.swift
//  FeatureGalleryTests
//

import CoreCamera
import Foundation
import Testing
@testable import FeatureGallery

/// The DTO↔entity boundary. This is the one type in the feature that sees a wire shape, so these
/// tests are what stop a camera field quietly reappearing in the UI layer.
@MainActor
private func makeRepository(client: MockVIRBClient = MockVIRBClient()) -> (GalleryRepository, MockVIRBClient) {
	(GalleryRepository(client: client), client)
}

@Test func mediaMapsEveryFieldTheGalleryUses() async throws {
	let client = MockVIRBClient()
	client.mediaListResult = [.stub(name: "A.MP4", kind: .video, fileSize: 4_096,
									date: Date(timeIntervalSince1970: 1_000),
									latitude: 45.07, longitude: 7.68)]

	let items = try await GalleryRepository(client: client).media()

	let item = try #require(items.first)
	#expect(item.kind == .video)
	#expect(item.name == "A.MP4")
	#expect(item.fileSize == 4_096)
	#expect(item.date == Date(timeIntervalSince1970: 1_000))
	#expect(item.gpsLatitude == 45.07)
	#expect(item.gpsLongitude == 7.68)
	#expect(item.url.absoluteString.hasSuffix("A.MP4"))
	#expect(item.thumbURL != item.url)
}

@Test func photoKindSurvivesTheMapping() async throws {
	let client = MockVIRBClient()
	client.mediaListResult = [.stub(name: "B.JPG", kind: .photo)]

	let items = try await GalleryRepository(client: client).media()

	#expect(items.first?.kind == .photo)
}

@Test func statusCollapsesToTheTwoFieldsTheHeaderRenders() async throws {
	let client = MockVIRBClient()
	client.statusResult = .success(.stub(needsFormat: true, latitude: 45.07))

	let status = try await GalleryRepository(client: client).status()

	#expect(status.needsFormat)
	// The header shows "GPS fix", not a coordinate — the entity carries the fact, not the value.
	#expect(status.hasGPSFix)
}

@Test func statusReportsNoFixWhenTheCameraHasNoCoordinate() async throws {
	let client = MockVIRBClient()
	client.statusResult = .success(.stub(needsFormat: false, latitude: nil))

	let status = try await GalleryRepository(client: client).status()

	#expect(!status.hasGPSFix)
	#expect(!status.needsFormat)
}

@Test func deviceReadsTheIdentityFromTheHandshake() async throws {
	let client = MockVIRBClient()
	client.connectResult = .success(.stub(setupComplete: true))

	let device = try await GalleryRepository(client: client).device()

	#expect(device.firmware == 200)
	#expect(device.partNumber == "006-B2465-00")
	#expect(device.deviceId == 1)
}

@Test func deleteSendsTheCameraTheItemsItCanAddress() async throws {
	let client = MockVIRBClient()
	let entity = MediaFactory.item(name: "A.MP4")

	try await GalleryRepository(client: client).delete([entity])

	// The repository reconstructs a DTO rather than caching one: the camera addresses an item by
	// its url, so a round trip through the entity has to preserve it exactly.
	#expect(client.deletedURLs == [entity.url])
}

@Test func downloadAddressesTheItemByItsCameraURL() async throws {
	let client = MockVIRBClient()
	let entity = MediaFactory.item(name: "A.MP4")
	let destination = URL(fileURLWithPath: "/tmp/A.MP4")

	let result = try await GalleryRepository(client: client).download(entity, to: destination) { _ in }

	#expect(result == destination)
	#expect(client.downloadedURLs == [entity.url])
}

@Test func snapshotReturnsTheNewPhotoAsAnEntity() async throws {
	let client = MockVIRBClient()
	client.snapResult = .success(.stub(name: "SNAP.JPG", kind: .photo))

	let item = try await GalleryRepository(client: client).snapshot()

	#expect(item.name == "SNAP.JPG")
	#expect(item.kind == .photo)
}

@Test func cameraFailuresPropagateUnchanged() async {
	let client = MockVIRBClient()
	client.mediaListError = VIRBError.notActivePhone

	await #expect(throws: VIRBError.notActivePhone) {
		_ = try await GalleryRepository(client: client).media()
	}
}
