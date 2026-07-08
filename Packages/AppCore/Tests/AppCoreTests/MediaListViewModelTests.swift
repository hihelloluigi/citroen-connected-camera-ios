import Testing
import VIRBKit
@testable import AppCore

@MainActor
@Test func loadPopulatesItemsAndStatus() async {
    let service = MockGalleryService()
    service.mediaResult = [MediaFactory.item(name: "A.MP4"), MediaFactory.item(name: "B.JPG", kind: .photo)]
    let model = MediaListViewModel(service: service)
    #expect(model.items.isEmpty)

    await model.load()

    #expect(model.items.map(\.name) == ["A.MP4", "B.JPG"])
    #expect(model.status != nil)
    if case .loaded = model.state {} else { Issue.record("expected .loaded, got \(model.state)") }
}

@MainActor
@Test func loadFailureSurfacesUserFacingError() async {
    let service = MockGalleryService()
    service.mediaError = VIRBError.cameraUnreachable
    let model = MediaListViewModel(service: service)

    await model.load()

    #expect(model.items.isEmpty)
    #expect(model.state == .failed(UserFacingError(VIRBError.cameraUnreachable)))
}

@MainActor
@Test func refreshAfterLoadedKeepsItemsWhenItFails() async {
    let service = MockGalleryService()
    service.mediaResult = [MediaFactory.item(name: "A.MP4")]
    let model = MediaListViewModel(service: service)
    await model.load()

    service.mediaError = VIRBError.cameraUnreachable
    await model.refresh()

    #expect(model.items.map(\.name) == ["A.MP4"]) // prior content retained, no flash-to-error
}
