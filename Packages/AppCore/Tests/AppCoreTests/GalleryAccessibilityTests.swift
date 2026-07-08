import Testing
import VIRBKit
@testable import AppCore

@Test func labelsAPhotoWithoutGPS() {
	let item = MediaFactory.item(name: "A.JPG", kind: .photo, date: nil)
	#expect(GalleryAccessibility.label(for: item) == "Photo")
}

@Test func labelsAGeotaggedVideo() {
	let item = MediaFactory.item(name: "B.MP4", kind: .video, gps: (lat: 1, lon: 2))
	#expect(GalleryAccessibility.label(for: item) == "Video, geotagged")
}
