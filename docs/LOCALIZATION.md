# Localization

The app ships in **en, it, es and fr**. Every user-facing string lives in one place:
`Packages/Core/CoreLocalization/Sources/CoreLocalization/Resources/Localizable.xcstrings`.

## Adding or changing a string

1. Add the key to `Localizable.xcstrings` with all four locales.
2. Add an accessor to the matching enum in `Strings/` — `CommonStrings`, `OnboardingStrings`,
   `GalleryStrings`, `CameraErrorStrings`.
3. Use the accessor. Never `String(localized:)` at a call site.

Keys are namespaced snake_case (`gallery.status_no_gps`). Call sites go through the typed enums so a
renamed key is a compile error rather than a string that silently renders as its own identifier —
which reads as plausible text in a screenshot and is easy to ship.

`CoreLocalizationTests` fails the build if a key is missing from any locale, if a translation's
format specifiers don't match English's, or if an accessor comes back as its own key.

## Where copy is allowed to live

Only in `CoreLocalization` and in the Feature packages that read it. `CoreCamera` and `CoreDomain`
carry none: `VIRBError` has no message, `UserFacingError` is a case-carrying enum, and
`PasswordRules` returns a `PasswordRuleViolation`. `CoreLocalization/Extensions/` turns those cases
into sentences, which is why `CoreLocalization` depends on `CoreDomain` and never the reverse.

## Gotcha: `CoreLocalization` is iOS-only, and has to be

SwiftPM's own build **copies** an `.xcstrings` into the resource bundle rather than compiling it.
Only Xcode runs `xcstringstool` over it. So under `swift test` on macOS, `String(localized:)` finds
no compiled `.strings` table and returns the raw key — every assertion about a string's *content*
passes or fails for the wrong reason.

Rather than let that divergence exist, the module is iOS-only, and its tests run through the test
plan under `xcodebuild` like the feature packages do. That is also why those tests assert against
the compiled `en.lproj/Localizable.strings` in the built bundle rather than against the `.xcstrings`
source — the source is not present at runtime, and a key that is in the catalog but absent from the
built product is exactly the failure worth catching.

The knock-on effect is the reason `CoreDomain` carries no copy: if it did, it would have to depend
on `CoreLocalization`, which would make `CoreDomain` iOS-only too, and the whole logic suite would
stop running without a simulator.

## Plurals

`gallery.delete_confirm %lld` is the one plural, and its count is interpolated into the key:

```swift
String(localized: "gallery.delete_confirm \(count)", bundle: .module)
```

A String Catalog attaches plural variations to an *argument*, so the argument has to be part of the
localization value. `String(format:)` on an already-resolved string cannot pick a plural form, and
branching on `count == 1` in Swift would be wrong the moment a language with more than two plural
categories is added. Plurals compile to a separate `Localizable.stringsdict` per locale; the test
suite checks each one exists.

## Info.plist

The three permission prompts are localized through `App/Resources/InfoPlist.xcstrings`, separately
from the module catalog, because they are read by iOS out of the app bundle rather than by any code.
`Info.plist` also declares `CFBundleLocalizations` so the App Store lists all four languages.

## Translation provenance

The Italian, Spanish and French strings were written alongside the English and have **not** been
reviewed by a native speaker. They are complete and idiomatic enough to ship a beta; treat a native
review as outstanding work before a public release.
