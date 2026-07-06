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

Select the **CitroenConnectedCamera** scheme and an iOS 17+ simulator, then Run. The app currently
launches to placeholder screens driven by the onboarding router; the real onboarding and gallery
land in later milestones.

## Status

`VIRBKit` (camera client), the app shell, `CoreUI` (design system), and the first onboarding step
(welcome + permissions, with live camera-reachability routing) are in place. The connect / set‑password /
reconnect screens and the gallery are next.
