//
//  LocalizationCatalogTests.swift
//  CoreLocalizationTests
//

import Foundation
import Testing
@testable import CoreLocalization

/// The four locales the app ships.
private let shippedLocales = ["en", "it", "es", "fr"]

/// These assert against the *compiled* bundle — the `.lproj` folders Xcode's xcstringstool
/// produces — rather than the `Localizable.xcstrings` source. That is deliberate: the source is
/// not present at runtime, and a key that is in the catalog but absent from the built product is
/// exactly the failure worth catching. A missing translation never throws; it silently falls back
/// to English, which is how a half-localized build reaches the App Store unnoticed.
private func strings(for locale: String) throws -> [String: String] {
	let path = try #require(Bundle.module.path(forResource: locale, ofType: "lproj"),
							"no \(locale).lproj in the built bundle")
	let url = URL(fileURLWithPath: path).appendingPathComponent("Localizable.strings")
	let plist = try PropertyListSerialization.propertyList(
		from: try Data(contentsOf: url), format: nil)
	return try #require(plist as? [String: String])
}

@Test func bundleShipsEveryLocale() throws {
	let available = Set(Bundle.module.localizations)
	for locale in shippedLocales {
		#expect(available.contains(locale), "\(locale) is missing from the built bundle")
	}
}

@Test func everyLocaleDefinesTheSameKeys() throws {
	let english = Set(try strings(for: "en").keys)
	#expect(!english.isEmpty)

	for locale in shippedLocales.dropFirst() {
		let keys = Set(try strings(for: locale).keys)
		#expect(english.subtracting(keys).isEmpty,
				"\(locale) is missing: \(english.subtracting(keys).sorted())")
		#expect(keys.subtracting(english).isEmpty,
				"\(locale) has keys English doesn't: \(keys.subtracting(english).sorted())")
	}
}

@Test func noTranslationIsLeftAsEnglishPlaceholderText() throws {
	let english = try strings(for: "en")
	// Not every string differs across locales — "OK" and "Firmware" are the same word in several —
	// so this asserts the bulk of them were actually translated rather than copied.
	for locale in shippedLocales.dropFirst() {
		let translated = try strings(for: locale)
		let identical = english.filter { translated[$0.key] == $0.value }.count
		#expect(Double(identical) / Double(english.count) < 0.2,
				"\(locale) still matches English for \(identical) of \(english.count) keys")
	}
}

@Test func formatSpecifiersMatchAcrossLocales() throws {
	let english = try strings(for: "en")
	// A translation that drops or adds a specifier crashes at String(format:) time rather than
	// merely reading wrong, so the count has to be identical in every locale.
	for locale in shippedLocales.dropFirst() {
		let translated = try strings(for: locale)
		for (key, value) in english {
			guard let other = translated[key] else { continue }
			#expect(specifierCount(value) == specifierCount(other),
					"\(key) has mismatched specifiers in \(locale)")
		}
	}
}

@Test func everyLocaleShipsTheCompiledPlural() throws {
	// The multi-select delete confirmation is the one plural, and plurals compile into a separate
	// .stringsdict — absent from .strings, so the check above cannot see it.
	for locale in shippedLocales {
		let path = try #require(Bundle.module.path(forResource: locale, ofType: "lproj"))
		let url = URL(fileURLWithPath: path).appendingPathComponent("Localizable.stringsdict")
		#expect(FileManager.default.fileExists(atPath: url.path), "\(locale) has no stringsdict")
	}
}

@Test func pluralisedDeleteConfirmationResolvesBothForms() {
	let one = GalleryStrings.deleteConfirm(count: 1)
	let many = GalleryStrings.deleteConfirm(count: 3)
	// Exercises the interpolated-key path end to end: the one/other split has to come back from
	// the catalog, not from a Swift branch, and neither form may be the raw key.
	#expect(one != many)
	#expect(!one.contains("gallery.delete_confirm"))
	#expect(many.contains("3"))
}

@Test func formattedStringsSubstituteTheirArgument() {
	#expect(OnboardingStrings.connectOnNetwork(ssid: "ConnectedCAM0000").contains("ConnectedCAM0000"))
	#expect(GalleryStrings.geotagged(kind: "Video").contains("Video"))
	#expect(CameraErrorStrings.unexpected(result: 42).contains("42"))
}

@Test func plainAccessorsResolveRatherThanReturningTheirKey() {
	// A missing entry surfaces as the key itself, which reads as a plausible string in a screenshot.
	#expect(!CommonStrings.ok.contains("common."))
	#expect(!GalleryStrings.title.contains("gallery."))
	#expect(!OnboardingStrings.welcomeTitle.contains("onboarding."))
	#expect(!CameraErrorStrings.denied.contains("camera_error."))
}

private func specifierCount(_ value: String) -> Int {
	value.components(separatedBy: "%@").count - 1 + value.components(separatedBy: "%lld").count - 1
}
