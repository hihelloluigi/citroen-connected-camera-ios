# Architecture

## Overview

The app is split into three Swift Package Manager libraries — `VIRBKit`, `CoreUI`, and `AppCore`
— that hold all the testable, platform-neutral logic, plus a thin app target (`App/App`) that is
the iOS shell. The app target supplies the live OS/camera implementations (Keychain, Location,
Wi-Fi info, Photos) and the SwiftUI screens; the packages know nothing about UIKit, AVKit, Photos,
or CoreLocation. This split keeps the logic unit-testable in isolation from the simulator/device —
`AppCore` even builds and tests on macOS — and confines every non-portable framework import to the
app target.

## Modules

### VIRBKit

The camera client: `VIRBClient` (an `actor` implementing `VIRBClientProtocol`), the request/response
models (`CameraSession`, `CameraStatus`, `DeviceInfo`, `MediaItem`), `VIRBError`, and the transport
layer (`VIRBTransport`, `URLSessionTransport`, `VIRBCommand`). No UI code. Transport-layer tests run
against a mocked `URLProtocol` over fixtures captured from the real camera, so the suite exercises
real request/response bytes without needing hardware.

### CoreUI

Design tokens (`Packages/CoreUI/Sources/CoreUI/Tokens`: `AppColor`, `AppFont`, `AppSpacing`,
`AppRadius`, `AppSize`, `AppIconSize`, `AppOpacity`, plus `Color+Adaptive`/`Color+Hex` helpers) and
reusable components (`Packages/CoreUI/Sources/CoreUI/Components`: `PrimaryButton`, `SecondaryButton`,
`PressableButtonStyle`, `Badge`, `LabeledField`, `TelemetryText`, `ErrorStateView`,
`EmptyStateView`), all built to render correctly in both light and dark mode.

### AppCore

The coordinator/router (`AppCoordinator`, `AppRouter`, `RoutingController`, `RoutingInput`,
`RoutingInputAssembler`, `AppDestination`), the composition root (`AppEnvironment`), the service
protocols (`PermissionsService`, `WiFiInfoService`, `ConnectivityMonitor`), onboarding
(`OnboardingActions`, `OnboardingFlags`, `PasswordRules`), gallery (`GalleryService`,
`MediaListViewModel`, `MediaDetailViewModel`, `MediaSection`, `PhotoLibrarySaver`, `LoadState`,
`UserFacingError`, `GalleryAccessibility`), and phone-id persistence (`PhoneIdStore`,
`SecureStore`). Every view model here is `@MainActor @Observable` with no `import SwiftUI` — they
are plain, unit-testable state holders that any SwiftUI (or other) view can bind to.

### App target

`App/App` is `@main` (`CitroenConnectedCameraApp`), `RootView` (switches on
`AppCoordinator.destination` to pick a screen), the composition root's live half
(`AppEnvironment+Live.swift`, which builds `AppEnvironment.live()`), the live service
implementations (`KeychainSecureStore`, `LiveLocationPermissions`, `LiveWiFiInfo`,
`LiveGalleryService`, `LivePhotoLibrarySaver`, `CameraReachabilityProbe`), the feature views under
`App/App/Features/Onboarding` and `App/App/Features/Gallery`, and `Info.plist` /
`CitroenConnectedCamera.entitlements`.

## The core pattern

`AppEnvironment.live()` is built once, in `CitroenConnectedCameraApp`, and passed down through
`RootView` — a single composition root, not a DI container. Every dependency it holds
(`VIRBClientProtocol`, `OnboardingFlagsStore`, `PermissionsService`, `WiFiInfoService`,
`GalleryService`, `PhotoLibrarySaver`, `ConnectivityMonitor` — itself wrapping a `ReachabilityProbe`)
is a `Sendable` protocol (or, for `ConnectivityMonitor`, a `@MainActor` wrapper around one) with a
live implementation in the app target and a mock/stub implementation used only by tests.

Navigation is a pure total function: `AppRouter.destination(for:)` maps a `RoutingInput` to exactly
one `AppDestination`, with no side effects, and is exhaustively unit-tested against every input
combination. `AppCoordinator` owns the current `destination` and recomputes it by calling
`AppRouter`; `RoutingController` owns the live inputs (onboarding flags, Location status,
connectivity snapshot, the just-changed-password flag), assembles them into a `RoutingInput` via
`RoutingInputAssembler`, and feeds `AppCoordinator`. Screens never decide navigation themselves —
they call into `RoutingController` (via `OnboardingActions`) and let the router react.

View models don't live in one single place: the **gallery** view models (`MediaListViewModel`,
`MediaDetailViewModel`) live in `AppCore` itself — `@MainActor @Observable`, no `import SwiftUI` —
and are unit-tested directly against mock services. The **onboarding** view models
(`App/App/Features/Onboarding/{Welcome,ConnectWiFi,LocationPermission,SetPassword,Reconnect}ViewModel.swift`)
live in the app target as thin wrappers with no tests of their own; they hold only screen-local
`@Observable` state and delegate every testable decision to `AppCore` — flag mutation and routing to
`OnboardingActions`, password validation to `PasswordRules` — so the logic worth testing is tested
where it lives, in `AppCore`, regardless of which side of the package boundary the view model itself
sits on.

## Onboarding flow

The destination sequence is `welcome → localNetworkPermission → locationPermission →
connectWiFi → setPassword → reconnect → gallery`, driven by `AppRouter.destination(for:)` from
`{onboarding flags, Location permission status, connectivity snapshot, didJustChangePassword}`:

- **welcome** until the user taps "Get started".
- **localNetworkPermission** until the app has reached the camera once (Local Network access
  confirmed).
- **locationPermission** until the user has made any Location choice (grant or deny — Location is
  optional).
- **reconnect** immediately after a password change, since the camera drops the Wi-Fi connection
  when its password changes; this takes priority even while unreachable.
- **connectWiFi** while the camera is unreachable, or while its setup state is still unknown.
- **setPassword** once reachable with `setupComplete == false` (still on the factory password).
- **gallery** once reachable with `setupComplete == true`, or (after onboarding has completed at
  least once) whenever the camera is reachable again.
- **reconnect** (post-onboarding) if the camera becomes unreachable after onboarding completed.

The camera itself is the source of truth for setup state, so the flow self-heals whenever the
camera drops off Wi-Fi or comes back — there's no separate "resume" logic, just the same router
re-evaluating the same inputs. See `../API_ANALYSIS.md` for the camera-side handshake
(`initialConnection` → `activePhoneRequest` → commands) that produces `isReachable` and
`setupComplete`.

## Gallery

`GalleryService` is the gallery's single seam over the camera: `media()`, `status()`, `device()`,
`snapshot()`, `delete(_:)`, and `download(_:to:progress:)`. The live implementation
(`LiveGalleryService`) wraps `VIRBClient`; tests use a mock, so `MediaListViewModel` and
`MediaDetailViewModel` never touch `VIRBClientProtocol` directly.

`MediaListViewModel` drives the media grid: it loads and groups items (via `MediaSection`), tracks
multi-select, and owns delete/download/snapshot actions. Deletion is optimistic — selected items
are removed from the displayed grid immediately, then the delete is confirmed against the camera
and the grid is reconciled with a fresh `refresh()`; on failure the previous grid snapshot is
restored and the error surfaced via `actionError`. Downloads go through the injected
`PhotoLibrarySaver` (backed by `PHPhotoLibrary` in the live app), so the save-to-Photos step is
mockable in tests.

`MediaDetailViewModel` drives the single-item detail screen (view, delete, save-to-Photos) with the
same `GalleryService`/`PhotoLibrarySaver` seams.

## Error handling & state

Every camera failure collapses to a `VIRBError` case (`notActivePhone`, `denied`,
`passwordRejected`, `cameraUnreachable`, `transport`, `decoding`, `unexpected`). `UserFacingError`
converts any thrown error into one human-voiced line: known `VIRBError`s use their own
`userMessage`; anything else becomes a generic "try again" message, so no raw `URLError` or
decoding noise ever reaches a screen.

Every gallery view model exposes a `LoadState<Value>` (`idle` / `loading` / `loaded(Value)` /
`failed(UserFacingError)`). Views switch on this to render content, a spinner, or CoreUI's
`ErrorStateView` (a centered message with an optional retry action) or `EmptyStateView` (an
empty-grid invitation to act).

## Concurrency

All three packages build under Swift 6 (`swift-tools-version: 6.0`) with strict concurrency.
`VIRBClient` is an `actor`, serializing all commands through a single transport. Every coordinator
and view model (`AppCoordinator`, `RoutingController`, `ConnectivityMonitor`,
`MediaListViewModel`, `MediaDetailViewModel`, the onboarding view models) is `@MainActor
@Observable`. All cross-boundary dependency protocols are `Sendable`. `.swiftlint.yml` enables
`force_unwrapping` and `force_try` as `error`-severity opt-in rules, so no `!` force-unwrap or
`try!` is permitted in source.

## Testing strategy

Unit-tested, no device required:

- **VIRBKit** — the client and transport against a mocked `URLProtocol` replaying fixtures
  captured from the real camera.
- **AppCore** — routing (`AppRouter` exhaustively), the coordinator, onboarding logic
  (`OnboardingActions`, `PasswordRules`), and every gallery view model (`MediaListViewModel`,
  `MediaDetailViewModel`), all driven through mock service/store implementations.
- **CoreUI** — token parsing/formatting (e.g. hex color parsing, byte-count formatting).

Build-and-device-verified, not covered by `swift test`:

- The live OS/camera wrappers in the app target (`KeychainSecureStore`, `LiveLocationPermissions`,
  `LiveWiFiInfo`, `LiveGalleryService`, `LivePhotoLibrarySaver`, `CameraReachabilityProbe`), since
  they need a real device joined to the camera's Wi-Fi AP.
- The onboarding view models in the app target (`App/App/Features/Onboarding/`) — there's no
  app-target test target, so these thin wrappers have no unit tests of their own; their logic is
  covered indirectly through the `OnboardingActions`/`PasswordRules` tests in `AppCore`, and the
  screens themselves are build-and-device-verified.
- VoiceOver behavior and the system Photos-save permission prompt.

Current counts (from `swift test`): **VIRBKit 27**, **AppCore 57**, **CoreUI 8** — 92 tests total.

## Further reading

- [`../API_ANALYSIS.md`](../API_ANALYSIS.md) — the reverse-engineered local camera API (transport,
  commands, handshake, result codes).
- [`../openapi.json`](../openapi.json) — the same API as an OpenAPI 3.0 document.
