# Tests

## Running them

```sh
./scripts/test.sh                 # newest installed iPhone
./scripts/test.sh "iPhone 17 Pro" # a named one
```

`TestPlans/CitroenConnectedCamera.xctestplan` is the Development scheme's default plan and
aggregates every target — the nine package suites, the app-shell unit bundle, and the UI bundle.
One invocation runs all of it, and that is what CI runs.

Individual Core packages that build for macOS can also be run without a simulator:

```sh
cd Packages/Core/CoreCamera && swift test
```

That works for `CoreCamera`, `CoreConnectivity`, `CoreDomain`, `CoreStorage` and `CoreUI`. It does
**not** work for `CoreLocalization` or either feature package — those are iOS-only. See
[`LOCALIZATION.md`](LOCALIZATION.md) for why `CoreLocalization` has to be.

## What is covered where

| Target | Tests | What it proves |
|---|---:|---|
| `CoreCameraTests` | 27 | The client and transport against a mocked `URLProtocol` replaying fixtures captured from the real camera — real request and response bytes, no hardware |
| `CoreConnectivityTests` | 7 | The session probe's handshake-vs-heartbeat sequencing, and which errors mean "the camera answered" rather than "the camera is gone" |
| `CoreDomainTests` | 10 | Password rules, onboarding flags, and the error mapping — all case-level, no copy |
| `CoreLocalizationTests` | 8 | The **compiled** catalog: same keys in every locale, matching format specifiers, a `.stringsdict` per locale, and no accessor returning its own key |
| `CoreLoggingTests` | 5 | The level ordering and its case-insensitive parsing, an unrecognised name resolving to nil rather than a default, and a non-empty subsystem |
| `CoreStorageTests` | 2 | The phone id is generated once and persists |
| `CoreUITests` | 9 | Token parsing and telemetry formatting |
| `FeatureGalleryTests` | 35 | The DTO↔entity mapping, the coordinator's stack, and every ViewModel against a fake repository |
| `FeatureOnboardingTests` | 19 | The step machine exhaustively, and what the use case persists and reports |
| `CitroenConnectedCameraTests` | 11 | The shell: routing, the coordinator, the composition root |
| `CitroenConnectedCameraUITests` | 6 | The app boots and the flow lands where the scripted camera says it should |

139 tests.

## The UI suite

The app is unusable without a physical ConnectedCAM on its own Wi-Fi, which made every screen past
Welcome unreachable in the Simulator. `ScriptedVIRBClient` (in `CoreCamera`) answers for a camera
that isn't there, and `AppComposition` selects it only when the process was launched with
`-uiTestMode`:

| Flag | Effect |
|---|---|
| `-uiTestMode absent` | Nothing answers — what a plain simulator launch looks like |
| `-uiTestMode fresh` | Reachable, setup incomplete — the flow stops at the password step |
| `-uiTestMode ready` | Reachable and set up, with media on the card — the flow reaches the gallery |
| `-uiTestResetState` | Clears the persisted onboarding flags |

`-uiTestResetState` is not tidiness. The flags live in the simulator's `UserDefaults` and survive
between tests, so without it a suite that passes in isolation can fail when run in a different
order.

Two things worth knowing before adding a UI test:

**Screens are addressed by identifier, never by text.** `AccessibilityID` lives in `CoreUI` so the
features that set the identifiers and the bundle that reads them cannot drift apart. A test matching
on "Get started" would break the moment it ran in one of the other three locales.

**A bare `.accessibilityIdentifier` on a container overwrites its children's.** Applied to a screen's
root `VStack`, it propagates down and every button inside comes back with the *screen's* identifier.
Each screen therefore marks itself `.accessibilityElement(children: .contain)` first.

**SwiftUI picks an element's type from its outermost view.** The onboarding screens resolve as
`Other`, the gallery's grid as a `ScrollView` because a `ScrollView` is what it wraps. Querying
`app.otherElements[...]` finds five screens and hangs on the sixth until the existence timeout —
which reads as a bug in the app rather than in the test. `XCUIApplication.screen(_:)` matches on
identifier without asserting a type; use it for screen containers.

## What no test covers

- The live OS wrappers — `KeychainSecureStore`, `LiveLocationPermissions`, `LiveWiFiInfo`,
  `PhotoLibrarySaver`. They need a real device, and in the case of Wi-Fi info, one joined to the
  camera's AP.
- Real camera traffic. `CoreCameraTests` replays captured fixtures, which proves the encoding and
  decoding but not that a given firmware still answers the same way.
- VoiceOver output and the system permission prompts, which live outside the app.
