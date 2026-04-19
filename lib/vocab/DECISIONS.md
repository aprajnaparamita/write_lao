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
