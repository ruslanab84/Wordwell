# Design System — English Lexicon (Oxford-style + on-device AI)

Style: warm, editorial, print-inspired dictionary — not a generic SaaS app. Cream paper, restrained ink-monochrome UI, with color reserved for CEFR level coding and literal color-word swatches.

---

## 1. Typography

**Display / headwords — Fraunces**
```
https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,500;0,600;0,700;1,500&display=swap
```
Used only for: screen titles (H1), word headwords, card headline text. Never for body copy or UI chrome.

**Body / UI — Work Sans**
```
https://fonts.googleapis.com/css2?family=Work+Sans:wght@400;500;600;700&display=swap
```
Used for everything else: paragraphs, labels, nav, buttons, badges.

Do not substitute Inter, Roboto, or system Arial — Work Sans is the deliberate choice to avoid the generic-AI-app look.

**Type scale**

| Role | Font | Size | Weight |
|---|---|---|---|
| Screen title (H1) | Fraunces | 28–34px | 700 |
| Card headline / word-of-the-day | Fraunces | 21–24px | 600 |
| Headword on word screens | Fraunces | 34px | 700 |
| Body text | Work Sans | 14–15px | 400 |
| Secondary / meta (IPA, part of speech) | Work Sans | 12–13px | 400–500, italic for part of speech |
| Small labels / section headers | Work Sans | 11–12px | 500–600 |
| Badges (CEFR, tags) | Work Sans | 10–11px | 700 |
| Buttons | Work Sans | 13–14px | 600 |
| Nav labels | Work Sans | 10.5px | 600 active / 400 inactive |

Line height: 1.4–1.55 for body text, 1.05–1.1 for large display type.

---

## 2. Color tokens

| Token | Hex | Use |
|---|---|---|
| `bg` | `#F7F2E6` | App background (cream) |
| `ink` | `#211E19` | Primary text, icons, active states, primary buttons |
| `muted` | `#8C877C` | Secondary text, captions |
| `muted-icon` | `#B7AE9C` | Disabled/chevron icons |
| `border` | `rgba(33,30,25,0.12–0.16)` | Card and row borders (never a drop shadow) |

**CEFR level coding** (used only for level badges/filters — the one place color carries meaning):

| Level | Text | Background | Dot/accent |
|---|---|---|---|
| A1–A2 | `#3E5636` | `#E3EDE0` | `#4F7A4A` |
| B1–B2 | `#6E4712` | `#F5E8CF` | `#B8863A` |
| C1–C2 | `#2E4A63` | `#DCE6EC` | `#2E4A63` |

**On-device AI privacy indicator:** small `#4F7A4A` dot + 11px muted caption "On-device · Private & secure".

Never introduce a new accent color outside this list without a functional reason.

---

## 3. Layout & components

- Screen side padding: **22–24px**
- Section vertical gap: **14–18px**
- Card padding: **14–18px**
- List row vertical padding: **9–13px**, separated by spacing/hairlines, never a repeated drop shadow
- Border radius: **10–14px** cards · **20–24px** pills/buttons · **3–6px** small badges
- Touch targets: **≥44×44px** for every tappable icon/button
- Icon-only buttons always get `aria-label`

**Standard screen header** (every tab uses this pattern): title (Fraunces) + one-line muted subtitle, illustration anchored top-right.

**Card types**
- *Hero/word-of-the-day card:* 1px border, white fill, optional progress bar, one primary button
- *AI tutor note:* 1px solid border (dashed only for the Home AI-entry card), small icon + 12px label + 13px body
- *List row:* icon (22–26px, stroke) + title + muted description + trailing chevron, no card wrapper
- *Stat box:* 1px border, centered icon/number/label — used only in Practice and Profile, not duplicated elsewhere

**Buttons**
- Primary: solid `ink` fill, cream text, pill radius, 44px min height
- Secondary: transparent, 1px `ink` border
- Never append a `→` character to button/link text — use a real chevron icon element if direction needs showing

**Bottom nav:** fixed, native Liquid Glass tab bar with 5 tabs (Home · Grammar · Library · Practice · Profile), using SF Symbols and an `ink` selection tint. Dictionary search opens from Home.

**Toggles:** pill track (34×20px) — on = `ink` fill with cream knob right, off = outlined track with `muted-icon` knob left.

---

## 4. SVG illustration guidelines

Dictionary word illustrations (`*_plate`) use the **flat colour card** style below, enforced by `Tools/svg-lint/svg_lint.py`. If this section and the linter disagree, fix one of them in the same commit. Phrasal-verb and `_line` assets are still monochrome line art (thin `#3A362E` rounded outlines, `fill="none"`, tinted with ink in Dark Mode) until they are redrawn.

- Flat colour shapes on a sand card. No outlines, gradients, shadows, transparency or textures. One hero object per word, readable at 64 pt. No text in the picture.
- Same card, frame and sun for every word; only the hero changes.
- Dark mode: the card keeps its sand colours, like a printed picture. Only the UI around it adapts.

### Illustration palette (15 tokens, enforced)

Only these colours may appear in an illustration, written as uppercase hex.

| Token | Hex | Use |
|---|---|---|
| `sand` | `#EDD9AE` | card background |
| `sandBorder` | `#BD9F66` | card border, inner frame, steps |
| `halo` | `#E8C486` | the sun behind the hero |
| `teal` | `#2E6F6A` | main cool colour: clothes, walls, plumage |
| `deepTeal` | `#1F4D4A` | shade of teal, roofs, cuffs |
| `orange` | `#E5A648` | small warm accent: belly, windows, flag |
| `brown` | `#7A5535` | ground line, branches, doors, roofs |
| `green` | `#5A7F4A` | leaves, trees |
| `ink` | `#2A1E16` | eyes, beaks, hair, thin details |
| `skin` | `#D98B57` | skin and warm walls |
| `skinShade` | `#C27443` | shade of skin, ears, neck, darker walls |
| `cream` | `#F6F1E7` | windows, tusks, highlights |
| `grey` | `#8E8A86` | animals and stone |
| `greyShade` | `#77736F` | far legs, ears, tail |
| `earPink` | `#C98F7A` | inner ear |

Rules: a shade token is used for parts that sit behind or below (far legs, neck under the chin), never for outlines. Add a colour only by editing `palette.json` and this table together; a test checks that they match.


### Composition

- Hero object centred on the sun. Side views face left, like the bird and the elephant.
- Prefer concrete nouns and simple actions. For abstract words (however, although) do not force a picture: use a typographic card.
- At most 90 shapes, usually 15 to 40. If a detail disappears at 64 pt, remove it.
- A ground line (`brown`, 4 wide) and one or two `green` leaves or trees are optional, for objects that stand on something. Portraits and body parts may float.
- No eyes on non-living objects. Living things get a single `ink` dot as an eye.

### Illustration spec (enforced by lint)

Canvas `viewBox="0 0 340 200"`. No `width` or `height` attributes: the app scales the artwork.

Elements, in this exact order:

1. Card: `rect x=1 y=1 width=338 height=198 rx=12`, fill `sand`, stroke `sandBorder`, stroke-width 2.
2. Inner frame: `rect x=12 y=12 width=316 height=176 rx=5`, fill `none`, stroke `sandBorder`, stroke-width 1.2.
3. Sun: `circle` filled `halo`, radius 66 to 74, centre within x 160 to 190 and y 94 to 106, fully inside the inner frame.
4. Artwork: everything else.

Content box: all artwork, including half of every stroke width, stays inside x 18 to 322 and y 18 to 182. The bottom-left corner is left free for the UI index overlay.

Shapes: `rect`, `circle`, `ellipse`, `line`, `path`, `polygon`, `polyline`, grouped with `g`. Paths use `M L H V C Q Z` only, so bounds can be checked. Transforms are `translate`, `scale` and `rotate` only.

Paint:
- Every closed shape sets `fill` explicitly, to a palette colour or `none`.
- Detail strokes are 2, 2.5, 3 or 4 wide.
- Strokes 5 wide or more act as filled shapes (limbs, trunks, tails) and must use `stroke-linecap="round"`.
- No `opacity`, `fill-opacity` or `stroke-opacity`. Use a palette colour instead.

Forbidden: `text`, `image`, `style` and `class`, gradients, `filter`, `mask`, `clipPath`, `pattern`, `use`, `title`, `desc`, `metadata`, foreign namespaces.

### Files

- Location: `Design/Illustrations/<lemma>.svg`. In the app repo this is `Resources/IllustrationsSVG/`.
- Name: lowercase ASCII lemma slug, letters, digits and hyphens: `elephant.svg`, `ice-cream.svg`.
- Size: 4096 bytes at most, minified. `--fix` minifies.
- No metadata. Some tools embed provenance or editor metadata; `--fix` strips it and the linter rejects it, because it can add several KB to a 2 KB file.
- The word to picture link is `illustrationAssetName` on `WordEntry` and `assetName` in `IllustrationBinding`. Use the lemma slug as the asset name.

### Lint

```bash
python3 Tools/svg-lint/svg_lint.py Design/Illustrations          # check
python3 Tools/svg-lint/svg_lint.py Design/Illustrations --fix    # strip metadata, size attributes, uppercase hex, minify, then check
python3 Tools/svg-lint/svg_lint.py Design/Illustrations --json   # machine-readable
python3 -m unittest discover -s Tools/svg-lint                   # tests
```

Exit code 0 is clean, 1 means errors, 2 means a path was not found. Use the same command as a pre-commit hook and in CI.

| Rule | Checks |
|---|---|
| `filename` | lowercase lemma slug |
| `size`, `complexity` | at most 4096 bytes and 90 shapes |
| `viewbox`, `root-size`, `root` | exact viewBox, no width or height |
| `card`, `frame`, `sun`, `structure` | first three elements as in Illustration spec |
| `element`, `attribute`, `foreign-namespace` | allowed elements and attributes only |
| `palette`, `hex-case` | colours from `palette.json`, uppercase hex |
| `implicit-fill`, `implicit-stroke` | nothing is left to default to black |
| `opacity` | no transparency |
| `stroke-width`, `tube-cap` | allowed widths, round caps on thick strokes |
| `bounds` | artwork inside the content box, transforms and stroke width included |
| `path-command`, `transform` | only supported commands, so bounds are checkable |
| `empty-art` | at least three shapes after the sun |


### Entry card anatomy
1. Back link to Library.
2. Illustration card.
3. Headword (serif display style) with a round play button on the right.
4. Part of speech (italic), IPA, CEFR badge.
5. Definition, then an italic example.
6. AI tutor note in a bordered box, with a chat icon and the label `AI tutor note`.
7. Related words as chips.

#### AI tutor note

- English only for now. No hints written for speakers of a particular native language until the "Explain in my language" feature exists.
- One or two sentences, about 30 words at most.
- Useful kinds: an idiom, a usage or grammar point, a collocation, a common confusion.
- Never adds a sense, level or example that is not in the dictionary data. Text comes from validated AI output.


---

## 5. On-device AI (Apple Intelligence)

- Any AI entry point (Home callout, Search fallback, word-screen "AI tutor note") carries a visible privacy cue: green dot + "On-device · Private & secure" or equivalent.
- Settings row is labeled **"On-device AI (Apple Intelligence)"**, not just "AI" — name the underlying system framework explicitly.
- Under the toggle, one line of plain-language reassurance: "Runs entirely on this device — nothing leaves your phone."
- **Not yet designed:** an unavailable/disabled state for devices without Apple Intelligence support (toggle should read as unavailable, not just off, with a short explanation) — flagged for a follow-up screen.

---

## 6. Accessibility

- Text contrast: body text ≥4.5:1 against `bg`; verified for `ink` and `muted` on `#F7F2E6`
- Real semantic elements: `<button>`, `<a href>`, `<input>` + `<label>`, even in static mockups
- No fake OS status bars in screen mockups
- Colors that carry meaning (CEFR levels) also differ in the accompanying text label — never color alone

---

## 7. What to avoid

- Gradient washes, uniform drop-shadow card kits, tracked-out ALL-CAPS eyebrow labels
- Colored specimen plates, picture frames, and captions inside illustrations
- New accent colors without a stated function
- Stat duplication across screens (full stats live only in Profile)
