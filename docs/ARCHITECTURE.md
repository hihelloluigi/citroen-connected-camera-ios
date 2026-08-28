# Architecture

MVVM + Coordinator over SPM modules. Each layer knows only the layer below it, and only through
protocols: Presentation depends on Domain protocols, Domain is UI-agnostic, and only `Data/` knows a
DTO exists.

## The module graph

```
App/App/                     the shell — RootCoordinator, AppComposition, RootView
  ↓
Packages/Features/           FeatureOnboarding, FeatureGallery
  ↓
Packages/Core/               CoreCamera, CoreConnectivity, CoreDomain,
                             CoreLocalization, CoreNavigation, CoreStorage, CoreUI
```

A module's folder tier and its name prefix always agree — every `Core*` under `Packages/Core/`,
every `Feature*` under `Packages/Features/`. There is no third tier. The dependency runs one way and
is enforced by `custom_rules` in `.swiftlint.yml`, not just by convention: a feature importing a
sibling feature, a Core module importing a feature, or a `Live*` type defined in the app target are
all build failures.

| Module | What it owns |
|---|---|
| `CoreCamera` | The dashcam's local HTTP API — `VIRBClient` (an actor), the transport, the wire DTOs, `VIRBError` |
| `CoreConnectivity` | Is the camera there? `ConnectivityMonitor`, `CameraSessionProbe`, SSID reading |
| `CoreDomain` | UI-agnostic shapes several layers share — permissions, onboarding flags, `LoadState`, `UserFacingError` |
| `CoreLocalization` | Every user-facing string, in en/it/es/fr |
| `CoreNavigation` | `Coordinator`, `NavigationActionHandler<Action>` |
| `CoreStorage` | Keychain and `UserDefaults` implementations |
| `CoreUI` | Design tokens, shared components, `AccessibilityID` |
| `FeatureOnboarding` | The six-screen first-run flow and the state machine behind it |
| `FeatureGallery` | The media grid, the detail screen, and the repository over the camera |

### Why `CoreCamera` and not `CoreVIRB`

VIRB is Garmin's protocol, which the ConnectedCAM speaks; it is the vocabulary
[`API_ANALYSIS.md`](../API_ANALYSIS.md) is written in. The naming rule asks that a *module* be named
for its role, so the module is `CoreCamera` while the types inside stay `VIRBClient`, `VIRBError`,
`VIRBCommand` — the same way `CoreLocation` vends `CLLocationManager`.

### Why there is no `CoreLocation` wrapper module

A wrapper around a system framework earns a module when something swaps across it. Nothing swaps
across Location here, and a module named `CoreLocation` would collide with the framework it imports,
so `LiveLocationPermissions` is a file pair in `CoreDomain/Services/` beside the protocol it
implements.

## The composition root

`AppComposition.live()` is built once, in `CitroenConnectedCameraApp`, and is the only place that
names a concrete implementation. Each module vends its own live type — `KeychainSecureStore`,
`GalleryRepository`, `LiveWiFiInfo` — and nothing below the composition root knows which one it got.

Below that, **Builders are the composition root for their screen.** `OnboardingBuilder` and
`GalleryBuilder` assemble a feature's ViewModels, use cases and coordinator and hand back a single
`View`; `RootView` does nothing but ask the right builder for one.

## Navigation

`RootCoordinator` owns one `AppDestination`, which has two cases: `.onboarding(OnboardingStep)` and
`.gallery`. The six onboarding screens are one linear, root-replacing flow whose step
`FeatureOnboarding` owns, so the shell only ever decides between that flow and the gallery.

The step machine is `ResolveOnboardingStepUseCase` — a total function from `OnboardingRoutingInput`
to an `OnboardingStep`, or `nil` when the flow is finished. Domain owns the decision; `AppRouter` is
four lines that turn `nil` into `.gallery`.

Screens never decide navigation. A ViewModel emits a `NavigationAction`, and the coordinator routes
it:

- `FeatureGallery` emits `GalleryNavigationAction.mediaTapped`, and `GalleryCoordinator` pushes the
  detail screen onto its own `NavigationStack`. The detail screen emits nothing — its only exit is a
  dismissal, which `@Environment(\.dismiss)` already handles correctly.
- `FeatureOnboarding` emits `OnboardingNavigationAction` — flags persisted, password changed, camera
  back, a fresh reachability reading — and the app shell's `RoutingController` folds each into the
  routing input that drives `RootCoordinator`. This is what replaced the flow reaching into
  `RoutingController` directly; a feature that imports the app shell is not a layer boundary at all.

### Known variance

`FeatureOnboarding` has no `Coordinator/` folder, unlike `FeatureGallery`. Its whole navigation
state is one `OnboardingStep` that the shell already routes, so a coordinator there would own a
single value `RootCoordinator` would have to mirror. `FeatureGallery` keeps one because it has a
real stack to push onto.

## The data boundary

`CoreCamera` returns DTOs decoded straight off the wire: `MediaItemDTO`, `CameraStatusDTO`,
`DeviceInfoDTO`, `CameraSessionDTO`. `GalleryRepository` — in `FeatureGallery/Data/` — is the only
type in the feature that sees one. Everything above it speaks entities.

The entities are deliberately narrower than the wire shapes. `MediaEntity` drops `sessionId` and
`videoType`, two camera-internal classifications no screen reads; `CameraStatusEntity` carries the
two facts the status header renders out of `CameraStatusDTO`'s eleven fields. A field the UI never
shows is a field the UI cannot accidentally start depending on.

The camera addresses an item by its `url`, so `delete` and `download` reconstruct a minimal DTO from
the entity rather than caching one between calls. `GalleryRepositoryTests` covers that round trip.

## Copy lives in one place

`CoreCamera` and `CoreDomain` carry no user-facing strings. `VIRBError` has no `userMessage`;
`UserFacingError` is a case-carrying enum; `PasswordRules` returns a `PasswordRuleViolation` rather
than a sentence. The wording lives in `CoreLocalization/Extensions/`, which is why that module
depends on `CoreDomain` and never the reverse.

That is not tidiness for its own sake: it is what keeps `CoreDomain` buildable for macOS. See
[`LOCALIZATION.md`](LOCALIZATION.md).

## Onboarding flow

`welcome → localNetworkPermission → locationPermission → connectWiFi → setPassword → reconnect →`
gallery, resolved from `{onboarding flags, Location status, connectivity snapshot,
didJustChangePassword}`:

- **welcome** until the user taps Get started.
- **localNetworkPermission** until the app has reached the camera once.
- **locationPermission** until the user has made any Location choice — grant *or* deny, since
  Location is optional and only supplies the network name.
- **reconnect** immediately after a password change, which takes priority even while unreachable:
  the camera restarts its Wi-Fi with the new password and drops every client.
- **connectWiFi** while the camera is unreachable, or while its setup state is still unknown.
- **setPassword** once reachable with `setupComplete == false` — still on the factory password.
- **gallery** once reachable with `setupComplete == true`.
- **reconnect** again if a finished-onboarding user loses the camera.

The camera is the source of truth for setup state, so the flow self-heals when it drops off Wi-Fi
and comes back — there is no separate resume path, just the same machine re-evaluating the same
inputs. See [`API_ANALYSIS.md`](../API_ANALYSIS.md) for the handshake that produces `isReachable` and
`setupComplete`.

## Error handling and state

Every camera failure collapses to a `VIRBError` case, then to a `UserFacingError` case, then to one
line of copy from `CameraErrorStrings`. No raw `URLError` or decoding noise reaches a screen.

Gallery ViewModels expose `LoadState<Value>` — `idle` / `loading` / `loaded` / `failed` — and views
switch on it to render content, a spinner, `ErrorStateView`, or `EmptyStateView`.

Deletion is optimistic: the selected items leave the grid immediately, the delete is confirmed
against the camera, and the grid reconciles with a fresh `refresh()`. On failure the previous grid
is restored and the error surfaced.

## Concurrency

Swift 6 with strict concurrency throughout. `VIRBClient` is an actor, serializing every command
through one transport. Coordinators and ViewModels are `@MainActor @Observable`. Cross-boundary
protocols are `Sendable`. `force_unwrapping` and `force_try` are `error`-severity, so no `!` or
`try!` appears in source — including tests.

## Further reading

- [`TESTS.md`](TESTS.md) — what is tested where, and what a `swift test` run cannot cover
- [`LOCALIZATION.md`](LOCALIZATION.md) — the string catalog and why `CoreLocalization` is iOS-only
- [`SECRETS.md`](SECRETS.md) — the `.env` → `Secrets.xcconfig` pipeline
- [`NOTES.md`](NOTES.md) — accepted tradeoffs and deferred work
- [`API_ANALYSIS.md`](../API_ANALYSIS.md) — the reverse-engineered camera API
