# WordwellAI

AI layer for the Wordwell iOS app: contracts, on-device implementation (Apple Foundation Models) and a developer CLI.

## Structure

```
WordwellAI/
├── Package.swift
├── Sources/
│   ├── WordwellAICore/                  # pure Swift, no FoundationModels import
│   │   ├── Contracts/                   # LanguageAIService, SpeakingFeedbackService,
│   │   │                                # LearningInsightService, AIDictionaryLookup, AIError
│   │   ├── Models/                      # AIWordContext, LearnerProfile, results
│   │   ├── Pipeline/                    # ResilientLearningAI, ResilientExamPractice, validators,
│   │   │                                # RestrictedTermsPolicy, quiz assembler, cache,
│   │   │                                # ReverseDictionary, StoryPipeline, PlacementPipeline,
│   │   │                                # MistakePatternAnalyzer, MistakeCoach
│   │   └── Support/                     # UnavailableLearningAI, MistakeClassifier, QueryTerms
│   ├── WordwellAIStorage/               # app adapters (Apple platforms)
│   │   ├── SQLiteDictionary.swift       # AIDictionaryLookup + DefinitionSearching over FTS5
│   │   ├── SQLiteDictionaryBuilder.swift, DictionarySchema.swift, SQLiteSupport.swift
│   │   └── MistakeEntity.swift, SwiftDataMistakeNotebook.swift   # MistakeNotebook over SwiftData
│   ├── WordwellAIFoundationModels/      # iOS 26+ / macOS 26+ at runtime
│   │   ├── Prompts/                     # AIPrompts (versioned), PromptBuilder, TokenBudget
│   │   ├── Schemas/                     # @Generable schemas + mapping to domain
│   │   ├── Tools/                       # LookupWordTool (dictionary grounding)
│   │   ├── Exam/                        # exam-style prompts, schemas, FoundationModelsExamPractice
│   │   ├── Study/                       # find / story / placement / mistake-lesson prompts and service
│   │   └── Service/                     # FoundationModelsLearningAI, availability, errors, prewarm
│   └── wordwell-ai/                     # CLI (swift-argument-parser)
│       ├── Commands/                    # feature, practice and tooling commands
│       ├── Support/                     # environment, JSON dictionary, renderer
│       └── Resources/                   # seed-dictionary.json, eval-suite.json, restricted-terms.json
└── Tests/                               # WordwellAICoreTests, WordwellAIStorageTests
```

## Anti-hallucination design

- Meanings come only from `AIWordContext` (dictionary). Sense IDs are validated.
- Every sentence must contain the headword or a known form (`FormMatcher`).
- Quiz: the model writes sentences only; answer and distractors come from the dictionary.
- Corrections/feedback: issues must quote text that exists in the learner input.
- Target-word usage in speaking is computed deterministically.
- Learner input is delimited `<<< >>>` and treated as data (prompt-injection eval case included).

## Token/performance

- Stable per-task instructions → prewarm and prefix reuse; learner data lives in the prompt.
- Dictionary data inlined compactly; senses trimmed to fit `TokenBudget` (real token counts on 26.4+).
- `maximumResponseTokens` per task, greedy sampling for deterministic tasks.
- Validated results cached by `task|lemma|level|language|promptVersion`.
- `wordwell-ai inspect` shows exact prompts and token counts.

## CLI (macOS 26+, Apple Intelligence enabled)

```bash
swift run wordwell-ai availability --language ru
swift run wordwell-ai explain decide --language ru --stream
swift run wordwell-ai examples borrow --count 3 --interests football
swift run wordwell-ai compare affect effect --level B1
swift run wordwell-ai mistakes suggest
swift run wordwell-ai quiz decide --interactive
swift run wordwell-ai improve "He suggested me to take a taxi." --target suggest
swift run wordwell-ai speak --words suggest decide --transcript "i suggest we decide go to park"
swift run wordwell-ai insight --weak affect lend
swift run wordwell-ai inspect explain decide --language ru
swift run wordwell-ai eval --min-pass-rate 0.85 --json > eval-report.json
```

## App integration

```swift
// Core/AI/AIContainer.swift (app target)
let lookup = DictionaryAILookupAdapter(repository: dictionaryRepository) // conforms to AIDictionaryLookup
let primary: any LearningAI
if #available(iOS 26.0, *) {
    primary = FoundationModelsLearningAI(dictionary: lookup)
} else {
    primary = UnavailableLearningAI(reason: .osTooOld)
}
let ai: any LearningAI = ResilientLearningAI(
    primary: primary,
    fallback: nil,                 // PCC / partner model later, behind user consent
    policy: .disabled,
    cache: AIResponseCache(storage: InMemoryAICacheStorage()) // swap for SwiftData-backed storage
)
```

ViewModels depend on `LanguageAIService` / `SpeakingFeedbackService` / `LearningInsightService`,
map `AIError.localizationKey` to the String Catalog, and hide AI actions when
`availability(languageCode:)` is not `.available`.

## Exam-style practice

Original practice in a common international exam format, fully brand-neutral.

- Sections: speaking (`interview`, `longTurn`, `discussion`), writing (`dataDescription`, `opinionEssay`), reading (True / False / Not stated).
- Material is always newly generated; prompts forbid naming or imitating real exams, boards, publishers or score scales.
- Levels are unofficial CEFR estimates with app-owned criteria (task, organisation, vocabulary, grammar).
  The overall level is a conservative median computed in code; under-length answers lose one task level.
- Reading answer keys must be grounded in an exact quote from the passage.
- `RestrictedTermsPolicy` rejects restricted names; offending output is regenerated and never shown.
  The config (`restricted-terms.json`) holds only FNV-1a fingerprints, so no brand name exists in source, bundle or binary.
  The plain-text term list is kept outside the repo (legal/product owner). Add a term:
  `swift run wordwell-ai exam fingerprint "<term>"` → paste the hex into the config.
- UI must show `ExamAssessment.disclaimerKey`; do not use exam brands in the app name, subtitle, keywords or screenshots.

```bash
swift run wordwell-ai exam speaking --part long-turn --topic travel --interactive
swift run wordwell-ai exam writing --kind data --answer-file essay.txt
swift run wordwell-ai exam reading --questions 5 --interactive
swift run wordwell-ai exam audit --runs 3 --max-violation-rate 0
```

## Study tools: find, story, placement, patterns

New pipelines in `WordwellAICore/Pipeline` (services in `Contracts/StudyServices.swift`, on-device implementation in `WordwellAIFoundationModels/Study`):

| Command | Pipeline | What the model does | What code guarantees |
|---|---|---|---|
| `find "fear of heights"` | `ReverseDictionary` | proposes words, may read other languages | every word exists in the dictionary; definition is the dictionary's; degrades to retrieval-only when AI is unavailable |
| `story --words decide borrow lend --topic weekend` | `StoryPipeline` | writes the story | length and sentence length by CEFR level; coverage of target words computed in code; regenerates, keeps the best attempt (≥75% words) |
| `placement --interactive` (or `--answer` ×3, `--answers-file`) | `PlacementPipeline` | assesses four criteria | fixed questions; lower-median level; a short sample is capped at B1; confidence computed in code |
| `patterns …` | `MistakePatternAnalyzer`, `MistakeCoach` | writes only the weekly mini-lesson | classification, ranking and exercise verification are rule-based |

```bash
swift run wordwell-ai find "fear of heights"            # add --offline for retrieval only
swift run wordwell-ai story --words decide borrow lend --level B1
swift run wordwell-ai placement                          # prints the questions
swift run wordwell-ai placement --interactive
swift run wordwell-ai patterns seed                      # 16 sample mistakes
swift run wordwell-ai patterns report                    # offline, no AI
swift run wordwell-ai patterns lesson --interactive      # weekly mini-lesson
swift run wordwell-ai patterns capture "She go to school yesterday"   # improve + save to notebook
swift run wordwell-ai patterns add "I have a apple" "I have an apple" --days-ago 2
```

### Mistake patterns (item 7)

`MistakeClassifier` compares the wrong and corrected sentence token by token and decides among: articles, prepositions, verb forms, agreement, plurals, word order (rules), and spelling, word choice, collocation, register (category hint, then edit distance). Anything ambiguous is `.other` and never triggers a lesson. Ranking uses a 28-day window and a 14-day half-life; a pattern needs 3+ mistakes. Lesson exercises for rule-based patterns must be classified as the same pattern by the same classifier, and the learner's own sentences are never reused. The notebook is `[MistakeRecord]`: a JSON file in the CLI (`~/.wordwell-ai/mistakes.json`), SwiftData in the app.

### Limits

- The classifier is heuristic: `he go → goes` vs `my brother go → goes` cannot be told apart without a subject, so the second is `.other`. Extend the word lists in `MistakeClassifier` and add a test row for each new case.
- Without `--db`, retrieval in the CLI is a lexical baseline over the JSON dictionary. In the app use `SQLiteDictionary` (FTS5, bm25).
- Descriptions in other languages depend on the model supporting that language; otherwise `find` falls back to retrieval, which only understands English.
- `seed-dictionary.json` (28 entries) is illustrative: definitions and CEFR levels were written by hand, not taken from Open English WordNet.
- Placement is an unofficial CEFR estimate; the UI must say so.

## App adapters (`WordwellAIStorage`)

Two ready adapters for the contracts the pipelines depend on. Both are local-only.

**SQLite FTS5 dictionary.** One read-only file: `entry` (lookup by lemma, CEFR, JSON payload) and `entry_fts` (FTS5, `porter unicode61`; columns lemma, definitions, collocations, forms; bm25 weights 8/2/1/1). `SQLiteDictionary` is an actor that serves `AIDictionaryLookup` (verification, stable quiz distractors) and `DefinitionSearching` (reverse lookup). User text is turned into quoted letter-only words, so it cannot inject FTS operators. `PRAGMA user_version` guards the schema.

```bash
swift run wordwell-ai db build -o dictionary.sqlite       # from the JSON dictionary (or --dictionary file.json)
swift run wordwell-ai db search "fear of heights" --db dictionary.sqlite
swift run wordwell-ai find "fear of heights" --db dictionary.sqlite
swift run wordwell-ai story --words decide borrow --db dictionary.sqlite
```

**SwiftData mistakes notebook.** `MistakeEntity` + `SwiftDataMistakeNotebook` (a `ModelActor`, work happens off the main thread) implement `MistakeNotebook`. CloudKit is off in `makeContainer` (learner sentences stay on the device; `.unique` is incompatible with CloudKit). If the app already has a `ModelContainer`, add `MistakeEntity.self` to its schema and create the notebook with that container. Call `prune(olderThan:)` occasionally.

```swift
import WordwellAICore
import WordwellAIStorage
import WordwellAIFoundationModels

// Composition root
let dictionary = try SQLiteDictionary(url: Bundle.main.url(forResource: "dictionary", withExtension: "sqlite")!)
let container = try SwiftDataMistakeNotebook.makeContainer()
let notebook = SwiftDataMistakeNotebook(modelContainer: container)

let tools: any StudyToolsAI = {
    if #available(iOS 26.0, *) { return FoundationModelsStudyTools() }
    return UnavailableStudyTools(reason: .osTooOld)
}()

let finder = ReverseDictionary(service: tools, dictionary: dictionary)
let coach = MistakeCoach(service: tools)

// Use cases
let result = try await finder.find("fear of heights", learner: learner)
try await notebook.add(records)                                  // after "improve my sentence"
let stats = try await coach.report(from: notebook)              // offline, no model
let lesson = try await coach.weeklyLesson(from: notebook, learner: learner)
```

Notes: SQLite's FTS5 and the porter tokenizer ship in the system library on iOS and macOS. Build `dictionary.sqlite` in your data pipeline, not on the device. Ship a new file with a new `DictionarySchema.version` when the layout changes.

## Versioning

Bump `AIPrompts.version` on any prompt or schema change, then run `eval`.
