# 03_AI_FEATURES.md — On-Device AI Product Specification

## 1. Product principle
AI must behave as a **learning layer over a trusted dictionary**, not as a generic chatbot.

The primary product loop is:

```text
Search → Understand → Save → Practice → Speak → Review → Progress
```

AI enhances each step while the dictionary and learning engine remain functional without AI.

---

## 2. AI responsibilities
AI may be used for:

- simplified explanations
- explanations in the learner's preferred language
- additional examples
- comparison of similar words
- usage guidance
- common mistake explanations
- sentence correction
- more natural alternatives
- personalized quizzes
- speaking prompts
- speaking feedback
- weekly learning insights
- semantic search assistance

AI must not silently replace authoritative dictionary data.

---

## 3. AI provider abstraction
All AI features go through `LanguageAIService`.

The first implementation should target Apple on-device Foundation Models when available.

Future providers may be added without modifying the feature UI.

Implementations:

- `AppleFoundationModelService`
- `NoAIService`
- optional future remote provider

---

## 4. User personalization inputs
The AI layer may use the following learning context:

- CEFR level
- explanation language
- preferred English variant (UK / US / both)
- saved words
- weak words
- recent mistakes
- recently reviewed words
- current learning topic
- daily goal

Do not feed unnecessary personal data into prompts.

---

## 5. Dictionary Entry AI actions
The Dictionary Entry screen should include a restrained `AI Coach` section.

### 5.1 Explain Simply
Goal: rewrite the meaning at the user's CEFR level.

Input:
- curated dictionary entry
- CEFR level

Output:
- 1–3 sentence simple explanation
- no invented dictionary sense

Example:

```text
Word: sophisticated
Level: B1

AI:
Something sophisticated is advanced, complex, or carefully designed.
```

### 5.2 Explain in My Language
Goal: explain difficult English concepts in the user's selected language.

Rules:
- keep the headword, IPA, examples, and collocations in English
- explanation may be localized
- avoid turning every screen into a translation dictionary

### 5.3 More Examples
Generate contextual examples matched to CEFR level.

Requirements:
- use the correct sense
- avoid uncommon idioms for lower levels
- keep examples short enough for mobile reading

### 5.4 Compare Words
Examples:

- family vs relatives vs household
- job vs work vs career
- say vs tell vs speak vs talk

Structured output:

- short summary
- key difference for each word
- example sentence for each
- common learner trap

### 5.5 Common Mistakes
Use curated mistakes first where available.

AI may add learner-specific explanations.

Example:

```text
Incorrect: My family have five people.
Better: There are five people in my family.
```

### 5.6 When Should I Use It?
Explain practical usage:

- formal / informal
- spoken / written
- academic / everyday
- typical situations

### 5.7 Quiz Me
Generate a short quiz from the current word.

Supported question styles:

- choose meaning
- choose correct sentence
- fill the gap
- collocation match
- sentence correction

---

## 6. Personalized example correction
The user may save a personal example for a word.

Flow:

1. User writes a sentence.
2. App validates that the target word appears where appropriate.
3. AI returns structured feedback.
4. User may save original or corrected version.

Output model:

```swift
struct SentenceFeedback {
    let original: String
    let corrected: String
    let explanation: String
    let importantMistakes: [Mistake]
    let naturalAlternative: String?
}
```

Keep feedback focused on the most important 2–4 issues.

---

## 7. Semantic search
Search must still support normal dictionary lookup.

Add an optional AI-assisted mode for meaning-based queries.

Examples:

```text
"a word for being extremely tired"
"what do you call someone who wants everything perfect"
"word for when you solve a difficult problem"
```

Flow:

1. AI interprets the meaning request.
2. It proposes candidate lemmas.
3. Candidates are resolved against the local dictionary.
4. Only valid dictionary entries are shown.

AI must not return a fabricated headword that cannot be resolved.

---

## 8. Practice planner enrichment
The deterministic Practice Planner decides what the user should review.

AI may enrich the selected plan with:

- contextual examples
- micro-dialogues
- short explanations
- adaptive quiz variations
- speaking prompts

Example daily plan:

```text
Vocabulary — 5 min
Review: achieve, effort, challenge

Speaking — 3 min
Talk about a challenge you overcame.

Grammar focus — 2 min
make vs do
```

AI should use the user's weak words and recurring mistakes.

---

## 9. Speaking practice
Speaking is one of the core premium features.

### 9.1 Topic generation
AI may create speaking prompts based on:

- CEFR level
- recently learned words
- current topic
- previous mistakes

Example:

```text
Topic: Family
Target vocabulary: relative, supportive, relationship, close-knit
Prompt: Talk for 1–2 minutes about your family.
```

### 9.2 Suggested questions
AI may produce 3–5 support questions.

### 9.3 Transcript feedback
After speech-to-text:

AI evaluates:

- grammar
- vocabulary choice
- naturalness
- repeated errors
- whether target vocabulary was used correctly

AI should not claim to measure pronunciation from text alone.

### 9.4 Better Answer
Generate a more natural answer at approximately the same CEFR level.

Do not transform a B1 learner's answer into advanced C2 prose.

---

## 10. Pronunciation separation
Pronunciation analysis is not the same as language-model feedback.

Architecture:

```text
Audio → speech/phonetic analysis → pronunciation signals
Transcript → AI → grammar/wording/naturalness signals
```

The final Speaking Feedback screen may combine both sources.

---

## 11. AI Conversation
This feature is optional for a later version.

It should use short role-play scenarios rather than an unrestricted general chat.

Examples:

- airport
- hotel
- restaurant
- job interview
- doctor appointment
- meeting
- travel

A session contains:

- scenario objective
- target vocabulary
- 5–10 turns
- end-of-session summary
- mistakes
- suggested expressions
- words to save

---

## 12. Listening enrichment
AI may generate comprehension questions from trusted listening content.

AI may also produce short scripts for TTS-based practice when appropriate.

Never make listening dependent on AI generation.

---

## 13. Personalized Word for You
Instead of a random Word of the Day, create `Word for You`.

Selection should be deterministic and based on:

- current level
- weak vocabulary area
- topic history
- recently mastered vocabulary

AI may explain why the word is useful and generate one short practice prompt.

---

## 14. Learning insights
Progress screens may include concise AI-generated insights.

Example:

```text
This week you learned 24 new words and used 11 of them correctly in speaking practice.
You often confuse “make” and “do”.
Next week, focus on collocations.
```

Rules:

- insights must be based on actual tracked learning data
- do not invent progress statistics
- show at most 1–3 useful observations

---

## 15. Mastery and weak-word detection
The mastery engine should be deterministic.

AI may interpret patterns but should not own the score.

Inputs to mastery score may include:

- successful reviews
- failed reviews
- time since last review
- correct use in speaking
- correct use in personal examples
- quiz performance

UI states:

- Mastered
- Learning
- Needs review

---

## 16. Optional image-based learning
For later versions, on-device vision/multimodal processing may support:

- Learn from Photo
- Camera Dictionary
- Scan English text

Possible flow:

```text
Camera / Photo
  ↓
Vision / OCR / image understanding
  ↓
Recognized object or English text
  ↓
Resolve against local dictionary
  ↓
Open Dictionary Entry
```

Example results from a kitchen photo:

- kettle
- cabinet
- countertop
- faucet
- cutting board

Only display dictionary-resolvable vocabulary as learning entries.

---

## 17. Structured outputs
Prefer typed/structured model responses.

Suggested AI DTOs:

- `SimpleExplanation`
- `LocalizedExplanation`
- `GeneratedExample`
- `WordComparison`
- `SentenceFeedback`
- `SpeakingFeedback`
- `QuizSession`
- `WeeklyLearningInsight`

This enables safe rendering, validation, caching, and testing.

---

## 18. Prompt construction rules
System prompts should include only necessary context.

Recommended prompt context:

- user's CEFR level
- explanation language
- target dictionary entry
- relevant curated senses
- relevant recent learner mistakes

Avoid sending the entire user history.

Prompt rules:

- stay within the supplied dictionary sense
- do not invent facts about the learner
- keep output concise
- adapt difficulty to CEFR
- avoid overwhelming the learner
- return structured data where requested

---

## 19. AI caching
Cache results that are reusable and not highly user-specific.

Examples suitable for caching:

- simple explanation for word + CEFR
- word comparison for a fixed set of lemmas
- generic additional examples

Do not indiscriminately cache sensitive speech feedback.

Cache keys should include:

- word ID
- sense ID
- CEFR
- explanation language
- model/provider version where relevant

---

## 20. AI unavailable behavior
Every AI action must have graceful fallback.

Examples:

- hide disabled actions when appropriate
- show `AI unavailable on this device`
- provide curated dictionary examples instead of generated examples
- provide predefined quiz templates instead of generated quiz
- allow speaking recording/transcription even if AI feedback is unavailable

Never block the main dictionary experience.

---

## 21. AI UI rules
AI should be visually understated.

Good labels:

- Explain simply
- Compare
- More examples
- Practice speaking
- Improve my sentence

Avoid:

- giant “Ask AI Anything” boxes
- chatbot-first layout
- glowing AI gradients
- excessive sparkles

Use small labels such as:

`On-device AI`

only when technically accurate.

---

## 22. Privacy rules
- Prefer on-device processing.
- Do not upload speech/audio unless a future remote feature explicitly requires it.
- Raw microphone recordings should not be retained by default.
- AI provider availability must be transparent.
- Do not claim “private” unless the operation is actually local/private.

---

## 23. Priority order for AI implementation

### V1
1. Explain Simply
2. Explain in My Language
3. More Examples
4. Compare Words
5. Personal Sentence Correction
6. AI Quiz
7. Speaking Transcript Feedback
8. Weekly Learning Insight

### V1.1 / V2
9. Semantic Search
10. AI Conversation
11. Camera Dictionary
12. Learn from Photo
13. Advanced listening generation

---

## 24. Definition of Done for an AI feature
An AI feature is complete only when:

- it works through `LanguageAIService`
- it has loading, success, error, cancel, and unavailable states
- output is validated before rendering
- the core screen works without AI
- it is covered by unit tests with a mock AI provider
- the UI matches `design.md`
