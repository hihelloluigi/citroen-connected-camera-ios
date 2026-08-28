import Testing
@testable import FeatureGallery

@MainActor
@Test func tappingAnItemPushesItOntoThePath() {
	let coordinator = GalleryCoordinator()
	let item = MediaFactory.item(name: "A.MP4")

	coordinator.handle(.mediaTapped(item))

	#expect(coordinator.path == [item])
}

@MainActor
@Test func consecutiveTapsStack() {
	let coordinator = GalleryCoordinator()
	let first = MediaFactory.item(name: "A.MP4")
	let second = MediaFactory.item(name: "B.JPG", kind: .photo)

	coordinator.handle(.mediaTapped(first))
	coordinator.handle(.mediaTapped(second))

	#expect(coordinator.path == [first, second])
}

@MainActor
@Test func popToRootClearsTheWholePath() {
	let coordinator = GalleryCoordinator()
	coordinator.handle(.mediaTapped(MediaFactory.item(name: "A.MP4")))
	coordinator.handle(.mediaTapped(MediaFactory.item(name: "B.JPG", kind: .photo)))

	// Called after the detail screen deletes what it was showing: the screen underneath has
	// nothing left to show for that item either.
	coordinator.popToRoot()

	#expect(coordinator.path.isEmpty)
}

@MainActor
@Test func coordinatorStartsAtTheGrid() {
	#expect(GalleryCoordinator().path.isEmpty)
}
