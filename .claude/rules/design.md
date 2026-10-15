---
paths:
  - "Wordwell/**"
  - "Packages/WordwellKit/Sources/WordwellDesign/**"
  - "Tools/**"
  - "**/*.svg"
  - "design.md"
---

## Design rules (from `design.md` — authoritative; re-read it for exact tokens)

Apply to any UI or illustration work:

- Style: warm editorial print-dictionary, cream paper, ink-monochrome. Fraunces for titles/headwords/card headlines only; Work Sans for everything else. No Inter/Roboto/system-Arial look.
- Color is functional only: CEFR badges (A=green, B=amber, C=blue), green dot for on-device AI cue, literal color-word swatches. No new accents without a stated function. No gradients, uniform drop-shadow cards (use 1px borders), or tracked-out ALL-CAPS eyebrows.
- Layout: 22–24pt side padding, 14–18pt card padding, radii 10–14 cards / 20–24 pills / 3–6 badges, tap targets ≥44pt. Screen header = Fraunces title + one-line muted subtitle + illustration top-right.
- Buttons: primary solid ink + cream text, pill; secondary 1px ink border. Never put `→` in button/link text; use a real chevron.
- Tab bar: native Liquid Glass, 5 tabs (Home · Grammar · Library · Practice · Profile), SF Symbols. Dictionary search opens from Home.
- Illustrations: dictionary `_plate` words migrate to the flat colour card style (`flat_color` binding style, viewBox 340×200, 15-token palette, no text/outlines/gradients; see `design.md` §4, linted by `Tools/svg-lint/svg_lint.py`). Not-yet-migrated `_plate`, `_line` and phrasal-verb SVGs remain monochrome line art (viewBox 342×196 / 160×96, `#3A362E` strokes). Migrated so far: elephant, arm, school, head, building. UI icons are SF Symbols, not SVG illustrations. Same icon = same meaning everywhere.
- Every AI entry point shows the privacy cue "On-device · Private & secure". Settings row label: "On-device AI (Apple Intelligence)" with "Runs entirely on this device — nothing leaves your phone."
- Accessibility: body text ≥4.5:1 (use `#736E64` for secondary text), level meaning never by color alone, real semantic controls.
- Full stats live only in Profile; stat boxes only in Practice and Profile.
