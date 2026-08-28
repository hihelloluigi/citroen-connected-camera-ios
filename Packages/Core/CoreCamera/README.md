# CoreCamera

The dashcam's local HTTP API. One actor, one transport, one wire format.

## Invariants

**The `VIRB*` names are not a leftover.** VIRB is Garmin's protocol, which the ConnectedCAM speaks,
and it is the vocabulary `API_ANALYSIS.md` and `openapi.json` are written in. The *module* is named
for its role, per the naming rule; the types keep the protocol's own name the way `CoreLocation`
vends `CLLocationManager`. Renaming them would make the reverse-engineering notes stop matching the
code.

**This module carries no user-facing copy.** `VIRBError` has cases and diagnostic payloads, never
sentences. A transport that ships copy is a transport that has to be localized, and localizing it
would drag every consumer behind an iOS-only string catalog. `CoreLocalization` supplies the
wording.

**`VIRBClient` is an actor because the camera has one session.** Commands serialize through a single
transport with one connection per host. Two concurrent commands is not a performance question — the
camera answers the second by dropping the first.

**The models are DTOs and are named so.** They decode straight off the wire. Nothing above
`FeatureGallery/Data/` should ever hold one.

**`ScriptedVIRBClient` ships in the binary deliberately.** The app is unusable without a physical
camera, which makes every screen past Welcome unreachable in a simulator — to a UI test and to App
Review alike. `AppComposition` only selects it under `-uiTestMode`, so a normal launch cannot reach
it.
