# CoreUI

Design tokens, shared components, and the accessibility identifiers the UI suite addresses.

## Invariants

**`accent` and `accentEmphasis` are two roles, not two shades.** Both greens come from the app
icon. `accent` is only ever a filled surface — the icon's field colour, unchanged in both
appearances; as a mid-tone it carries near-black `onAccent` at 5.7:1 but reads at only 2.8:1 as a
foreground on a light background. `accentEmphasis` takes every foreground use and is the icon's
darker road green in light mode (5.6:1). Using one where the other belongs is not a style slip; it
is unreadable text.

**`telemetry` is deliberately outside the brand hue.** It used to be a teal, which the green brand
now occupies — at 1.05:1 against `accentEmphasis` a speed readout was indistinguishable from an
accent-tinted label. It is blue so that "this is a measurement" stays separable from "this is
actionable".

**`PrimaryButton`'s hairline self-cancels by design.** The stroke is `accentEmphasis`, which in
light mode is a deeper green than the fill and gives the CTA a defined edge, and in dark mode *is*
the fill colour — so it vanishes exactly where the fill already stands on its own.

**`AccessibilityID` lives here rather than in the test bundle.** The features that set the
identifiers and the bundle that reads them would otherwise hold duplicate literals that drift — and a
UI test querying an identifier nobody sets any more does not fail loudly, it hangs until the
existence timeout.

**`AppSettings` is `#if canImport(UIKit)`-guarded rather than making the module iOS-only.** CoreUI is
the one module both features and the app share; keeping it macOS-buildable is what lets its token and
formatter tests run without a simulator.

**Every type role is a `Font.TextStyle`, never a point size.** `Font.system(size:)` renders at one
size forever, which leaves anyone who has raised their text size reading 13pt captions. The style
each role maps to was chosen to preserve the size it already rendered at, so `callout` is a
`.subheadline` and `caption` is a `.footnote` — the names are this design system's roles, the styles
supply Apple's metrics.

**`HeroIcon` and `ScrollableScreen` exist because scaling fonts is only half of Dynamic Type.** A
symbol sized with `.font(.system(size:))` stays put while the text beside it grows, which reads as a
layout bug; `@ScaledMetric` fixes that but needs a `View` to live in. And a screen built from a
`VStack` with `Spacer()`s truncates its copy at large sizes with no way to reach the rest —
`ScrollableScreen` gives that extra height somewhere to go while keeping the small-text layout
identical.
