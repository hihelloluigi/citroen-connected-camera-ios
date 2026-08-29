# Running the project

How to set up, run, test, and build Citroën Connected Camera locally.

## Prerequisites

- macOS with **Xcode 26.6** (the version in `.xcode-version`), iOS 17 SDK or later.
- [Homebrew](https://brew.sh).
- [Mint](https://github.com/yonaskolb/Mint): `brew install mint`

XcodeGen and SwiftLint are **not** installed by hand. `Mintfile` pins both, and `bootstrap.sh`
installs exactly those versions — a `brew install xcodegen` would resolve whatever is current and
quietly generate a different project than everyone else's.

## First-time setup

```sh
./scripts/bootstrap.sh
open CitroenConnectedCamera.xcodeproj
```

That installs the pinned tools, generates `Configurations/Secrets.xcconfig` for Development, and
generates the project. It is safe to re-run.

A fresh clone needs no configuration to build and run on the simulator. To sign for a **physical
device**, create the environment file first:

```sh
cp envs/.env.example envs/.env.development   # then set CCAM_TEAM_ID
```

See [SECRETS.md](SECRETS.md) for the whole pipeline. `envs/.env.*` and
`Configurations/Secrets.xcconfig` are both git-ignored, so your team ID is never committed.

`CitroenConnectedCamera.xcodeproj` is generated from `project.yml` and git-ignored. Rerun
`mint run xcodegen generate` whenever you add, remove or move a file; Xcode-UI changes to the
project are discarded on the next generate.

## Schemes

| Scheme | Bundle id | Display name |
|---|---|---|
| Development | `me.luigiaiello.ccam.development` | C-CAM Dev |
| Staging | `me.luigiaiello.ccam.staging` | C-CAM Beta |
| Production | `me.luigiaiello.ccam` | C-CAM |

They differ only in bundle id, display name and signing team — there is no backend to point at, so
all three talk to the same camera. Separate bundle ids mean a Development and a TestFlight build can
sit on a device side by side.

## Running the app

Pick the **Development** scheme and an iOS 17+ simulator or device, then Run.

> [!IMPORTANT]
> The connect step and the gallery talk to the physical camera over its own Wi-Fi access point at
> `192.168.0.1`, which a simulator cannot join. To exercise the real flow — connect, set password,
> reconnect, browse, download, delete — run on a **physical device joined to the camera's Wi-Fi**.

To see the later screens in the Simulator without a camera, launch with a scripted one:

```sh
xcrun simctl launch <device-udid> me.luigiaiello.ccam.development \
  -uiTestMode ready -uiTestResetState
```

`ready`, `fresh` and `absent` are the scenarios; `-uiTestResetState` clears the persisted onboarding
flags. This is the same mechanism the UI suite uses — see [TESTS.md](TESTS.md).

## Permissions and entitlements

- **Access WiFi Information** (`com.apple.developer.networking.wifi-info`, in
  `Configurations/CitroenConnectedCamera.entitlements`) — reads the joined network's SSID to confirm you
  are on the camera.
- **Usage strings** live in `Configurations/Info.plist` and are localized through
  `App/Resources/InfoPlist.xcstrings`:
  - `NSLocalNetworkUsageDescription` — needed to reach the camera at all.
  - `NSLocationWhenInUseUsageDescription` — needed to read the Wi-Fi SSID on iOS.
  - `NSPhotoLibraryAddUsageDescription` — needed to save downloads to the photo library.
- **ATS**: `NSAllowsLocalNetworking` permits cleartext HTTP to local addresses, since the camera
  serves plain HTTP with no TLS.

Denying Local Network blocks the app from reaching the camera at all. Denying Location only means
the app cannot show the confirmed SSID — the flow continues, which is why the screen offers "Not
now" as a first-class choice.

## Running the tests

The whole suite, all eleven targets:

```sh
./scripts/test.sh                 # newest installed iPhone
./scripts/test.sh "iPhone 17 Pro" # a named one
```

Individual Core modules that build for macOS run without a simulator:

```sh
cd Packages/Core/CoreCamera && swift test
```

That works for `CoreCamera`, `CoreConnectivity`, `CoreDomain`, `CoreStorage` and `CoreUI` — not for
`CoreLocalization` or the feature packages, which are iOS-only. See [TESTS.md](TESTS.md).

## Building and linting

```sh
mint run xcodegen generate
xcodebuild -project CitroenConnectedCamera.xcodeproj -scheme Development \
  -destination 'generic/platform=iOS Simulator' -skipPackagePluginValidation build
mint run swiftlint lint --strict --config .swiftlint.yml
```

SwiftLint must report 0 violations. `warning_threshold: 1` makes any single violation — warning or
error — a build failure, and the build-tool plugin runs the same rules per package during a build,
so a lint regression fails `xcodebuild` too, not only the standalone gate.
