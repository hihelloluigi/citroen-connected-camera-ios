# Citroën Connected Camera (iOS)

Unofficial open-source iOS app to browse, download, and manage recordings from the Citroën
ConnectedCAM dashcam over its local Wi-Fi API.

> Not affiliated with, authorized, endorsed by, or connected to Citroën, Stellantis, or Garmin.
> "Citroën" and "ConnectedCAM" are trademarks of their respective owners. Use at your own risk:
> this app talks to your camera's local API and can change settings and delete recordings.

## Requirements

- Xcode 16+, iOS 17+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Getting started

```sh
brew install xcodegen      # one-time
xcodegen generate          # writes CitroenConnectedCamera.xcodeproj (git-ignored)
open CitroenConnectedCamera.xcodeproj
```

Select the **CitroenConnectedCamera** scheme and an iOS 17+ simulator, then Run. The app launches
into the onboarding flow (welcome → permissions → connect → set password → reconnect), then hands off
to the gallery: browse recordings with a camera status header, multi-select download and delete, and a
detail screen with playback and save-to-Photos.

## Status

`VIRBKit` (camera client), the app shell, `CoreUI` (design system), the full onboarding flow, and the
gallery — a date-sectioned media grid with a camera status header, multi-select download and delete, a
snapshot action, and a detail screen with photo zoom, video playback, save-to-Photos, and share — are
in place. Polish (error/empty-state refinement, accessibility, README finalization) is the last step.
