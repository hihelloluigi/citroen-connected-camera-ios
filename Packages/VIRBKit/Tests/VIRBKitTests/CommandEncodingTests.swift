import Foundation
import Testing
@testable import VIRBKit

@Test func encodesCommandBody() throws {
    let data = VIRBCommand.body("activePhoneRequest", ["phoneId": .string("ABC")])
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(json?["command"] as? String == "activePhoneRequest")
    #expect(json?["phoneId"] as? String == "ABC")
}

@Test func encodesArrayField() throws {
    let data = VIRBCommand.body("deleteFile", ["files": .strings(["http://x/a.MP4"])])
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect((json?["files"] as? [String])?.first == "http://x/a.MP4")
}

@Test func encodesIntField() throws {
    let data = VIRBCommand.body("saveVideoDuration", ["seconds": .int(20)])
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(json?["seconds"] as? Int == 20)
}
