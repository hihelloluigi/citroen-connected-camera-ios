# Security policy

## Reporting a vulnerability

**Please do not open a public issue for a security problem.**

Use GitHub's private vulnerability reporting instead:
[**Report a vulnerability**](https://github.com/hihelloluigi/citroen-connected-camera-ios/security/advisories/new).
It is enabled on this repository and the report stays private until a fix is published.

This is a spare-time project with one maintainer, so please allow a few days for a first reply.
When you report, it helps to include the iOS version, the app version, and the steps that reproduce
the problem.

## Supported versions

Only `main` is supported. There are no release branches and no backports — fixes land on `main` and
you rebuild.

## Scope

In scope: anything in this repository — the app, its packages, the build scripts, and the CI
workflows.

Out of scope, because they are not this project's to fix:

- **The camera's own firmware.** Report those to Citroën or Stellantis. The protocol notes in
  [API_ANALYSIS.md](API_ANALYSIS.md) describe what the camera does; they do not make it this
  project's behaviour.
- **The official ConnectedCAM app.** Unrelated software from a different vendor.

## Known and accepted by design

These are properties of the camera, documented so nobody spends time reporting them as findings:

- **The camera speaks cleartext HTTP.** There is no TLS on the device, at `192.168.0.1`, and it
  cannot be added from the client side. `NSAllowsLocalNetworking` is set for exactly this reason
  and is scoped to local addresses only.
- **Media downloads are unauthenticated.** `GET /media/...` needs no handshake, so anyone already
  on the camera's Wi-Fi can read the recordings. The defence is the Wi-Fi password, which is why
  the app's setup flow pushes you to change it away from the factory default.
- **The app has no accounts, no backend and no analytics.** The only value it persists is a
  generated phone id in the Keychain and the onboarding flags in `UserDefaults`. See
  [`PrivacyInfo.xcprivacy`](App/Resources/PrivacyInfo.xcprivacy).

## What this project does not carry

There is one build-time secret, `CCAM_TEAM_ID`, and it is only an Apple Developer Team ID needed to
sign for a device. There is no API key, because there is no server. See [docs/SECRETS.md](docs/SECRETS.md).
