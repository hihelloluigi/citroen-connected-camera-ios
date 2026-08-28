# CoreConnectivity

Is the camera there, and is it set up?

## Invariants

**An error that means "the camera answered" is not an error about reachability.**
`CameraSessionProbe` treats `.notActivePhone`, `.denied`, `.unexpected` and `.decoding` as proof the
camera is still on the network — it resets the session and re-handshakes in place. Only
transport-class failures report unreachable. Collapsing those two kinds of failure into one is what
used to make the app bounce out of the gallery whenever another phone took control.

**Setup state is carried across heartbeats.** `periodicUpdate` doesn't report it, so the value from
the last successful `initialConnection` handshake is what the snapshot carries. Setup only ever
changes through this app's own onboarding, so a stale value is not a risk; re-handshaking on every
poll would be.

**`LiveWiFiInfo` is `#if os(iOS)`-guarded rather than making the module iOS-only.** The monitor and
the probe are the parts worth testing, and keeping them macOS-buildable is what lets them run under
`swift test` with no simulator.
