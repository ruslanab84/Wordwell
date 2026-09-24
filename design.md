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

Use the screenshot's quiet pictogram style for **all** word-meaning and phrasal-verb illustrations: thin, dark, rounded outlines on the card or page background. SVGs have no built-in plate, colored scene background, printed caption, or decorative border.

- `fill="none"`, `stroke="#3A362E"` or `currentColor`, with round caps and joins. Tint the vector with the semantic ink color in Dark Mode.
- Keep a consistent visible line weight: about **1.5–2px** at the displayed size. Increase source stroke width for drawings scaled down within a larger viewBox.
- Draw only the subject and any second object needed to explain the meaning. Use a simple arrow between objects when direction or change is the meaning, as in the phrasal-verb cards.
- Build from a few recognizable circles, lines, rectangles, and short paths. Leave generous empty space. Avoid shading, textures, gradients, tiny details, and photorealism.
- Phrasal-verb card scenes use a **160×96** viewBox. Dictionary illustrations use **342×196**, centered above the headword. Header motifs are roughly **90–140px** wide.
- A word that *names a color* may use one filled color swatch with a dark outline; this is the only fill exception for word illustrations. Keep its accessible description explicit.
- UI icons remain SF Symbols or the shared icon set; an illustration should explain a word, not imitate an interface control.

### General SVG rules
- Every element closed explicitly, every attribute quoted
- No external images, no `<foreignObject>`, no animation
- Reuse the same icon for the same meaning everywhere (magnifier = search, chevron = navigate forward, etc.) — icons are a shared component set, not redrawn per screen

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
