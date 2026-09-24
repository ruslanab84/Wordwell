# Wordwell implementation architecture

[Docs/01_ARCHITECTURE.md](Docs/01_ARCHITECTURE.md), [Docs/03_AI_FEATURES.md](Docs/03_AI_FEATURES.md), and [Docs/04_SVG_ASSET_SPEC.json](Docs/04_SVG_ASSET_SPEC.json) define the product architecture. [design.md](design.md) is the single visual source; `Docs/02_DESIGN.md` points to it. The later user correction makes `design.md` authoritative for SVG appearance, while the JSON schema defines binding metadata and allowed screen contexts.

## Modules and dependency direction

```text
Wordwell app target (AppContainer, AppRouter, feature Views/ViewModels)
  ├── WordwellDomain           Foundation-only models and contracts
  ├── WordwellDesign           SwiftUI tokens, fonts, shared visuals
  ├── WordwellData ──────────→ WordwellDomain
  └── WordwellAI ────────────→ WordwellDomain
```

The four libraries live in the local `Packages/WordwellKit` package. Features stay in the app target until an actual feature needs its own module. ViewModels receive only the contracts they use; they do not access `AppContainer`, SwiftData, SQLite, or Foundation Models directly. `WordwellDesign` never imports Domain, Data, or AI. AppContainer is the only production composition root.

## Phase 1 foundation

- `WordwellDomain` defines `WordEntry` with stable entry and sense IDs, separate `UserWordState` and progress models, illustration binding metadata, and typed AI outputs. `WordEntry` does not duplicate the illustration asset name; the binding repository resolves it.
- Repository contracts cover dictionary lookup, saved words, progress, learning settings, and illustration bindings. `LanguageAIService` is the provider-independent AI boundary; its operations receive a selected dictionary sense and minimal learner context.
- `NoAIService` reports `.notConfigured` and throws a typed unavailable error. `UnavailableDictionaryRepository` remains the explicit fallback if the bundled dictionary cannot open. Neither fabricates learning content.
- `AppRouter` owns the selected tab and five independent typed navigation paths. The initial route is `dictionaryEntry(wordID:)`; later routes are added with their features. Services and repositories never navigate.
- `AppContainer` wires the router, bundled local dictionary, and AI contract without changing feature contracts.

## Persistence decision

The authoritative dictionary is a bundled, read-only SQLite database with an FTS5 index for local headword, word-form, and meaning search. User-owned data will use a separate local SwiftData store behind repositories: saved words, personal examples, review events, session summaries, goals, and preferences. No cloud sync or remote AI is implied. Entry IDs use the upstream lemma and part-of-speech key; upstream sense IDs are retained.

## Phase 3 dictionary core

`Tools/import_dictionary.py` reproducibly converts the licensed Open English Wordnet 2025 JSON archive into the bundled database. [Docs/05_DICTIONARY_SOURCE.md](Docs/05_DICTIONARY_SOURCE.md) records its source, checksum, attribution, and field coverage. `LocalDictionaryRepository` provides exact and prefix search, meaning search, suggestions, and article lookup. Package tests exercise these paths entirely offline.

## Design and SVG boundaries

The existing Fraunces/Work Sans files and basic tokens are isolated in `WordwellDesign`. SVG source files are bound through metadata, not paths embedded in `WordEntry`. Schema version 2 uses monochrome line art in headers, dictionary entries, library, review, and speaking. `LocalIllustrationBindingRepository` caches the bundled metadata; the existing `_plate` asset names remain stable identifiers for dictionary illustrations, but their artwork is now unframed line art. A missing binding leaves the screen usable. `Tools/validate_svg_assets.py` runs in the Xcode build, and `WordwellSVGImage` renders vector assets from the design package.

## Phase 2 design system

- `WordwellDesign` owns the semantic color palette, Fraunces/Work Sans type roles, layout metrics, and reusable headers, body text, bordered cards, rows, stat boxes, buttons, toggles, CEFR badges, and privacy cue. It has no dependency on feature or domain modules.
- The light palette follows `design.md`. The product specification also requires Dark Mode, so semantic colors resolve to a warm dark palette automatically. Line illustrations use the semantic ink tint.
- `design.md` claims that `#8C877C` meets 4.5:1 contrast on `#F7F2E6`; the measured ratio is 3.2:1. The original muted token remains available for decoration, while secondary text uses `#736E64` (4.54:1) in light mode. Automated checks cover primary, secondary, and CEFR text in both appearances.
- The app shell uses five independent navigation stacks and the native Liquid Glass tab bar, kept visible while scrolling. SwiftUI supplies tab labels, selection state, and accessibility behavior.
- The current SF Symbol tab icons remain navigation vectors; word illustrations use shared SVG rendering.

## Ordered phases

1. Architecture (this foundation)
2. Design System
3. Dictionary core
4. Dictionary Entry UI
5. Search
6. Library
7. Practice
8. Speaking
9. Progress
10. AI integration
11. SVG illustration binding
12. Listening, Quiz, and remaining features

The current five tab views are placeholders inherited from the initial project skeleton. They do not count as completed feature phases. The dictionary core is implemented; the search and entry screens remain Phase 4 and Phase 5 work.
