import Foundation
import Testing
@testable import AppCore

@Test func groupsByDayNewestFirstWithRelativeTitles() {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    let now = Date(timeIntervalSince1970: 1_000_000) // fixed reference
    let today = now
    let yesterday = now.addingTimeInterval(-86_400)
    let older = now.addingTimeInterval(-5 * 86_400)

    let items = [
        MediaFactory.item(name: "A.MP4", date: older),
        MediaFactory.item(name: "B.MP4", date: today),
        MediaFactory.item(name: "C.MP4", date: yesterday)
    ]
    let sections = MediaGrouping.sections(from: items, calendar: cal, now: now)

    #expect(sections.count == 3)
    #expect(sections[0].title == "Today")       // newest day first
    #expect(sections[0].items.map(\.name) == ["B.MP4"])
    #expect(sections[1].title == "Yesterday")
    #expect(sections[2].items.map(\.name) == ["A.MP4"])
}

@Test func undatedItemsGroupLastUnderTheirOwnTitle() {
    let now = Date(timeIntervalSince1970: 1_000_000)
    let items = [MediaFactory.item(name: "D.JPG", kind: .photo, date: nil),
                 MediaFactory.item(name: "E.MP4", date: now)]
    let sections = MediaGrouping.sections(from: items, now: now)
    #expect(sections.last?.title == "Undated")
    #expect(sections.last?.items.map(\.name) == ["D.JPG"])
}
