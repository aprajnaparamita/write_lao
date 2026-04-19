# Vocab Feature — Decision Log

A running record of decisions made while building the 500-word vocab feature.
Each entry: **what** was decided, **why**, **alternatives considered**, and
anything **future-you might want to revisit**.

---

## Phase 1 — Storage, Models, and Content Loading

### D1. Hive over sqflite for the vocab data layer

- **Decided**: Use Hive (`hive: ^2.2.3` + hand-written TypeAdapters) for all
  user-state persistence in the vocab feature.
- **Why**: The existing app already uses Hive for `CharacterProgress` and
  `LessonProgress` (see `lib/data/datasources/progress_hive_adapters.dart`).
  Adding sqflite would introduce a second storage stack, two backup paths, and
  two migration strategies for one app.
- **Alternatives considered**: The original spec called for sqflite with
  formal migrations and SQL-style relational integrity. Rejected to keep the
  app on a single storage substrate.
- **Revisit if**: We grow past ~10k user records per box, need cross-row
  queries that Hive can't express cheaply, or want server-side replicas with
  SQL-shaped exports.

### D2. Forward-compatible row shape for v2 cloud sync

- **Decided**: Every user-owned record carries:
  - `id` — UUID v4 string (via `uuid` package), generated client-side
  - `createdAt` / `updatedAt` — `DateTime` stored in UTC (serialized as
    ISO-8601 when we eventually export)
  - `syncState` — enum `{ local, pendingPush, synced, conflict }`, default
    `local` in v1
- **Why**: v1 is local-only, but the spec calls out a future cloud-sync layer.
  Bolting UUIDs and sync state on later means migrating every existing user's
  Hive box. Doing it now costs almost nothing.
- **Alternatives considered**: Auto-increment ints for primary keys. Rejected
  because they collide across devices the moment we sync.
- **Revisit if**: We pick a sync backend (Supabase/Firestore/custom) — at that
  point we'll wire the `syncState` transitions and add a push/pull worker.

### D3. Hand-written Hive TypeAdapters with reserved type IDs

- **Decided**: Hand-write adapters in `vocab_hive_adapters.dart` rather than
  generate them. Use type IDs **12–16** for `UserWord`, `UserVocabProgress`,
  `UserSession`, `FlagDeck`, `FlagDeckWord`.
- **Why**: Matches the existing pattern in
  `lib/data/datasources/progress_hive_adapters.dart` (IDs 0, 1). Hand-written
  adapters give us explicit field-byte control, which we want when fields get
  added or removed across versions.
- **Alternatives considered**: `hive_generator` annotations. Rejected for
  in-house consistency; we can revisit if the field count balloons.
- **Revisit if**: We add many more types — at some point the boilerplate
  outweighs the control.
- **ID reservations**: 0–1 used by alphabet. 2–11 left as a buffer.
  12–16 used by vocab. 17+ free for future use.

### D4. Enums serialized as strings, inline within parent adapters

- **Decided**: `WordStatus`, `SyncState`, and `CharacterType` are written as
  string values (`'new'`, `'learning'`, `'consonant'`, …) inside their
  parents' adapters via private helpers, not as separately registered
  TypeAdapters.
- **Why**: Enum values are small and stable. A renamed enum case is the only
  hazard, and a string-valued payload makes that explicit at deserialize time.
  Avoids one TypeAdapter registration per enum.
- **Revisit if**: The enum set grows large or we want to switch to compact
  integer encoding for size.

### D5. Idempotent Hive registration

- **Decided**: `registerVocabHiveAdapters()` guards every
  `registerAdapter` with `Hive.isAdapterRegistered(typeId)`.
- **Why**: Tests register adapters in `setUpAll`. Hive throws by default on
  duplicate registration, so without the guard, any test that re-registers
  (or any code path that boots Hive twice) crashes.
- **Revisit if**: Hive's default behavior changes in a future release.

### D6. Content bundle as a single asset JSON, validated at load

- **Decided**: All static content (units, lessons, words) ships as one file —
  `assets/vocab/course.json` — loaded once into `CourseContent` and held in
  memory by `CourseRepository`.
- **Why**: 500 words × small payload comfortably fits in memory. One file
  means one parse, one validation pass, and one OTA update unit. The
  alternative — per-lesson JSON files — multiplies I/O and validation
  surface area for no real benefit at this scale.
- **Validation**: `CourseContentValidator` collects every error before
  throwing (`CourseValidationException`), so authors fix the whole bundle in
  one pass instead of whack-a-mole. Validates duplicate IDs, dangling
  `lesson_ids`, dangling `word_ids` (new and review), empty `examples`, empty
  `characters`, and missing referenced asset paths (`image_path`,
  `audio_path`).
- **Revisit if**: We exceed ~5k words or ship region-specific content packs.

### D7. Dependency-injected asset access on the data source

- **Decided**: `CourseContentDataSource` takes two function typedefs —
  `AssetStringLoader` and `AssetExistsCheck` — instead of calling
  `rootBundle` directly. The production factory wires them to `rootBundle`.
- **Why**: Tests run pure-Dart (no `WidgetsFlutterBinding`) by passing fakes
  that read from in-memory fixture strings. Keeps test setup trivial and
  isolates the data source from Flutter's plugin layer.
- **Revisit if**: We add other asset types (e.g., audio sprite sheets) — the
  same DI shape should extend cleanly.

### D8. Fixtures as Dart strings, not real bundle copies

- **Decided**: `test/vocab/fixtures/course_fixtures.dart` ships inline JSON
  strings (`validBundleJson`, `bundleWithDanglingWordJson`, …) plus a
  matching `validBundleAssetPaths` set.
- **Why**: A real-bundle integration test belongs to a later phase. For Phase
  1, fixtures keep tests deterministic, fast, and editable in one place.
- **Note**: Declared `final String` (not `const`) because the fixtures
  interpolate computed word strings via helper functions.
- **Revisit when**: Phase 8/9 wires the real bundle — we'll add a smoke test
  that loads `assets/vocab/course.json` through the production factory.

### D9. Empty stub bundle in `assets/vocab/course.json`

- **Decided**: Ship an empty-but-valid bundle (`units: []`, `lessons: []`,
  `words: []`) so the app boots and `CourseContentDataSource.load()`
  succeeds before any real content is authored.
- **Why**: Lets us wire the Riverpod providers and run the app in Phase 2+
  without first authoring 500 words.
- **Revisit when**: Real content lands — the empty bundle gets replaced, no
  code changes needed.

### D10. Repositories accept an injectable `Clock`

- **Decided**: All four repositories take a `Clock` typedef defaulting to
  `() => DateTime.now().toUtc()`. Tests inject a fixed clock to assert
  exact `createdAt`/`updatedAt` values.
- **Why**: Time-dependent assertions without `Future.delayed` or wall-clock
  flake.
- **Revisit if**: We need a global app-wide clock (Riverpod-provided) — easy
  swap from a per-repo default.

---

## Phase 2 — Lesson Engine and SRS

### D11. SM-2 lapse fully resets interval to 1

- **Decided**: A failed card (`quality < 3`) sets `interval_days = 1` and
  `consecutive_correct = 0`. Ease factor is left unchanged (vanilla SM-2).
- **Why**: User decision at kickoff. Some SM-2 variants halve the interval
  on lapse; we picked the stricter "back to step 1" rule because it matches
  how the prompt's pedagogy is framed and is easier to reason about than a
  partial decay.
- **Revisit if**: We start seeing leech-like behavior — a stricter lapse
  amplifies that. A "graduating interval" tweak could soften it.

### D12. Status transitions evaluated in order, retirement supersedes

- **Decided**: After SM-2 updates the interval/EF/consecutive counters,
  status moves through `new → learning → reviewing → mature` in sequence;
  `retired` is checked last and wins if both clauses
  (`consecutive_correct >= 5 AND interval > 60`) hold.
- **Why**: The spec lists transitions independently but they can collide:
  e.g., a 50-day-interval-with-EF=2.0-after-5th-correct review jumps to
  100-day interval AND meets the retirement bar. Without an ordering rule,
  the state would be ambiguous. Retirement is the strongest claim, so it
  wins.
- **Revisit if**: We add a "graduate to mature" celebration UX — we may
  want mature → retired to be a separate, deliberate user action.

### D13. `next_review_at = null` sorts after explicit due dates

- **Decided**: In `getReviewCandidates`, a `UserWord` with no
  `next_review_at` is *eligible* (matches the spec's `null OR within 24h`
  filter) but sorts AFTER words with an explicit past or near-future due
  date.
- **Why**: A null due date means "we created the row but haven't run an
  SRS step yet" — usually a transient state. A word with an explicit past
  due date is unambiguously due. The first review-fill test exercises
  exactly this: 6 created rows, 2 with explicit due dates → those 2 must
  win the slots.
- **Revisit if**: We change when `UserWord` rows get created — currently
  `startLesson` pre-creates them for the lesson plan, which is the only
  way `next_review_at` can be null in practice.

### D14. Pre-declared review IDs honored, then SRS, then weighted-random

- **Decided**: Review-slot fill order in `LessonEngine._selectReviewIds`:
  1. Pre-declared `lesson.review_word_ids` from the content bundle
     (filtered to those actually introduced before this lesson)
  2. SRS-eligible candidates from `getReviewCandidates(unitId)`
  3. Weighted-random fallback over previously-introduced words, weighted
     by `1 / (1 + times_seen)` so often-seen words appear less
- **Why**: Matches the prompt's three-tier priority model. Pre-declared
  reviews give content authors an escape hatch for forced repetition. The
  weighted fallback keeps lessons full when the SRS queue is empty (e.g.,
  user is binging through new units).
- **Revisit if**: We add a "review-only" mode — we'd want to bias toward
  SRS-eligible only and skip the random tier.

### D15. `current_lesson_id` only advances if the completed session was current

- **Decided**: `completeLesson` advances progress only when
  `session.lesson_id == progress.current_lesson_id` (or current is null).
  Replaying a previously-completed lesson saves the session row but does
  not double-count progress.
- **Why**: The prompt says "advance on lesson completion" but doesn't
  cover replay. Without this guard, hitting "redo" on lesson 3 after
  finishing lesson 5 would silently regress the user's progress pointer.
- **Revisit if**: We add a separate "review session" UX — those sessions
  shouldn't even attempt to advance, but the guard handles it for free.

### D16. Time-of-day uses exact `now + intervalDays` (not calendar-aligned)

- **Decided**: `next_review_at = now() + intervalDays days`. We do NOT
  snap to local midnight or a "due today" calendar bucket.
- **Why**: Anki's default behavior. The spec's open question flagged this;
  a calendar-aligned scheduler is friendlier UX but requires a stable
  user timezone (which we don't yet have wired up). The `reviewWindow`
  of 24h on the eligibility filter compensates: anything coming due
  within a day is already a review candidate.
- **Revisit if**: Users complain that reviews "shift" to inconvenient
  times of day. Easy fix: snap to start-of-day in the user's local
  timezone after grabbing it from device locale.

### D17. SRS engine is pure; `LessonEngine` owns I/O

- **Decided**: `lib/vocab/domain/srs.dart` is a pure function set
  (`applySrs`, `cardOutcomeForErrors`, `qualityFor`). No Hive, no
  repositories, no clock — `now` is a parameter.
  `lib/vocab/domain/lesson_engine.dart` owns all repository and clock
  interactions.
- **Why**: The SM-2 algorithm is the part most likely to attract
  research-paper-level test scrutiny (and the part most likely to be
  swapped for FSRS or another scheduler later). Keeping it pure means
  one file gets unit-tested in isolation, no Hive setup needed.
- **Revisit if**: We swap to FSRS — the seam is already in the right
  place.

---

## Phase 3 — Card Flow: Intro and Outro

### D18. Example 2 does NOT auto-play on the intro card

- **Decided**: The intro card auto-plays headword → example 1 only.
  Example 2 is on-demand via its play button.
- **Why**: Spec text in the prompt mentioned "Example 2 auto-plays after
  a short delay," but Phase 3 test #4 asserts the *opposite* (`does NOT
  auto-play example 2 audio`). The test is the binding contract — when
  prose and tests disagree, tests win. UX-wise, three back-to-back
  unprompted clips is a lot; ending the auto-chain after example 1
  leaves a natural pause for the user to engage.
- **Revisit if**: The auto-play sequence feels too short in
  user-testing — easy to extend to example 2 by adding one more clause
  to `_onAudioComplete`.

### D19. `VocabAudioPlayer` interface with explicit `onComplete` stream

- **Decided**: `lib/vocab/audio/vocab_audio_player.dart` defines an
  abstract `VocabAudioPlayer` with `play`/`stop`/`dispose` plus two
  streams: `stateStream` (idle/playing/error) and `onComplete` (emits
  the finished asset path). Production impl
  (`AudioPlayersVocabAudioPlayer`) wraps the `audioplayers` package.
- **Why**: Cards chain auto-play by listening to `onComplete`. In tests
  the `FakeVocabAudioPlayer` exposes `completeCurrent()` so we can
  deterministically simulate the headword finishing without real audio
  or timers. Without the abstraction, cards would have to depend
  directly on `audioplayers` and tests would need a mock-plugin layer.
- **Revisit if**: We swap audio backends (e.g., to `just_audio`) — only
  the production impl changes.

### D20. Audio assets prefixed with `vocab/` at the player layer

- **Decided**: `AudioPlayersVocabAudioPlayer.play(path)` calls
  `AssetSource('vocab/$path')`. Word and example records store paths
  *without* the leading `vocab/` (e.g., `audio/w_0001_word.wav`).
- **Why**: The course bundle lives at `assets/vocab/`, so the bundle's
  `audio_path` strings are naturally relative to that root.
  Centralizing the prefix in one place means no caller has to know
  about asset directory layout.
- **Revisit if**: Audio gets sharded across multiple bundles or moves
  to remote URLs — the prefix logic moves into a path resolver.

### D21. Mute detection stubbed to `false` in v1

- **Decided**: `VocabAudioPlayer.isMuted` always returns `false` in
  production. `WordCardBase` shows the muted indicator
  (`Icon(Icons.volume_off)`) when `isMuted` is true, but the trigger is
  not wired in v1.
- **Why**: Flutter has no first-party API for "is the device on
  silent." Plugins exist (`flutter_volume_controller`,
  `audio_session`), but each adds platform-specific permissions. v1
  ships without; the indicator is exercised in tests via
  `FakeVocabAudioPlayer(muted: true)`.
- **Revisit when**: A user-visible "audio not playing" complaint
  surfaces, or when we add a settings screen — at which point the
  toggle could be a manual user preference instead of a hardware probe.

### D22. Translation fallback chain: locale → language → English → first

- **Decided**: `pickTranslation(map, languageCode, scriptCode)` tries:
  exact `lang_Script` match → `lang` match → `'en'` → first available
  entry. Never throws; always returns a non-empty string when the map
  is non-empty.
- **Why**: We ship 16 locales but content authoring won't keep all of
  them in lockstep. A predictable fallback chain means a missing
  Vietnamese gloss falls back to English, not a crash. English is the
  guaranteed pivot per content validation in Phase 1.
- **Revisit if**: We add region-specific bundles where English is no
  longer guaranteed — at which point the fallback should pivot through
  the user's secondary language preference.

### D23. `WordCardBase` is a single shared shell for intro and outro

- **Decided**: `WordCardBase` owns the visual layout (headword,
  romanization, gloss, POS, image, two example rows). `IntroCard` and
  `OutroCard` add their own action rows and own auto-play sequencing.
- **Why**: The two cards differ only in (a) which audio auto-plays and
  (b) the action row at the bottom. Pulling the shell into a base
  widget cuts ~120 lines of duplicate layout code per card and means
  any visual fix lands in one place.
- **Revisit if**: Practice/Test cards (Phase 4) need substantially
  different layouts — better to leave this shared and let those build
  their own shells than over-generalize.

### D24. Headword text uses `Flexible` + `FittedBox(scaleDown)`

- **Decided**: The headword `Text` is wrapped in `Flexible` →
  `FittedBox(fit: BoxFit.scaleDown)` so long Lao words shrink to fit
  rather than overflow the row or push the play button off-screen.
- **Why**: Lao headwords vary widely in width (a 2-character word vs.
  a 6+ character compound). `displayMedium` at full scale on a narrow
  phone caused `RenderFlex overflowed by 7.0 pixels` in test
  viewports. `FittedBox.scaleDown` only shrinks when needed, so short
  words still render at full size.
- **Revisit if**: Compounds get long enough that scale-down hurts
  legibility — at which point we'd switch to a two-line layout.

---

## Phase 4 — Card Flow: Practice and Test

### D25. Reuse the existing `WritingCanvas` via a per-card scope

- **Decided**: Vocab character cards do **not** re-implement the
  drawing engine. They wrap the existing `WritingCanvas` widget in a
  `RealStrokeCanvasHost`, which puts each canvas in its own
  `ProviderScope` overriding `canvasControllerProvider` with a fresh
  `CanvasController`.
- **Why**: The alphabet section's drawing+validation pipeline (DTW,
  stroke matching, ghost guides) is the right code to use for
  vocabulary too — duplicating it would mean two rendering paths to
  maintain. But the existing `canvasControllerProvider` is a global
  Riverpod `StateNotifierProvider`, so without a scope override two
  vocab cards in the tree (or a card + the alphabet screen) would
  share state and step on each other. The per-card scope override
  gives us isolation without forking the widget.
- **Alternatives considered**: (a) refactor `WritingCanvas` to take an
  injected controller — would touch the alphabet section and risk
  regressions. (b) embed the canvas painter directly and skip the
  Riverpod layer — same forking concern.
- **Revisit if**: We need shared canvas state between cards (we
  don't), or the existing widget is refactored to be controller-
  agnostic — at which point we drop the override.

### D26. Swappable `StrokeCanvasHostBuilder` for test injection

- **Decided**: Card widgets accept a `StrokeCanvasHostBuilder`
  function-typed parameter. Production passes
  `defaultStrokeCanvasHostBuilder` (which returns
  `RealStrokeCanvasHost`). Tests pass `fakeStrokeCanvasBuilder` from
  `test/vocab/fakes/fake_stroke_canvas.dart`, which renders a stub
  with three buttons (`fakeStrokeIncorrect`, `fakeStrokeCorrect`,
  `fakeCharacterComplete`) that drive the host card's callbacks
  deterministically.
- **Why**: Per the prompt: "Use a mock drawing control for unit
  tests — don't test the actual stroke recognition here." The builder
  pattern keeps the seam at the widget boundary, so cards have no
  knowledge of the real canvas's implementation details.
- **Revisit if**: We add an integration test that exercises the real
  `WritingCanvas` end-to-end — that test would simply use the default
  builder.

### D27. Glyph → asset codepoint conversion lives in the canvas host

- **Decided**: `WordCharacter.character` stores the Lao glyph itself
  (e.g., `'ສ'`). `RealStrokeCanvasHost._codepointFor(glyph)` derives
  the asset filename codepoint (e.g., `'0EAA'`) by reading the first
  rune and formatting as 4-digit uppercase hex.
- **Why**: The content bundle (Phase 1) carries the glyph as the
  authoring-friendly representation; the existing
  `CharacterStrokeDataSource` expects the codepoint as the file key.
  Putting the conversion at the host means `WordCharacter` doesn't
  need a redundant `codepoint` field, and authors don't need to
  hand-write hex.
- **Revisit if**: We start authoring multi-codepoint clusters (e.g.,
  combining marks) where the first rune isn't enough — at which
  point the field becomes a list.

### D28. Card-mode mapping owned by `lib/vocab/domain/card_mode.dart`

- **Decided**: `cardModeFor(WordStatus)` maps `new`/`learning` to
  `CardMode.practice` and `reviewing`/`mature`/`retired` to
  `CardMode.test`. Cards take `mode` as a parameter and have no SRS
  knowledge.
- **Why**: The prompt says "this mapping is owned by the lesson
  engine." Keeping the function in `domain/` (not the widget tree)
  means it's testable as a pure function and future engine code can
  call it without dragging in Flutter.
- **`retired` → test**: Spec only mentioned `reviewing`/`mature`, but
  a retired word is the most-mature state — showing it with a guide
  would feel like a downgrade. If we ever ship a "retired-word
  refresher" UX, we can branch on it then.

### D29. Per-character error counting; one accumulator per word

- **Decided**: Each non-`correct` `StrokeMatchResult` from the canvas
  contributes **one** error. `WordPracticeFlow` owns the per-word
  accumulator and passes it to the `WordOutcome` it emits when the
  last character completes. Card widgets are stateless w.r.t.
  cross-character state.
- **Why**: SM-2 rates the *word*, not the character. The flow widget
  is the natural owner of per-word state because it's the same
  instance for all the word's characters. Cards stay simple.
- **Revisit if**: We start surfacing per-character feedback in the
  outro — at which point the accumulator becomes a per-char map.

### D30. Show-hint costs 3 errors and is a one-way switch

- **Decided**: In `CharacterTestCard`, tapping "Show hint" adds 3 to
  the error count, switches the canvas to practice mode (guide
  visible), and disables the button for the rest of that character.
- **Why**: The prompt says "show hint" should "cost SRS rating —
  count as extra errors" without specifying how many. Three is high
  enough to hurt the SM-2 grade (3 errors → `again` per
  `cardOutcomeForErrors`) but low enough that a desperate user can
  recover. One-way means the user can't toggle the hint on/off to
  game the penalty.
- **Revisit if**: Telemetry shows users hitting the button on every
  character — that signals the test mode is too hard, not that the
  penalty is wrong.

### D31. Aborting a word emits no `WordOutcome`

- **Decided**: The X button (`abortButton`) calls the `onAbort`
  callback. The flow does not emit `onWordCompleted`, so the engine
  records nothing for the in-flight word.
- **Why**: A partial pass is data of unknown quality — the user may
  have backed out because of a phone call, not because they failed.
  SM-2 should only update on completed cards. Future work can add a
  separate "session abandoned" telemetry signal if we want to
  surface it.

### D32. Mode is set at flow construction; never flips mid-word

- **Decided**: `WordPracticeFlow.mode` is `final`. Even if the user's
  SRS status changes during the session (e.g., from `new` to
  `learning`), the flow keeps the mode it started with for this
  word.
- **Why**: A word's mode-switch should be a deliberate decision the
  engine makes between cards, not something the UI does mid-word.
  Mid-word toggles would also be confusing for the user.

### D33. Strings in `lib/vocab/presentation/i18n/character_strings.dart`

- **Decided**: Hint copy ("Draw a consonant"), prompt copy ("Trace
  this character"), and progress label ("Character 1 of 3") live in
  one constants file rather than inline in widgets. English-only in
  v1; the file is shaped to swap in `AppLocalizations.of(context)`
  calls in v2.
- **Why**: The prompt asked for the type-hint strings to be in a
  "localization-ready string table." Putting all card-related copy
  in one file keeps the swap mechanical when v2 lands.
- **Revisit when**: The full vocab feature lands and we wire in the
  existing `AppLocalizations` system.

---
