# Phase 02 — Lesson Engine and SRS

**Depends on:** `01_data_model_and_schema.md`

## Objective

Implement the lesson-selection logic and the SM-2 spaced repetition algorithm. No UI in this phase — this is the engine that the card UI will call into.

## What this phase covers

- Selecting the words for a given lesson (3 new + 2 review, with v1-of-unit-1 special case)
- Running SM-2 after each card to update user_word records
- Computing a user's due-for-review queue
- Determining lesson completion and unlock state

## What this phase does NOT cover

- Drawing or scoring character strokes (Phase 4)
- UI for cards (Phases 3-5)
- Audio playback (Phases 3, 5)

## Lesson word selection

When a user opens lesson `L`:

1. Look up `L.new_word_ids` — these are the 3 new words for the lesson
2. Look up `L.review_word_ids` — these are up to 2 review slots
3. For each review slot, pick a word:
   - Candidates: words introduced in earlier lessons of the same unit, or any earlier unit
   - Priority 1: words whose `next_review_at` is in the past (genuinely due)
   - Priority 2: words whose `next_review_at` is within 24 hours (coming due soon)
   - Priority 3: words with lowest `consecutive_correct` (struggling words)
   - Exclude: words with `status = 'retired'`
4. If fewer than 2 due-review candidates exist, fill remaining slots with words from prior lessons at random (weighted toward lower `times_seen`)
5. For lesson 1 of unit 1, no review slots — the lesson is just 3 new words

Return an ordered list of 3-5 cards the user will see this lesson.

### Edge case: review pool empty

If the user is in unit 1 lesson 2 and has somehow not retained any word from lesson 1 (unlikely but possible), the review slots should still be populated — default to random words from completed lessons. Never return fewer than the expected card count.

### Edge case: review slot assignment pre-declared in content

The `lesson.review_word_ids` field in the content bundle may be empty (most lessons) or may pre-declare specific review words (if the content designer wants to force certain reviews). Honor pre-declared review words first, then fill remaining slots with SRS-selected reviews.

## SM-2 implementation

Standard SM-2 with minor adjustments for this app's rating model.

### Input: user rating (derived, not user-entered)

After each card, the app produces an SRS rating based on in-card performance:

| Card outcome | Rating | SM-2 quality value |
|---|---|---|
| 0 errors on any character | Easy | 5 |
| 1 error | Good | 4 |
| 2 errors | Hard | 3 |
| 3+ errors or user abandoned | Again | 2 |

Quality values below 3 are treated as "failed" in SM-2 terms.

### Algorithm

Given `user_word` state and incoming `quality` (2-5):

```
if quality >= 3:
    if interval_days == 0:
        new_interval = 1
    elif interval_days == 1:
        new_interval = 6
    else:
        new_interval = round(interval_days * ease_factor)
    
    new_ease_factor = ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
    new_ease_factor = max(1.3, new_ease_factor)
    
    consecutive_correct += 1
else:  # quality < 3, failed
    new_interval = 1
    new_ease_factor = ease_factor  # SM-2 doesn't reduce EF on fail, just interval
    consecutive_correct = 0

next_review_at = now + new_interval days
last_reviewed_at = now
times_seen += 1
if quality >= 3: times_correct += 1
```

### Status transitions

- `new` → `learning` on first encounter
- `learning` → `reviewing` after first successful review (quality >= 3 and interval > 1)
- `reviewing` → `mature` when `interval_days > 90`
- Any state → `retired` when `consecutive_correct >= 5 AND interval_days > 60`

(The retirement rule combines consecutive-correct count with interval length — flags set earlier recommended this as more reliable than count alone.)

### Retired words

Retired words:
- Do not appear in lesson review slots
- May still appear via the flag-deck feature (Phase 6) if the user flagged them
- Show up in a "completed words" reference screen (future scope)

## Due-for-review queue

Provide a query: `getReviewCandidates(unitId)` that returns words eligible for review in this unit's context.

```
eligible if:
  word was introduced in a lesson of unit <= given unit_id
  AND status != 'retired'
  AND (next_review_at is null OR next_review_at < now + 24 hours)
```

Order by:
1. `next_review_at ASC` (most overdue first)
2. `consecutive_correct ASC` (most struggling first) as tiebreaker

## Lesson completion

A lesson is marked complete when the user finishes all cards in it (intro + practice sequence + outro per word, plus any hear-and-identify cards). Persist via `user_session` insert.

A unit is marked complete when all lessons in it are complete.

The `user_progress.current_unit_id` and `current_lesson_id` advance on lesson completion. If the last lesson of unit N is completed, unit N+1 becomes current.

## Public API for this engine

The lesson engine exposes a small API to the UI:

- `startLesson(lessonId)` → returns the ordered list of cards/actions for this lesson; creates a `user_session` row with `started_at`
- `recordCardOutcome(wordId, outcome)` → updates user_word via SM-2
- `completeLesson(sessionId, duration, totalErrors)` → marks session complete, advances progress if appropriate
- `getReviewCandidates(unitId)` → for populating review slots
- `getCurrentProgress()` → returns user's current unit/lesson

## Tests (write these first)

1. SM-2 with quality=5 on a new word sets interval=1, next_review_at=now+1day
2. SM-2 with quality=5 on a word at interval=1 sets new interval=6
3. SM-2 with quality=5 on a word at interval=6 applies ease_factor multiplier
4. SM-2 with quality=2 resets interval to 1 but preserves ease_factor
5. SM-2 with quality=2 resets consecutive_correct to 0
6. SM-2 ease_factor never drops below 1.3
7. Word transitions new → learning → reviewing → mature at expected thresholds
8. Word retires when consecutive_correct >= 5 AND interval > 60
9. Retired words are excluded from getReviewCandidates
10. getReviewCandidates filters by unit scope (unit 3 does not return words from unit 5)
11. Lesson 1 of unit 1 returns exactly 3 cards (3 new, 0 review)
12. A lesson with review_word_ids pre-declared honors those words
13. A lesson with empty review_word_ids fills slots from SRS candidates
14. completeLesson advances current_lesson_id
15. Completing the last lesson of a unit advances current_unit_id

## Done when

- All tests pass
- The engine can run a full simulation: start lesson → record outcomes → complete lesson → next lesson is correctly set up
- SRS state updates are durable (restart app, state is preserved)
- `DECISIONS.md` notes any adjustments from classic SM-2

## Open questions to flag before implementing

Flag these explicitly if they come up during implementation — do not silently decide:

- **Lapse threshold.** Does a "fail" (quality < 3) halve the interval (some SM-2 variants) or fully reset to 1? The prompt says full reset; confirm before implementing.
- **Ease floor changes.** SM-2 default floor is 1.3. Anki uses 1.3 but some research suggests 1.5. Stick with 1.3 for v1.
- **Time of day.** When a word is "due today," is that any time on the calendar day, or exactly 24 hours after last review? Use "any time on the calendar day in user's local timezone" — friendlier UX.
