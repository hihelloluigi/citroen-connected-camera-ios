import SwiftUI
import Testing
@testable import CoreUI

@Test func parsesSixDigitHexWithHash() {
    let rgb = Color.rgb(hex: "#F5A524")
    #expect(rgb?.r == Double(0xF5) / 255)
    #expect(rgb?.g == Double(0xA5) / 255)
    #expect(rgb?.b == Double(0x24) / 255)
}

@Test func parsesSixDigitHexWithoutHash() {
    #expect(Color.rgb(hex: "0E1116") != nil)
}

@Test func rejectsMalformedHex() {
    #expect(Color.rgb(hex: "") == nil)
    #expect(Color.rgb(hex: "#FFF") == nil)      // 3-digit not supported
    #expect(Color.rgb(hex: "#GGGGGG") == nil)   // non-hex
    #expect(Color.rgb(hex: "12345678") == nil)  // too long
}
