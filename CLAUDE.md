# CLAUDE.md

**This file is an index, not the manual.** It carries the quick commands, the rules an agent must
not break, and the gotchas that live nowhere else. Depth lives in `docs/` — follow the pointers
before making structural changes.

## Quick start

```sh
brew install mint          # one-time
./scripts/bootstrap.sh     # pinned tools, secrets, and the .xcodeproj
open CitroenConnectedCamera.xcodeproj
```

| Command | What |
|---|---|
| `mint run xcodegen generate` | Regenerate the project after adding, moving or removing a file |
| `mint run swiftlint lint --strict --config .swiftlint.yml` | The standalone lint gate |
| `xcodebuild test -project CitroenConnectedCamera.xcodeproj -scheme Development -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -testPlan CitroenConnectedCamera -skipPackagePluginValidation` | The whole suite — 134 tests |
| `cd Packages/Core/<Module> && swift test` | One Core module, no simulator (not `CoreLocalization`, not the features) |

Always `mint run`, never a bare `xcodegen` or `swiftlint` — a bare invocation runs whatever is on
`PATH` and silently bypasses the `Mintfile` pin.

## Tech stack

Swift 6, SwiftUI, iOS 17+. XcodeGen 2.45.4 and SwiftLint 0.65.0, both pinned in `Mintfile`; Xcode
26.6 in `.xcode-version`. No third-party runtime dependencies at all — the only remote package is
the SwiftLint build-tool plugin.

## Where things live

| Path | What |
|---|---|
| `App/App/` | The shell — `RootCoordinator`, `AppComposition`, `RootView`, and nothing else |
| `App/CitroenConnectedCameraTests/` | App-shell unit tests |
| `App/CitroenConnectedCameraUITests/` | The UI suite, driven by `ScriptedVIRBClient` |
| `Packages/Core/` | 7 `Core*` modules |
| `Packages/Features/` | `FeatureOnboarding`, `FeatureGallery` |
| `Configurations/` | **Repo root**, not under `App/` — one xcconfig per environment, one `Info.plist` |
| `envs/` | Git-ignored `.env.<environment>`; only `.env.example` is tracked |
| `project.yml` | Source of truth; the `.xcodeproj` is generated and git-ignored |
| `TestPlans/` | The Development scheme's default plan, aggregating all ten targets |
| `docs/NOTES.md` | Accepted tradeoffs and deferred work, newest first |

## Read before you change

| Doc | Read it before |
|---|---|
| `docs/ARCHITECTURE.md` | Restructuring a module, adding a coordinator, changing a layer boundary |
| `docs/TESTS.md` | Adding a test, especially a UI test |
| `docs/LOCALIZATION.md` | Adding or changing any user-facing string |
| `docs/SECRETS.md` | Touching the `.env` → `Secrets.xcconfig` pipeline |
| `docs/running.md` | Setting up, running on a device, or first-time build problems |
| `docs/NOTES.md` | Touching a "why is this half-done?" area |
| `API_ANALYSIS.md` | Anything touching the camera protocol |

## Architecture — the rules that must not break

- **A module's folder tier and its name prefix always agree.** Every `Core*` under `Packages/Core/`,
  every `Feature*` under `Packages/Features/`. There is no third tier.
- **The dependency runs one way.** Features may depend on Core; Core may never depend on a Feature;
  a Feature may never import a sibling Feature. Four `custom_rules` in `.swiftlint.yml` make each of
  these a build failure rather than a convention.
- **Builders are the composition root.** A Builder assembles a screen and returns a `View`; nothing
  below it builds anything. `AppComposition` is the only place that names a live implementation, and
  no `Live*` type may be defined in the app target.
- **No DTO reaches a ViewModel.** `GalleryRepository` is the only type in `FeatureGallery` that sees
  one. A ViewModel importing `CoreCamera` is the smell.
- **Views render, they do not decide.** A ViewModel emits a `NavigationAction`; a coordinator routes
  it.
- **Domain owns the decisions.** State machines live in UseCases —
  `ResolveOnboardingStepUseCase`, not a ViewModel and not the shell.
- **User-facing copy lives only in `CoreLocalization` and the Features that read it.** `CoreCamera`
  and `CoreDomain` carry cases, never sentences.

## Gotchas

- **A missing per-package `.swiftlint.yml` is silent.** Every package carries one holding only
  `parent_config: ../../../.swiftlint.yml`. Without it the build-tool plugin falls back to
  SwiftLint's own defaults and the root config is ignored for that package — the symptom is a wall
  of `line_length` and `identifier_name` violations the root config plainly allows, which reads as a
  code regression rather than a missing file.

- **`String(localized:)` returns the raw key under `swift test`.** SwiftPM copies an `.xcstrings`
  rather than compiling it; only Xcode runs `xcstringstool`. This is why `CoreLocalization` is
  iOS-only and why `CoreDomain` must carry no copy — see `docs/LOCALIZATION.md`. The symptom is a
  screen rendering `gallery.status_no_gps`, which looks like a missing translation rather than a
  missing build step.

- **A container's `.accessibilityIdentifier` overwrites its children's.** Applied to a screen's root
  `VStack` it propagates down, and every button inside comes back with the *screen's* identifier —
  so `app.buttons["onboarding.getStarted"]` finds nothing and the UI test hangs until its timeout.
  Each screen marks itself `.accessibilityElement(children: .contain)` first.

- **SwiftUI picks an element's type from its outermost view.** The onboarding screens resolve as
  `Other`; the gallery's grid resolves as a `ScrollView`. `app.otherElements[...]` finds five of the
  six screens and hangs on the sixth. Use `XCUIApplication.screen(_:)`.

- **Build pre-action output is invisible in Xcode's build log.** The schemes redirect
  `generate_secrets.sh` to `/tmp/ccam_secrets.log`. Check that file first when a build behaves as
  though a build setting never resolved.

- **Editing the `.xcodeproj` is pointless.** It is generated from `project.yml` and git-ignored;
  Xcode-UI changes are discarded on the next `xcodegen generate`.

- **`sed -E` on macOS has no `\b`.** BSD `sed` accepts the flag and silently matches nothing, so a
  whole-word rename appears to succeed and changes zero files. Use Python for anything word-bounded.
