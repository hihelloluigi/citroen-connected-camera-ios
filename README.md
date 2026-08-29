# Citroën Connected Camera (iOS)

Unofficial open-source iOS app to browse, download, and manage recordings from the Citroën
ConnectedCAM dashcam over its local Wi-Fi API. A guided onboarding flow — join the camera's Wi-Fi,
set a password, reconnect — hands off to a gallery: a date-sectioned media grid with a camera status
header, multi-select download and delete, a snapshot action, and a detail screen with photo zoom,
video playback, save-to-Photos and share. Available in English, Italian, Spanish and French.

> Not affiliated with, authorized, endorsed by, or connected to Citroën, Stellantis, or Garmin.
> "Citroën" and "ConnectedCAM" are trademarks of their respective owners. Use at your own risk:
> this app talks to your camera's local API and can change settings and delete recordings.

## Quick start

```sh
brew install mint          # one-time
./scripts/bootstrap.sh     # pinned tools, secrets, and the .xcodeproj
open CitroenConnectedCamera.xcodeproj
```

A fresh clone builds and runs on the simulator with no configuration at all. See
[Running locally](docs/running.md) for device setup and build commands.

## Requirements

Xcode 26.6, iOS 17+, [Mint](https://github.com/yonaskolb/Mint). XcodeGen and SwiftLint are pinned in
`Mintfile` and installed by `bootstrap.sh`; there are no third-party runtime dependencies.

## Architecture

MVVM + Coordinator over SPM modules, tiered into `Packages/Core/` (8 modules) and
`Packages/Features/` (2), with a thin app shell. The layer boundaries are enforced by SwiftLint
rules, not just documented. 139 tests across eleven targets, including a UI suite that drives the real
app against a scripted camera.

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — modules, navigation, the data boundary
- [Tests](docs/TESTS.md) — what is covered where, and how to run it
- [Localization](docs/LOCALIZATION.md) — the string catalog and the four locales
- [Secrets](docs/SECRETS.md) — the `.env` → `Secrets.xcconfig` pipeline
- [Running locally](docs/running.md) — setup, devices, build commands
- [Notes](docs/NOTES.md) — accepted tradeoffs and deferred work
- [Local API reference](API_ANALYSIS.md) — the reverse-engineered camera protocol
- [`CLAUDE.md`](CLAUDE.md) — the agent index

## Before a public release

Tracked in [docs/NOTES.md](docs/NOTES.md); the short version:

- **App Review cannot test this app** without a physical camera. A demo mode or review notes plus a
  video is the largest open item, and it is not a code problem.
- **Native review of the it/es/fr translations.**
- A support URL and a privacy-policy URL for App Store Connect, and a real marketing version.

## License

MIT — see [LICENSE](LICENSE).
