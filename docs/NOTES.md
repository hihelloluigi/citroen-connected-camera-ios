# Notes

Accepted tradeoffs and deferred work, newest first. The log of "why is this half-done?"

## 2026-08-29 — The scripted camera serves pictures now, but not video

`ScriptedVIRBClient` answered the control protocol and nothing else, which was enough for a UI test
asserting on labels and badges and not enough for anything anyone looks at. The grid hands
`thumbURL` to `AsyncImage`, which is a plain `URLSession.shared` GET to `192.168.0.1` — an address
that resolves to nothing in the Simulator — so every cell fell through to its failure placeholder
and the media detail screen sat on its spinner forever. The one screen the app exists for was the
one screen you could not photograph, demo, or show a reviewer.

`ScriptedCameraURLProtocol` fills that in: a `URLProtocol` registered by `AppComposition` only under
`-uiTestMode`, claiming GETs to `/thumb/` and `/DCIM/` on the camera host and nothing else, so
`POST /virb` is untouched and a normal launch never reaches the class. It serves three bundled
JPEGs, picked by a checksum of the file name so a thumbnail and its full-size are always the same
picture and a reload never reshuffles the grid. The frames are deliberately drawn rather than
photographic — a demo build must not look like it is showing real footage from somebody's car.

**Still deferred:** video playback. A video's `url` gets a frame too, which is what the grid and the
share sheet need, but it is a JPEG under an `.MP4` name and `MediaDetailView`'s player cannot play
it. A real demo clip means encoding one and shipping it in the binary, and the honest reason it is
not done is that nothing needed it yet.

**This is not yet the demo mode App Review needs.** It is the media half of it. The gate is still
`-uiTestMode`, and a reviewer cannot pass launch arguments — see the entry below.

## 2026-08-29 — The gallery at accessibility sizes, and a bug it surfaced

Scaling the type and making the onboarding screens scroll did not carry the gallery. Walking it at
AX5 found four separate breakages, all of the same shape: a row of items that fits at 17pt and
hyphenates at 53pt. The status chips rendered as "SD rea/dy" and "GP/S/fix", the selection bar's
Download button as "Down-load" beside a Delete button of a different height, the detail screen's
three actions as "Save / Shar/e / Dele/te", and the thumbnail badges as "V…".

`AdaptiveStack` is the shared answer: horizontal at normal sizes, vertical at accessibility ones.
It branches on `dynamicTypeSize.isAccessibilitySize` rather than using `ViewThatFits`, because the
buttons it wraps are `maxWidth: .infinity`-greedy — they accept any width offered, so a horizontal
layout always reports that it fits and `ViewThatFits` never falls through. The badge takes a
different fix: over a 100pt grid cell there is no width to give it, so at accessibility sizes it
drops its text and keeps its symbol, which the cell's accessibility label already spells out.

**The bug:** the camera-details sheet showed "Reading camera details…" forever. The device load was
a `.task` on `StatusHeaderView`, and the gallery's 3s connectivity poll reassigns `model.status`,
which rebuilds the header and resets its `@State device` to nil — the poll raced the load and won,
every time. The load now lives on the sheet, which is the only thing that reads it. This was
present before Dynamic Type and had nothing to do with it; walking the screen slowly is what found
it.

**Still not covered:** VoiceOver navigation order, which is a different audit from text size.

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

## 2026-08-28 — Dynamic Type, and the layout change it forced

`AppFont` moved from fixed `Font.system(size:)` to `Font.TextStyle`-based roles, so all type scales.
The style each role maps to preserves the size it already rendered at, which is why the mapping is
not always the obvious one — `callout` is a `.subheadline` because that is the 15pt style. Only
`mono` moved, 14pt to 15pt, because there is no 14pt system text style and inventing one with
`.custom` would give up the platform's scaling curve to save a point.

Scaling the fonts turned out to be half the work. At AX5 the welcome copy truncated mid-word with
no way to read the rest: the onboarding screens are `VStack`s with `Spacer()`s and a fixed height,
so the extra height had nowhere to go. `ScrollableScreen` wraps each one in a `ScrollView` whose
content carries `minHeight: proxy.size.height` — the small-text layout is byte-identical because the
content still fills the screen and the `Spacer()`s still distribute, and the scroll only engages
once the content genuinely outgrows the viewport. `HeroIcon` does the same job for the large SF
Symbols, which `@ScaledMetric` has to scale because `.font(.system(size:))` will not.

The gallery was walked at AX5 afterwards and needed four more fixes — the assumption that "the grid
is already a `ScrollView` so it should behave" was wrong. See the entry below.

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
