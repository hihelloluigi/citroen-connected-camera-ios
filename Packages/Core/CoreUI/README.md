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
