# Citroën Connected Camera (iOS)

Unofficial open-source iOS app to browse, download, and manage recordings from the Citroën
ConnectedCAM dashcam over its local Wi-Fi API. The app is feature-complete: a guided onboarding
flow (join the camera's Wi-Fi, set a password, reconnect) hands off to a gallery — a
date-sectioned media grid with a camera status header, multi-select download and delete, a
snapshot action, and a detail screen with photo zoom, video playback, save-to-Photos, and share.

> Not affiliated with, authorized, endorsed by, or connected to Citroën, Stellantis, or Garmin.
> "Citroën" and "ConnectedCAM" are trademarks of their respective owners. Use at your own risk:
> this app talks to your camera's local API and can change settings and delete recordings.

## Quick start

```sh
brew install xcodegen      # one-time
xcodegen generate          # writes CitroenConnectedCamera.xcodeproj (git-ignored)
open CitroenConnectedCamera.xcodeproj
```

See [Running locally](docs/running.md) for full setup, device requirements, and test/build
commands.

## Documentation

- [Architecture](docs/architecture.md)
- [Running locally](docs/running.md)
- [Local API reference](API_ANALYSIS.md)

## Requirements

Xcode 16+, iOS 17+, [XcodeGen](https://github.com/yonaskolb/XcodeGen).

## License

MIT — see [LICENSE](LICENSE).
