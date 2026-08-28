# CoreLocalization

Every user-facing string, in en/it/es/fr. See `docs/LOCALIZATION.md` for the workflow.

## Invariants

**This module is iOS-only, and has to be.** SwiftPM copies an `.xcstrings` rather than compiling it,
so `String(localized:)` returns the raw key under `swift test` on macOS. Rather than let that
divergence exist, the module builds for iOS only and its tests run under `xcodebuild`.

**The tests assert against the compiled bundle, not the source.** `Localizable.xcstrings` is not
present at runtime; `en.lproj/Localizable.strings` is. A key that is in the catalog but absent from
the built product is exactly the failure worth catching, and only the compiled artifact can show it.

**Call sites go through the typed enums, never `String(localized:)` directly.** A missing key
surfaces as the key itself, which reads as plausible text in a screenshot. Routing through
`CommonStrings`/`OnboardingStrings`/`GalleryStrings`/`CameraErrorStrings` turns a rename into a
compile error instead.

**The dependency on `CoreDomain` runs one way.** This module knows the domain's cases so it can word
them. `CoreDomain` must never learn about this one.

**The plural's count is interpolated into its key.** A String Catalog attaches plural variations to
an argument, so the argument has to be part of the localization value. `String(format:)` on a
resolved string cannot pick a form, and branching on `count == 1` in Swift breaks the first time a
language with more plural categories is added.
