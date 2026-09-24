# 01_ARCHITECTURE.md — iOS English Learning App Architecture

## 1. Purpose
This document defines the target architecture for a new iOS English-learning application built around three pillars:

1. A serious learner's dictionary.
2. Structured learning and practice.
3. Private on-device AI where supported.

The application must remain useful when AI is unavailable. Dictionary, library, review, listening, basic speaking, and progress functionality must not depend on an AI model being present.

Concrete Phase 1 contracts live in `Packages/WordwellKit/Sources/WordwellDomain`; Swift snippets below illustrate responsibilities rather than duplicating the compiled API.

The visual implementation is governed separately by `Docs/02_DESIGN.md`, which points to the project's root `design.md`. Architecture code must not duplicate visual rules.

---

## 2. Implementation order
The project must be built in this order:

1. Architecture and module boundaries.
2. Design System.
3. Dictionary core.
4. Dictionary Entry UI.
5. Search.
6. Library.
7. Practice.
8. Speaking.
9. Progress.
10. AI integration.
11. SVG illustration binding and validation pipeline.
12. Listening, Quiz, and remaining features.

Do not build all features simultaneously. Complete each architectural layer and one vertical feature slice at a time.

---

## 3. Architectural style
Use **feature-based MVVM with Clean Architecture boundaries**.

Recommended principles:

- SwiftUI for presentation.
- Feature modules own their screens and feature-specific state.
- Domain logic must not depend on SwiftUI.
- Persistence, AI, speech, and audio are accessed through protocols.
- Dependency injection must be used instead of global service lookups.
- Cross-feature navigation must be handled by a router/coordinator abstraction.
- Design components live in a dedicated `Design` module/folder.
- The application must compile and operate with AI services replaced by a no-op or unavailable implementation.

---

## 4. Suggested project structure

```text
EnglishLearningApp/
├── App/
│   ├── EnglishLearningApp.swift
│   ├── AppContainer.swift
│   ├── AppRouter.swift
│   └── AppEnvironment.swift
│
├── Core/
│   ├── AI/
│   │   ├── LanguageAIService.swift
│   │   ├── AppleFoundationModelService.swift
│   │   ├── AIAvailabilityService.swift
│   │   ├── AIModels.swift
│   │   └── NoAIService.swift
│   ├── Dictionary/
│   │   ├── DictionaryRepository.swift
│   │   ├── LocalDictionaryRepository.swift
│   │   ├── DictionarySearchIndex.swift
│   │   └── DictionaryImporter.swift
│   ├── Persistence/
│   │   ├── PersistenceController.swift
│   │   ├── WordLibraryRepository.swift
│   │   ├── ProgressRepository.swift
│   │   └── SettingsRepository.swift
│   ├── Illustrations/
│   │   ├── IllustrationBindingRepository.swift
│   │   ├── IllustrationMetadataLoader.swift
│   │   └── SVGAssetValidator.swift
│   ├── Speech/
│   │   ├── SpeechRecognitionService.swift
│   │   ├── SpeechPermissionService.swift
│   │   ├── SpeakingFeedbackService.swift
│   │   └── PronunciationAnalysisService.swift
│   ├── Audio/
│   │   ├── PronunciationAudioService.swift
│   │   └── AudioPlaybackService.swift
│   ├── Practice/
│   │   ├── PracticePlannerService.swift
│   │   ├── SpacedRepetitionService.swift
│   │   └── MasteryScoringService.swift
│   ├── Analytics/
│   │   ├── AnalyticsService.swift
│   │   └── AnalyticsEvent.swift
│   └── Utilities/
│
├── Design/
│   ├── Tokens/
│   ├── Typography/
│   ├── Colors/
│   ├── Components/
│   ├── Illustrations/
│   └── PreviewSupport/
│
├── Features/
│   ├── Home/
│   ├── Search/
│   ├── DictionaryEntry/
│   ├── Library/
│   ├── Practice/
│   ├── Speaking/
│   ├── Listening/
│   ├── Review/
│   ├── Quiz/
│   ├── Progress/
│   ├── Profile/
│   └── Settings/
│
├── Domain/
│   ├── Models/
│   ├── UseCases/
│   └── ValueObjects/
│
└── Resources/
    ├── IllustrationsSVG/
    ├── DictionarySeed/
    ├── Audio/
    └── Localizations/
```

The exact folder layout may adapt to the codebase, but the separation of responsibilities must remain.

---

## 5. Dependency direction
Dependencies must flow inward:

```text
SwiftUI Views
    ↓
ViewModels / Feature State
    ↓
Use Cases
    ↓
Protocols / Repositories
    ↓
Infrastructure Implementations
```

Rules:

- Views must not call persistence APIs directly.
- Views must not call Foundation Models directly.
- Views must not parse SVG metadata directly.
- AI implementations must not own navigation.
- Repository implementations must not depend on SwiftUI.

---

## 6. AppContainer / dependency injection
Create one composition root responsible for wiring the application.

Example dependencies:

```swift
struct AppContainer {
    let dictionaryRepository: DictionaryRepository
    let wordLibraryRepository: WordLibraryRepository
    let progressRepository: ProgressRepository
    let illustrationRepository: IllustrationBindingRepository
    let aiService: LanguageAIService
    let speechRecognitionService: SpeechRecognitionService
    let speakingFeedbackService: SpeakingFeedbackService
    let practicePlannerService: PracticePlannerService
    let audioService: PronunciationAudioService
    let analyticsService: AnalyticsService
}
```

Requirements:

- Dependencies should be created once where appropriate.
- Test doubles must be easy to inject.
- Views receive feature ViewModels, not the entire container.
- Avoid service-locator patterns.

---

## 7. Navigation architecture
Use an app-level router with typed destinations.

Primary tabs:

- Home
- Search
- Library
- Practice
- Profile

Feature flows may push:

- Dictionary Entry
- Speaking Session
- Listening Session
- Review Session
- Quiz
- Progress Details
- Settings

Example destination model:

```swift
enum AppRoute: Hashable {
    case dictionaryEntry(wordID: String)
    case speaking(topicID: String?)
    case listening(sessionID: String?)
    case review
    case quiz
    case progress
    case settings
}
```

Do not place navigation decisions inside repositories or AI services.

---

## 8. Domain models

### 8.1 WordEntry

```swift
struct WordEntry: Identifiable, Codable, Hashable {
    let id: String
    let word: String
    let lemma: String
    let partOfSpeech: PartOfSpeech
    let ipaUK: String?
    let ipaUS: String?
    let definitions: [DefinitionSense]
    let synonyms: [String]
    let antonyms: [String]
    let collocations: [String]
    let cefrLevel: CEFRLevel?
    let usageNotes: [String]
    let commonMistakes: [CommonMistake]
    let audioUK: String?
    let audioUS: String?
    let illustrationAssetName: String?
}
```

### 8.2 DefinitionSense

```swift
struct DefinitionSense: Identifiable, Codable, Hashable {
    let id: String
    let definition: String
    let examples: [String]
    let register: UsageRegister?
}
```

### 8.3 UserWordState

```swift
struct UserWordState: Identifiable, Codable {
    let id: String
    let wordID: String
    var isFavorite: Bool
    var collectionIDs: [String]
    var status: LearningStatus
    var masteryScore: Double
    var reviewCount: Int
    var lastReviewedAt: Date?
    var nextReviewAt: Date?
    var personalExample: String?
}
```

### 8.4 LearningProfile

```swift
struct LearningProfile: Codable {
    var cefrLevel: CEFRLevel
    var explanationLanguage: String
    var preferredEnglishVariant: EnglishVariant
    var dailyGoalMinutes: Int
    var knownWordIDs: Set<String>
    var weakWordIDs: Set<String>
    var recurringMistakeTags: [String]
}
```

### 8.5 IllustrationBinding

```swift
struct IllustrationBinding: Codable, Hashable {
    let word: String
    let lemma: String
    let partOfSpeech: String?
    let assetName: String
    let assetPath: String
    let tags: [String]
    let style: String
    let version: Int
}
```

---

## 9. Repository contracts

### DictionaryRepository
Responsible for authoritative dictionary data.

```swift
protocol DictionaryRepository {
    func search(_ query: String, limit: Int) async throws -> [WordEntry]
    func entry(id: String) async throws -> WordEntry?
    func entry(lemma: String) async throws -> WordEntry?
    func suggestions(prefix: String, limit: Int) async throws -> [String]
}
```

### WordLibraryRepository
Responsible for user-owned vocabulary state.

```swift
protocol WordLibraryRepository {
    func save(wordID: String) async throws
    func remove(wordID: String) async throws
    func state(for wordID: String) async throws -> UserWordState?
    func allSavedWords() async throws -> [UserWordState]
    func update(_ state: UserWordState) async throws
}
```

### IllustrationBindingRepository

```swift
protocol IllustrationBindingRepository {
    func binding(forWord word: String, lemma: String?) async -> IllustrationBinding?
    func assetName(forWord word: String, lemma: String?) async -> String?
}
```

### ProgressRepository
Stores learning statistics, session history, goals, and mastery state.

---

## 10. Dictionary data strategy
Dictionary data is the source of truth for:

- headword
- lemma
- IPA
- part of speech
- curated definitions
- curated examples
- CEFR level
- irregular forms
- pronunciation references

AI must not silently replace authoritative dictionary fields.

AI may create:

- simpler explanations
- additional contextual examples
- comparisons
- personalized practice
- sentence improvement
- learner-specific feedback

When AI output conflicts with curated dictionary data, curated dictionary data wins.

---

## 11. AI architecture
All AI access must go through a provider-independent service.

```swift
protocol LanguageAIService {
    var availability: AIAvailability { get async }

    func explainSimply(
        entry: WordEntry,
        profile: LearningProfile
    ) async throws -> SimpleExplanation

    func explainInUserLanguage(
        entry: WordEntry,
        profile: LearningProfile
    ) async throws -> LocalizedExplanation

    func generateExamples(
        entry: WordEntry,
        profile: LearningProfile,
        count: Int
    ) async throws -> [GeneratedExample]

    func compareWords(
        words: [WordEntry],
        profile: LearningProfile
    ) async throws -> WordComparison

    func improveSentence(
        sentence: String,
        contextWord: WordEntry?,
        profile: LearningProfile
    ) async throws -> SentenceFeedback

    func generateQuiz(
        words: [WordEntry],
        profile: LearningProfile
    ) async throws -> QuizSession
}
```

Implementations:

- `AppleFoundationModelService`
- `NoAIService`
- optional future remote provider

The UI should only understand capability/availability, never provider details.

---

## 12. AI availability states
Use explicit states:

```swift
enum AIAvailability {
    case available
    case unavailableDevice
    case unavailableOS
    case modelNotReady
    case restricted
}
```

Each AI feature must handle all states gracefully.

Do not block dictionary access because AI is unavailable.

---

## 13. Structured AI outputs
Prefer structured generation over free-form text when possible.

Examples:

```swift
struct SentenceFeedback: Codable {
    let original: String
    let corrected: String
    let explanation: String
    let importantMistakes: [Mistake]
    let naturalAlternative: String?
}
```

```swift
struct WordComparison: Codable {
    let summary: String
    let differences: [WordDifference]
    let usageExamples: [GeneratedExample]
}
```

Benefits:

- predictable UI rendering
- easier testing
- simpler caching
- safer fallbacks

---

## 14. Practice engine
`PracticePlannerService` builds daily practice from user history.

Inputs:

- saved words
- next review dates
- mastery scores
- recent mistakes
- speaking history
- daily goal
- CEFR level

Output example:

```swift
struct DailyPracticePlan {
    let reviewWordIDs: [String]
    let speakingTopic: SpeakingTopic?
    let listeningTask: ListeningTask?
    let quiz: QuizSession?
    let estimatedMinutes: Int
}
```

The plan must be deterministic without AI. AI may enrich content where available.

---

## 15. Spaced repetition
Implement review scheduling independently from AI.

At minimum track:

- repetitions
- ease / confidence
- last review date
- next review date
- answer quality
- mastery score

Review types:

- meaning recall
- word recall
- context completion
- multiple choice
- collocation match
- personal example

AI-generated exercises are optional enrichments, not the only review path.

---

## 16. Speaking architecture
Separate audio handling from language feedback.

Pipeline:

```text
Microphone
   ↓
SpeechRecognitionService
   ↓
Transcript
   ↓
PronunciationAnalysisService (when supported)
   ↓
SpeakingFeedbackService
   ↓
LanguageAIService (grammar / wording / naturalness)
   ↓
Structured SpeakingFeedback
   ↓
ProgressRepository
```

`SpeakingFeedbackService` combines deterministic signals and AI output.

Do not ask the language model to invent a pronunciation score from text alone.

---

## 17. Listening architecture
Listening content may come from:

- bundled audio
- generated text + system TTS
- curated pronunciation audio

Listening session types:

- listen and choose
- listen and type
- comprehension
- word recognition
- shadowing

The same `WordEntry` and mastery state should be reused across dictionary, review, speaking, and listening.

---

## 18. SVG illustration architecture
SVGs are first-class learning assets.

Directory:

```text
Packages/WordwellKit/Sources/WordwellDesign/Resources/IllustrationsSVG/Words.xcassets/
```

Naming convention:

```text
word_family_line.imageset/word_family_line.svg
word_family_plate.imageset/word_family_plate.svg
word_branch_line.imageset/word_branch_line.svg
```

Metadata source:

```text
Packages/WordwellKit/Sources/WordwellData/Resources/IllustrationsSVG/illustration_bindings.json
```

Rules:

- one binding per lemma + part of speech + sense + visual style where needed
- monochrome line art and colored specimen plates follow `design.md`; specimen plates appear only in Dictionary Entry
- reuse an asset wherever its visual style and screen context allow it
- no duplicate assets with inconsistent style
- metadata must be validated at build/test time
- missing illustration must never break a word screen
- `Tools/validate_svg_assets.py` checks bindings, SVG content, and vector image sets during Xcode builds
- register each new SVG and its `Contents.json` in the Xcode validator phase input paths so sandboxed builds can inspect them

---

## 19. Persistence
Use SwiftData behind repositories for user-owned data. Keep the authoritative dictionary in a separate bundled, read-only SQLite database.

Persist:

- user word library
- favorites
- collections
- personal examples
- review history
- mastery state
- speaking session history
- listening history
- quiz results
- daily goals
- learning profile
- explanation language
- app settings

Keep dictionary seed data and user data logically separate.

---

## 20. Offline behavior
Core offline support must include:

- dictionary search over local data
- opening cached/local entries
- saved-word library
- review sessions
- progress
- bundled SVG illustrations
- cached pronunciation audio when available

AI actions must expose their own availability without degrading the rest of the screen.

---

## 21. Analytics
Analytics must be abstracted through `AnalyticsService`.

Suggested events:

- `word_searched`
- `dictionary_entry_opened`
- `word_saved`
- `word_removed`
- `ai_explanation_requested`
- `ai_comparison_requested`
- `practice_started`
- `review_completed`
- `speaking_started`
- `speaking_completed`
- `listening_completed`
- `quiz_completed`

Do not log raw private speech/audio/transcripts unless explicitly required and appropriately consented.

---

## 22. Error handling
Define user-safe domain errors.

Examples:

- dictionary unavailable
- AI unavailable
- speech permission denied
- microphone unavailable
- audio playback failed
- persistence failed
- asset missing

The UI must not expose raw framework errors.

---

## 23. Concurrency
Use Swift Concurrency.

Rules:

- long-running work uses `async/await`
- UI state updates on MainActor
- AI generation must be cancellable when possible
- search requests should debounce/cancel stale work
- persistence and asset lookup must not block SwiftUI rendering

---

## 24. Testing strategy
Required test layers:

### Unit tests
- dictionary repository
- spaced repetition
- mastery scoring
- practice planning
- illustration binding
- AI response mapping

### ViewModel tests
- loading / success / error states
- AI unavailable states
- word saving
- review completion

### UI tests
- search → dictionary entry
- save word → Library
- Practice → Review
- Practice → Speaking
- Progress updates

### Asset validation tests
- every mapped SVG exists
- no duplicate bindings
- asset naming rules are respected

---

## 25. Performance requirements
Target behavior:

- instant-feeling local dictionary search
- smooth 60/120 Hz scrolling depending on device
- no blocking file parsing in view body
- SVG metadata loaded once and cached
- expensive AI work outside main thread
- progress charts render from precomputed aggregates

---

## 26. Security and privacy
- Keep on-device processing on device when using on-device AI.
- Store only the minimum learning data needed.
- Do not make privacy claims beyond actual implementation.
- Microphone access must be requested only when needed.
- Raw recordings should not be persisted by default.

---

## 27. Definition of Done for architecture phase
The architecture phase is complete when:

- module/folder structure is created
- design layer is separated
- repository protocols exist
- AI protocol and no-AI fallback exist
- navigation skeleton exists
- domain models exist
- persistence strategy is selected
- SVG binding schema is defined
- dependency injection is wired
- Dictionary Entry can be implemented without changing architecture
