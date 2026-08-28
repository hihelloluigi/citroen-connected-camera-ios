# CoreUI

Design tokens, shared components, and the accessibility identifiers the UI suite addresses.

## Invariants

**`accent` and `accentEmphasis` are two roles, not two shades.** `accent` is only ever a filled
surface — it is the brand periwinkle unchanged in both appearances, which is light enough to carry
`onAccent` at ~9.8:1 and far too light to read as a foreground on a light background (1.5:1).
`accentEmphasis` takes every foreground use and is darkened for light mode. Using one where the
other belongs is not a style slip; it is invisible text.

**`PrimaryButton`'s hairline is not decoration.** A `#C7C8E5` fill has no visible edge against
`AppColor.background`. The stroke is `accentEmphasis`, which *is* the fill colour in dark mode, so it
self-cancels exactly where the fill already stands on its own.

**`AccessibilityID` lives here rather than in the test bundle.** The features that set the
identifiers and the bundle that reads them would otherwise hold duplicate literals that drift — and a
UI test querying an identifier nobody sets any more does not fail loudly, it hangs until the
existence timeout.

**`AppSettings` is `#if canImport(UIKit)`-guarded rather than making the module iOS-only.** CoreUI is
the one module both features and the app share; keeping it macOS-buildable is what lets its token and
formatter tests run without a simulator.

**Fonts are fixed sizes and do not scale.** That is a known gap, recorded in `docs/NOTES.md`, not an
intended design.
