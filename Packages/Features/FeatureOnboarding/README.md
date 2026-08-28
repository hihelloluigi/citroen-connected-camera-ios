# FeatureOnboarding

Six screens, one linear flow, one state machine.

## Invariants

**`ResolveOnboardingStepUseCase` is the only thing that decides.** It is a total function — every
input yields exactly one answer — from resolved facts to a step, or `nil` when the flow is done. The
app shell asks "onboarding or gallery" and a `nil` is what answers it. Moving any of that into a
View, a ViewModel or the shell takes away the ability to test the whole flow exhaustively in
milliseconds instead of with a camera and a stopwatch.

**This feature has no `Coordinator/`, and that is deliberate.** The flow is linear and
root-replacing: its entire navigation state is one `OnboardingStep`, derived from facts the shell
already holds. A coordinator here would own a single value `RootCoordinator` would have to mirror.
`FeatureGallery` keeps one because it has a real stack.

**The flow never touches the app's routing.** It emits `OnboardingNavigationAction` — flags
persisted, password changed, camera back, a fresh reading — and the shell folds each into its
routing input. A feature that imports the app shell is not a layer boundary at all, which is what
this replaced.

**A rejected password must not move the flow.** `changePassword` rethrows and reports nothing on
`.passwordRejected`, so the step stays put and the screen can offer the current-password recovery
field. Reporting `passwordChanged` on failure would pin the user on Reconnect waiting for a camera
that never kicked them off.

**Reconnect takes priority even while unreachable.** Changing the password makes the camera restart
its Wi-Fi and drop every client, so "unreachable" right afterwards is the expected state, not a
failure. The pin is released by `finishReconnect` once the camera is back *and* reports setup
complete — gating on both is what avoids a transient bounce back to Set password.

**Finishing onboarding is idempotent.** `applyConnectivity` runs on a 2s poll; without the
`hasCompletedOnboarding` check it would claim the active-phone slot on every tick.

**Location is optional, and the copy says so.** Any answered decision resolves the step — grant or
deny. "Not now" is a first-class choice, not a way to get nagged again.
