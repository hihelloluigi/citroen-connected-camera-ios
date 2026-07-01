import Foundation
import Testing
@testable import VIRBKit

@Test func decodesVideoAndPhotoFromMediaList() throws {
    let data = try Fixture.load("mediaList")
    let response = try JSONDecoder.virb.decode(MediaListResponse.self, from: data)

    #expect(response.media.count == 2)
    let video = response.media[0]
    #expect(video.kind == .video)
    #expect(video.name == "2026_06_27_11h57_v.MP4")
    #expect(video.sessionId == 249)
    #expect(video.date == Date(timeIntervalSince1970: 1782554222))
    #expect(video.url.absoluteString == "http://192.168.0.1/media/video/DCIM/VID_NORM/2026_06_27_11h57_v.MP4")

    let photo = response.media[1]
    #expect(photo.kind == .photo)
    #expect(photo.sessionId == nil)
    #expect(photo.gpsLatitude == 45.709058)
}
