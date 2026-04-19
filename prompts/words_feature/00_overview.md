# Write Lao — 500-Word Vocabulary Feature

## Context

Write Lao is an existing mobile app that teaches the Lao alphabet through stroke-based handwriting practice. This project adds a new **500-word vocabulary section** as an in-app purchase ($1 IAP) inside the existing app.

The vocabulary feature assumes users have already learned the Lao alphabet through the free part of Write Lao. Do not re-teach letters — teach words composed of those letters, with writing as the primary practice method.

## Audience

- Users who have completed or are comfortable with the Write Lao alphabet curriculum
- Script-literate in Lao (can read/write the characters)
- Not necessarily fluent — they know letters but not vocabulary yet
- Mobile-first, studying in short sessions (5-10 minutes)

## What you are building

A self-contained vocabulary + writing trainer that:

1. Presents 500 Lao words across 20 thematic units (5 lessons × 5 words per unit)
2. Uses spaced repetition (SM-2) to schedule review
3. Requires users to write words by drawing each character in sequence
4. Provides audio pronunciation (headword + two example sentences per word)
5. Supports a personal flagged-word deck for extra review
6. Works entirely offline on a single device (no server calls, no sync in v1)

## What you are NOT building (v1 scope boundaries)

- User authentication or accounts
- Cloud sync or server-side state
- Multi-user support on one device
- Social features, leaderboards, sharing
- Content generation (the 500 words + metadata are provided as input data)
- The review/authoring tool (that's a separate system)
- Audio recording (TTS and native recordings are provided as audio files)
- Image generation (images are provided)

## Forward compatibility with cloud sync

v1 is offline-only and single-device. v2 will add cloud sync. Design choices for v1 must not prevent v2:

- Use UUIDs (not auto-increment integers) for all user-state records
- Every user-state row has a `created_at` and `updated_at` timestamp
- State mutations are expressed as idempotent operations (e.g., "set card X to interval Y" rather than "increment interval")
- Keep a simple `sync_state` column on user-state tables (`"local"` for v1, later values will be `"synced"`, `"pending"`, `"conflict"`)
- No hard-coded assumptions that user-state is singular (design as if it were a table of user-owned records, even though v1 only ever has one user)

These are lightweight choices that make v2 sync achievable without a rewrite. Do not implement sync itself.

## Phases of this prompt package

This project is broken into numbered phases. Work through them in order:

- `01_data_model_and_schema.md` — Database schema, content data format, loading and validation
- `02_lesson_and_srs_engine.md` — Lesson selection logic, SM-2 implementation, review scheduling
- `03_card_flow_intro_and_outro.md` — Intro card and outro card UI/logic
- `04_card_flow_practice_and_test.md` — Per-character practice and test-mode drawing cards
- `05_card_flow_audio_recognition.md` — Occasional "hear and identify" card type
- `06_flag_decks.md` — Personal flagged-word decks for user-directed review
- `07_unit_and_lesson_navigation.md` — Unit/lesson list UI, progress, gating
- `08_iap_and_gating.md` — IAP state, feature unlock, upsell prompts
- `09_integration_with_write_lao.md` — Integration points with the existing Write Lao app
- `10_testing_and_deployment.md` — End-to-end tests, bundle packaging, release checklist

Each phase has its own file with dependencies, deliverables, and test requirements.

## Development principles (apply to every phase)

### Test-driven development, required

- Every phase begins by writing failing tests that specify the behavior
- Implementation follows tests, not the other way around
- No commit merges without tests passing
- Aim for high coverage on core logic (SRS, lesson selection, schema). UI tests can be lighter.

### Small commits

- Each commit does one thing
- Commit messages describe the behavior change, not the code change

### Ask before inventing

- If a phase is under-specified, flag it and propose 2-3 options before implementing
- Do not silently invent UX flows, algorithms, or data shapes not covered in the prompt

### Document decisions

- Each phase ends with a short `DECISIONS.md` entry: what was decided, what alternatives were considered, what future-you might want to revisit

## Technical assumptions (flexible — adapt to actual stack)

Write Lao is assumed to be a cross-platform mobile app and uses Flutter + sqflite.

The project scaffolding should:

- Use the existing Write Lao codebase conventions
- Add a local SQLite database (or equivalent) for user state
- Store course content as bundled JSON + media files in the app package
- Not introduce new runtime dependencies beyond what's necessary

If the actual stack differs from these assumptions, adapt the code but preserve the architecture (offline SQLite, bundled content, local state only).

## What the agent should do first

1. Read all 10 phase files in `/prompts/`
2. Examine the existing Write Lao codebase to understand its conventions, testing framework, and UI patterns
3. Propose an integration plan (where does new code live? which existing patterns get reused?)
4. Wait for approval before starting Phase 1

Do not start coding until the integration plan is confirmed.
