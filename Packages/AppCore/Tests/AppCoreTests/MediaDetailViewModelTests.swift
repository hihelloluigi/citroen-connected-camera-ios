import Foundation
import Testing
import VIRBKit
@testable import AppCore

@MainActor
@Test func saveToPhotosDownloadsThenSaves() async {
	let service = MockGalleryService()
	let saver = MockPhotoLibrarySaver()
	let item = MediaFactory.item(name: "A.MP4")
	let model = MediaDetailViewModel(item: item, service: service, photoSaver: saver)

	await model.saveToPhotos()

	#expect(service.downloadedNames == ["A.MP4"])
	#expect(saver.savedNames == ["A.MP4"])
	#expect(model.didSaveToPhotos == true)
	#expect(model.isSaving == false)
}

@MainActor
@Test func saveToPhotosSurfacesErrorOnFailure() async {
	let service = MockGalleryService()
	service.downloadError = VIRBError.cameraUnreachable
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 service: service, photoSaver: MockPhotoLibrarySaver())

	await model.saveToPhotos()

	#expect(model.didSaveToPhotos == false)
	#expect(model.actionError == UserFacingError(VIRBError.cameraUnreachable))
}

@MainActor
@Test func deleteReturnsTrueOnSuccess() async {
	let service = MockGalleryService()
	let item = MediaFactory.item(name: "A.MP4")
	let model = MediaDetailViewModel(item: item, service: service, photoSaver: MockPhotoLibrarySaver())

	let deleted = await model.delete()

	#expect(deleted == true)
	#expect(service.deletedBatches.map { $0.map(\.name) } == [["A.MP4"]])
}

@MainActor
@Test func deleteReturnsFalseAndSurfacesErrorOnFailure() async {
	let service = MockGalleryService()
	service.deleteError = VIRBError.notActivePhone
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 service: service, photoSaver: MockPhotoLibrarySaver())

	let deleted = await model.delete()

	#expect(deleted == false)
	#expect(model.actionError == UserFacingError(VIRBError.notActivePhone))
}

@MainActor
@Test func prepareShareURLReturnsDownloadedFileURL() async {
	let service = MockGalleryService()
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 service: service, photoSaver: MockPhotoLibrarySaver())

	let url = await model.prepareShareURL()

	#expect(url?.lastPathComponent == "A.MP4")
}
