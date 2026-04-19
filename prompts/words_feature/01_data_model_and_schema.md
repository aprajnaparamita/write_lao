# Phase 01 — Data Model and Schema

**Depends on:** `00_overview.md`
**Status:** Prerequisite for all subsequent phases.

## Objective

Define the data layer for both **course content** (static, read-only, ships with the app) and **user state** (dynamic, mutable, stored in local SQLite). Build ingestion and validation for the content bundle.

## Deliverables

1. SQLite schema migrations for user-state tables
2. Content bundle format (JSON + media files)
3. Content loader that reads the bundle and exposes query APIs
4. Schema validation for the content bundle (fail loudly on malformed input)
5. Tests for all of the above

## Course content structure

Course content is provided as a JSON bundle plus media files. The bundle is produced by the separate review/authoring tool and is treated as an opaque input here. Ship it inside the app package, load on first launch.

### File layout (in app bundle)

```
content/
  course.json              # the master content file
  images/
    w_0001.webp
    w_0002.webp
    ...
  audio/
    w_0001_word.wav
    w_0001_example1.wav
    w_0001_example2.wav
    ...
```

### course.json shape

```json
{
  "version": "1.0.0",
  "language": "lao",
  "target_audience": "write_lao_500",
  "units": [
    {
      "unit_id": "u_01",
      "unit_number": 1,
      "title": "Family and People",
      "description": "Basic family vocabulary",
      "lesson_ids": ["l_01_01", "l_01_02", "l_01_03", "l_01_04", "l_01_05"]
    }
  ],
  "lessons": [
    {
      "lesson_id": "l_01_01",
      "unit_id": "u_01",
      "lesson_number": 1,
      "new_word_ids": ["w_0001", "w_0002", "w_0003"],
      "review_word_ids": []
    }
  ],
  "words": [
    {
      "word_id": "w_0001",
      "lao_word": "ແມ່",
      "romanization": "mɛ̂ː",
      "english_gloss": "mother",
      "part_of_speech": "noun",
      "characters": [
        {"position": 0, "character": "ແ", "type": "vowel"},
        {"position": 1, "character": "ມ", "type": "consonant"},
        {"position": 2, "character": "່", "type": "tone"}
      ],
      "image_path": "images/w_0001.webp",
      "audio_path": "audio/w_0001_word.wav",
      "examples": [
        {
          "example_id": "w_0001_ex1",
          "lao_script": "ແມ່ ຮັກ ລູກ",
          "romanization": "mɛ̂ː hak luːk",
          "english_gloss": "Mother loves the child",
          "audio_path": "audio/w_0001_example1.wav"
        },
        {
          "example_id": "w_0001_ex2",
          "lao_script": "...",
          "romanization": "...",
          "english_gloss": "...",
          "audio_path": "audio/w_0001_example2.wav"
        }
      ]
    }
  ]
}
```

This data must be generated from the following locations:

prompts/data/step5_definition_prompts/*.json

Each json contains 5 words with descriptions in all l18n languages as
well as 2 examples in all l18n languages.

images for each word are in:
prompts/data/outputs/

and are named according to the index within the json file in
step5_definition_prompts. so prompt_099_of_100_1.png is the image for
the first word in prompt_099_of_100.json which is "ຈານ".

Similarly audio for each is saved in:
prompts/data/audio/

with the same naming convention except it includes _example1 and 
_example2 as well as _word for the examples and word respectively.

The order of these files is based on word freqency and the data and
files SHOULD be reorganixed and copied to a new location such as the
assets folder to better suit distribution. 

### Notes on the content structure of the proposed new json

- `characters` array is the stroke-by-stroke sequence the user practices. Character types are one of: `"consonant"`, `"vowel"`, `"tone"`. The teacher's review tagged these; trust the data.
- `position` is the draw order (phonological order), not necessarily visual order. Rendering handles visual positioning separately.
- For lesson 1 of unit 1, `review_word_ids` is an empty array (no prior words to review). The app treats this as a special case.
- The course bundle is validated on first load. Validation errors should fail loudly — they indicate a build-time bug.

## User state schema (local SQLite)

All user-state tables follow these conventions:

- Primary keys are UUIDs (strings), not auto-increment
- Every row has `created_at` and `updated_at` as ISO-8601 timestamps
- Every row has a `sync_state` column defaulting to `"local"` (unused in v1, wired for v2)

### Table: `user_word`

One row per word the user has encountered.

```sql
CREATE TABLE user_word (
  id TEXT PRIMARY KEY,           -- UUID
  word_id TEXT NOT NULL,         -- FK to content word_id
  
  -- SM-2 state
  ease_factor REAL NOT NULL DEFAULT 2.5,
  interval_days INTEGER NOT NULL DEFAULT 0,
  next_review_at TEXT,            -- ISO-8601, null until first review scheduled
  last_reviewed_at TEXT,
  consecutive_correct INTEGER NOT NULL DEFAULT 0,
  
  -- Encounter tracking
  times_seen INTEGER NOT NULL DEFAULT 0,
  times_correct INTEGER NOT NULL DEFAULT 0,
  first_seen_at TEXT,
  
  -- State
  status TEXT NOT NULL DEFAULT 'new',  -- 'new' | 'learning' | 'reviewing' | 'mature' | 'retired'
  
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'local',
  
  UNIQUE(word_id)
);

CREATE INDEX idx_user_word_next_review ON user_word(next_review_at);
CREATE INDEX idx_user_word_status ON user_word(status);
```

### Table: `user_progress`

Singleton row tracking overall progress. In v1 there's always exactly one row.

```sql
CREATE TABLE user_progress (
  id TEXT PRIMARY KEY,                   -- UUID
  current_unit_id TEXT,                  -- null if user hasn't started
  current_lesson_id TEXT,
  units_completed INTEGER NOT NULL DEFAULT 0,
  lessons_completed INTEGER NOT NULL DEFAULT 0,
  iap_unlocked INTEGER NOT NULL DEFAULT 0,  -- 0 = free user, 1 = paid
  
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'local'
);
```

### Table: `user_session`

Per-lesson completion record. Useful for analytics and for future sync.

```sql
CREATE TABLE user_session (
  id TEXT PRIMARY KEY,                   -- UUID
  lesson_id TEXT NOT NULL,
  started_at TEXT NOT NULL,
  completed_at TEXT,                     -- null if abandoned
  errors_count INTEGER NOT NULL DEFAULT 0,
  duration_seconds INTEGER,
  
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'local'
);

CREATE INDEX idx_user_session_lesson ON user_session(lesson_id);
```

### Table: `flag_deck`

User-created decks of flagged words.

```sql
CREATE TABLE flag_deck (
  id TEXT PRIMARY KEY,           -- UUID
  name TEXT NOT NULL,
  
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'local'
);

CREATE TABLE flag_deck_word (
  id TEXT PRIMARY KEY,           -- UUID
  deck_id TEXT NOT NULL,
  word_id TEXT NOT NULL,
  
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'local',
  
  UNIQUE(deck_id, word_id),
  FOREIGN KEY (deck_id) REFERENCES flag_deck(id) ON DELETE CASCADE
);
```

## Content loader API

Expose a read-only query API over the loaded content:

- `getAllUnits()` → list of units in order
- `getUnit(unitId)` → unit with its lesson IDs
- `getLesson(lessonId)` → lesson with its word IDs (new + review)
- `getWord(wordId)` → full word record including characters and examples
- `getWordsInUnit(unitId)` → all words that appear in any lesson of this unit
- `getWordsIntroducedBefore(lessonId)` → all words whose first introduction precedes this lesson (useful for SRS review pool filtering)

The content is read-only at runtime. No write API.

## Validation (on bundle load)

On first launch (or version change), validate the bundle:

- Every `lesson.new_word_ids` and `lesson.review_word_ids` references an existing word
- Every `lesson_id` in `unit.lesson_ids` exists in `lessons`
- Every `unit_id` on a lesson exists in `units`
- Every `image_path` and `audio_path` referenced exists in the bundle
- Every word has at least one example
- Character types are one of the allowed values
- Number of words matches expected total (log a warning if mismatched; don't hard-fail since future versions may have different counts)

Fail loudly with a clear error message if validation fails. Log which fields failed. Do not attempt to recover.

## Tests (write these first)

1. Schema creation migration runs cleanly on a fresh database
2. Schema migration is idempotent (runs twice without error)
3. Content loader parses a valid `course.json` fixture
4. Content loader rejects a `course.json` with dangling word reference
5. Content loader rejects a `course.json` with missing image file
6. Content loader rejects an invalid character type
7. `getWordsInUnit` returns words across all lessons in the unit
8. `getWordsIntroducedBefore` correctly scopes based on lesson ordering
9. User-state tables support inserting, updating, and querying with UUIDs
10. `updated_at` is automatically set on update (via trigger or ORM hook)

Use fixture data for tests — a small course.json with 2 units, 3 lessons, 10 words. Don't test against the real 500-word bundle.

## Done when

- All tests pass
- A fresh install can load the content bundle without error
- User-state tables exist and accept writes
- `DECISIONS.md` documents schema choices (why UUIDs, why `sync_state`, any schema surprises)

## Forward-compat notes

Do not implement sync logic. The `sync_state` column exists so v2 can add sync without altering tables. The UUID primary keys mean v2 can merge state from multiple devices without ID collisions. That's all.
