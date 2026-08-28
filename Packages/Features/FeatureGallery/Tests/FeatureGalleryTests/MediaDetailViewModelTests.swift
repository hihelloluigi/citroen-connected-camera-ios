import CoreCamera
import CoreDomain
import Foundation
import Testing
@testable import FeatureGallery

@MainActor
@Test func saveToPhotosDownloadsThenSaves() async {
	let service = FakeGalleryRepository()
	let saver = FakePhotoLibrarySaver()
	let item = MediaFactory.item(name: "A.MP4")
	let model = MediaDetailViewModel(item: item, repository: service, photoSaver: saver)

	await model.saveToPhotos()

	#expect(service.downloadedNames == ["A.MP4"])
	#expect(saver.savedNames == ["A.MP4"])
	#expect(model.didSaveToPhotos == true)
	#expect(model.isSaving == false)
}

@MainActor
@Test func saveToPhotosSurfacesErrorOnFailure() async {
	let service = FakeGalleryRepository()
	service.downloadError = VIRBError.cameraUnreachable
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 repository: service, photoSaver: FakePhotoLibrarySaver())

	await model.saveToPhotos()

	#expect(model.didSaveToPhotos == false)
	#expect(model.actionError == UserFacingError(VIRBError.cameraUnreachable))
}

@MainActor
@Test func deleteReturnsTrueOnSuccess() async {
	let service = FakeGalleryRepository()
	let item = MediaFactory.item(name: "A.MP4")
	let model = MediaDetailViewModel(item: item, repository: service, photoSaver: FakePhotoLibrarySaver())

	let deleted = await model.delete()

	#expect(deleted == true)
	#expect(service.deletedBatches.map { $0.map(\.name) } == [["A.MP4"]])
}

@MainActor
@Test func deleteReturnsFalseAndSurfacesErrorOnFailure() async {
	let service = FakeGalleryRepository()
	service.deleteError = VIRBError.notActivePhone
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 repository: service, photoSaver: FakePhotoLibrarySaver())

	let deleted = await model.delete()

	#expect(deleted == false)
	#expect(model.actionError == UserFacingError(VIRBError.notActivePhone))
}

@MainActor
@Test func prepareShareURLReturnsDownloadedFileURL() async {
	let service = FakeGalleryRepository()
	let model = MediaDetailViewModel(item: MediaFactory.item(name: "A.MP4"),
									 repository: service, photoSaver: FakePhotoLibrarySaver())

	let url = await model.prepareShareURL()

	#expect(url?.lastPathComponent == "A.MP4")
}
