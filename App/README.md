# App target

The shell. It composes; it does not implement.

## Invariants

**`AppComposition` is the only place that names a live implementation.** Each module vends its own —
`KeychainSecureStore`, `GalleryRepository`, `LiveWiFiInfo` — and nothing below the composition root
knows which one it got. No `Live*` type may be *defined* here; a SwiftLint custom rule enforces it.

**`RootView` asks a Builder for a view and does nothing else.** It constructs no ViewModel of its
own. If a screen needs assembling, that belongs in the feature's Builder.

**`AppDestination` has two cases, not seven.** The six onboarding screens are one flow whose step
`FeatureOnboarding` owns. The shell decides between that flow and the gallery, and nothing more.

**`RoutingController` is where the features' navigation actions land.** It folds each reported fact
into the routing input that drives `RootCoordinator`. Features never touch the coordinator.

**`-uiTestMode` is the only path to `ScriptedVIRBClient`.** Two launch arguments, read in one place
so the whole surface is visible at a glance. A normal launch matches neither.
