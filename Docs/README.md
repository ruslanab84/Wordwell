# WordwellAI

Standalone AI package in `Docs/` for the Verbalex iOS app: contracts, on-device implementation (Apple Foundation Models) and a developer CLI.

Run the Swift commands below from `Docs/`. Check `wordwell-ai availability` first; generation requires a supported Apple Intelligence device and language.

## Structure

```
Docs/
├── Package.swift
├── Sources/
│   ├── WordwellAICore/                  # pure Swift, no FoundationModels import
│   │   ├── Contracts/                   # LanguageAIService, SpeakingFeedbackService,
│   │   │                                # LearningInsightService, AIDictionaryLookup, AIError
│   │   ├── Models/                      # AIWordContext, LearnerProfile, results
│   │   ├── Pipeline/                    # ResilientLearningAI, ResilientExamPractice, validators,
│   │   │                                # RestrictedTermsPolicy, quiz assembler, cache
│   │   └── Support/                     # UnavailableLearningAI (null provider)
│   ├── WordwellAIFoundationModels/      # iOS 26+ / macOS 26+ at runtime
│   │   ├── Prompts/                     # AIPrompts (versioned), PromptBuilder, TokenBudget
│   │   ├── Schemas/                     # @Generable schemas + mapping to domain
│   │   ├── Tools/                       # LookupWordTool (dictionary grounding)
│   │   ├── Exam/                        # exam-style prompts, schemas, FoundationModelsExamPractice
│   │   └── Service/                     # FoundationModelsLearningAI, availability, errors, prewarm
│   └── wordwell-ai/                     # CLI (swift-argument-parser)
│       ├── Commands/                    # feature, practice and tooling commands
│       ├── Support/                     # environment, JSON dictionary, renderer
│       └── Resources/                   # seed-dictionary.json, eval-suite.json, restricted-terms.json
└── Tests/WordwellAICoreTests/
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
- Validated results cached by task, lemma, level, language, prompt version and selected sense.
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
// Wordwell/App/AppContainer.swift (app target)
let lookup = DictionaryAILookupAdapter(repository: dictionaryRepository) // conforms to AIDictionaryLookup
let primary: any LearningAI
if #available(iOS 26.0, *) {
    primary = FoundationModelsLearningAI(dictionary: lookup)
} else {
    primary = UnavailableLearningAI(reason: .osTooOld)
}
let ai: any LearningAI = ResilientLearningAI(
    primary: primary,
    cache: AIResponseCache(storage: InMemoryAICacheStorage())
)
```

The app's Dictionary Entry AI Coach uses `LearningAI` for explanations and examples.
Settings and Speaking use its availability check. Other package features remain available
through the developer CLI; app screens for them are not yet wired.

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

## Versioning

Bump `AIPrompts.version` on any prompt or schema change, then run `eval`.
