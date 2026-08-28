# Notes

Accepted tradeoffs and deferred work, newest first. The log of "why is this half-done?"

## 2026-08-28 — App Review cannot test this app

The app does nothing without a physical ConnectedCAM on its own Wi-Fi, which a reviewer will not
have. `ScriptedVIRBClient` exists and makes every screen reachable, but it is gated behind
`-uiTestMode` and a reviewer cannot pass launch arguments.

**Deferred:** a demo mode reachable from the UI, or review notes plus a video. **Not decided:**
which. This is the single largest risk to a public release and it is not a code problem — see the
pre-release list in [`../README.md`](../README.md).

## 2026-08-28 — Translations are not native-reviewed

it/es/fr were written alongside the English rather than by a native speaker. Complete and consistent,
and the test suite proves no key is missing and no format specifier drifted, but neither of those
catches an awkward phrasing. **Deferred:** a native pass on the three non-English locales before a
public release.

## 2026-08-28 — `CoreLocalization` is iOS-only

SwiftPM copies an `.xcstrings` instead of compiling it, so `String(localized:)` returns the raw key
under `swift test` on macOS. **Rejected:** shipping `.lproj/.strings` files instead of a String
Catalog, which would restore macOS testing but give up the catalog's plural handling and its Xcode
tooling, and diverge from the rest of the fleet. **Accepted:** the module is iOS-only and its tests
run under `xcodebuild` through the test plan. The knock-on constraint — `CoreDomain` must carry no
copy, or it would become iOS-only too and take the whole logic suite with it — turned out to be a
better boundary than the one it replaced.

## 2026-08-28 — No Dynamic Type

`AppFont` uses fixed `Font.system(size:)`, so text does not scale with the user's text size setting.
Everything already routes through the token, so this is a contained change; it has simply not been
made. **Deferred**, and it is an accessibility gap, not a preference.

## 2026-08-28 — Three build configurations, not six

beam uses `{Debug,Release} × {Development,Staging,Production}`. This app has no backend to point at
— the camera is the only server and it is identical on every unit — so a configuration only ever
varies the bundle id, the display name and the signing team. **Accepted:** three, matching pieno.
Staging exists so a TestFlight build can sit on a device beside a Development one, not because it
resolves anything different.

## 2026-08-28 — `FeatureOnboarding` has no coordinator

Onboarding is linear and root-replacing: its whole navigation state is one `OnboardingStep`, derived
by `ResolveOnboardingStepUseCase` from facts the shell already holds. A coordinator would own a
single value that `RootCoordinator` would have to mirror. **Accepted** as documented variance;
`FeatureGallery` keeps its coordinator because it has a real `NavigationStack` to push onto.

## 2026-08-28 — The `Live*` prefix is inconsistent, deliberately

`LiveLocationPermissions`, `LiveWiFiInfo` and `KeychainSecureStore` keep platform-implementation
names, while the gallery's two implementations are `GalleryRepository` and `PhotoLibrarySaver` with
no prefix. The naming table gives repositories their own form (`NounRepository`), and these are
repositories. Not an oversight; both conventions are in force at once because they cover different
things.
