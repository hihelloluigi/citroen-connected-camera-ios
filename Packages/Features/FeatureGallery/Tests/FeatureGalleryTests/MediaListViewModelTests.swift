import CoreCamera
import CoreDomain
import Testing
@testable import FeatureGallery

@MainActor
@Test func loadPopulatesItemsAndStatus() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.JPG", kind: .photo)]
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	#expect(model.items.isEmpty)

	await model.load()

	#expect(model.items.map(\.name) == ["A.MP4", "B.JPG"])
	#expect(model.status != nil)
	if case .loaded = model.state {} else { Issue.record("expected .loaded, got \(model.state)") }
}

@MainActor
@Test func loadFailureSurfacesUserFacingError() async {
	let service = FakeGalleryRepository()
	service.mediaError = VIRBError.cameraUnreachable
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })

	await model.load()

	#expect(model.items.isEmpty)
	#expect(model.state == .failed(UserFacingError(VIRBError.cameraUnreachable)))
}

@MainActor
@Test func refreshAfterLoadedKeepsItemsWhenItFails() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4")]
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()

	service.mediaError = VIRBError.cameraUnreachable
	await model.refresh()

	#expect(model.items.map(\.name) == ["A.MP4"]) // prior content retained, no flash-to-error
}

@MainActor
@Test func toggleTracksSelection() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.MP4")]
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()

	model.setSelecting(true)
	model.toggle("A.MP4")
	#expect(model.selection == ["A.MP4"])
	model.toggle("A.MP4")
	#expect(model.selection.isEmpty)
	model.setSelecting(false)				// leaving select mode clears selection
	model.toggle("B.MP4")
	#expect(model.selection.isEmpty)
}

@MainActor
@Test func snapshotInsertsNewPhotoAtFront() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4")]
	service.snapshotResult = MediaFactory.item(name: "NEW.JPG", kind: .photo)
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()

	await model.snapshot()

	#expect(model.items.map(\.name) == ["NEW.JPG", "A.MP4"])
}

@MainActor
@Test func deleteSelectedRemovesOptimisticallyOnSuccess() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.MP4")]
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()
	model.setSelecting(true)
	model.toggle("A.MP4")

	await model.deleteSelected()

	#expect(service.deletedBatches.map { $0.map(\.name) } == [["A.MP4"]])
	#expect(model.items.map(\.name) == ["B.MP4"])
	#expect(model.selection.isEmpty)
	#expect(model.isSelecting == false)
}

@MainActor
@Test func deleteSelectedRestoresAndSurfacesErrorOnFailure() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.MP4")]
	service.deleteError = VIRBError.notActivePhone
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()
	model.setSelecting(true)
	model.toggle("A.MP4")

	await model.deleteSelected()

	#expect(model.items.map(\.name) == ["A.MP4", "B.MP4"]) // restored
	#expect(model.actionError == UserFacingError(VIRBError.notActivePhone))
}

@MainActor
@Test func downloadSelectedSavesEachSelectedItemToPhotos() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.JPG", kind: .photo)]
	let saver = FakePhotoLibrarySaver()
	let model = MediaListViewModel(repository: service, photoSaver: saver, onAction: { _ in })
	await model.load()
	model.setSelecting(true)
	model.toggle("A.MP4")
	model.toggle("B.JPG")

	await model.downloadSelected()

	#expect(Set(saver.savedNames) == ["A.MP4", "B.JPG"])
	#expect(Set(service.downloadedNames) == ["A.MP4", "B.JPG"])
	#expect(model.isSelecting == false)
	#expect(model.isDownloading == false)
	#expect(model.downloadingIDs.isEmpty) // in-flight markers cleared once every download settles
}

@MainActor
@Test func removeFiltersItemLocallyWithoutANetworkCall() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.MP4")]
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })
	await model.load()

	model.remove(id: "A.MP4")

	#expect(model.items.map(\.name) == ["B.MP4"])
	#expect(service.deletedBatches.isEmpty) // local-only removal, no camera call
}

@MainActor
@Test func removeOnNonLoadedModelIsANoOp() async {
	let service = FakeGalleryRepository()
	let model = MediaListViewModel(repository: service, photoSaver: FakePhotoLibrarySaver(), onAction: { _ in })

	model.remove(id: "A.MP4") // idle state, before any load

	#expect(model.items.isEmpty)
	if case .idle = model.state {} else { Issue.record("expected .idle, got \(model.state)") }
}

@MainActor
@Test func downloadSelectedSurfacesErrorWhenTheCameraDownloadFails() async {
	let service = FakeGalleryRepository()
	service.mediaResult = [MediaFactory.item(name: "A.MP4")]
	service.downloadError = VIRBError.cameraUnreachable
	let saver = FakePhotoLibrarySaver()
	let model = MediaListViewModel(repository: service, photoSaver: saver, onAction: { _ in })
	await model.load()
	model.setSelecting(true)
	model.toggle("A.MP4")

	await model.downloadSelected()

	#expect(saver.savedNames.isEmpty)				  // nothing saved when the download failed
	#expect(model.actionError == UserFacingError(VIRBError.cameraUnreachable))
	#expect(model.downloadingIDs.isEmpty)			  // marker cleared even on failure
}
