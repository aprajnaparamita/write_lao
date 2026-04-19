# Phase 07 — Unit and Lesson Navigation

**Depends on:** `01`, `02`, `03`, `04`, `05`

## Objective

Build the screens that let a user navigate the course — unit list, lesson list within a unit, lesson completion state, and the gating logic that controls what's unlocked.

## Screens

### Unit list (top-level course screen)

Shows all 20 units in order. Each unit row shows:

- Unit number (e.g., "1")
- Unit title (e.g., "Family and People")
- Completion state (visual indicator: locked, in-progress, complete)
- Number of lessons complete / total (e.g., "3 / 5")
- Optional: a small icon or illustration per unit (from content metadata, if present)

Interaction:
- Tap an unlocked unit → navigate to its lesson list
- Locked units show a lock icon and are not tappable (or show a brief message: "Complete Unit 2 to unlock")

### Lesson list (within a unit)

Shows the 5 lessons of the current unit. Each lesson row shows:

- Lesson number (e.g., "Lesson 3")
- Completion state
- Word count (always 5 in v1, but don't hard-code it — pull from content)
- Preview of the 3 new words (small Lao script or English glosses)

Interaction:
- Tap an unlocked lesson → start it
- Locked lessons (not yet reached in this unit) show lock icon
- Completed lessons remain tappable for re-study (does not advance progress, may still update SRS if the user re-does the lesson)

### Post-lesson summary (end of a lesson)

Shown after the final outro card of the last word in a lesson:

- "Lesson X complete"
- Optional: per-word quick summary (errors per word), encouraging message based on performance
- "Continue" button → returns to lesson list, next lesson is now current
- If this was the last lesson of a unit: "Unit X complete" celebration screen before returning to unit list

Keep celebration screens short and skippable. Users who are grinding through lessons don't want a 5-second animation every time.

## Gating logic

Defined in Phase 02's engine, applied here in UI:

### Unit gating

Unit 1 is unlocked on IAP purchase. Unit N (N > 1) is unlocked when all lessons in unit N-1 are complete.

### Lesson gating

Within a unit, lessons unlock linearly. Lesson 1 of a unit is unlocked when the unit is unlocked. Lesson N (N > 1) is unlocked when lesson N-1 is complete.

### Re-study

Completed lessons are always re-studyable. Re-study does not "un-complete" them. SRS still applies — if the user re-does a word, its SRS state updates normally.

## Progress indicators

### Global progress

A progress bar or count somewhere (e.g., top of unit list screen): "X / 500 words mastered" where "mastered" means status in ('mature', 'retired').

### Unit progress

In the unit list row, show "3 / 5 lessons" or a mini progress bar.

### Lesson progress

If a user abandons a lesson partway through, what state is the lesson in? Options:

- Treat it as "not started" (user restarts from scratch)
- Save mid-lesson state and let them resume

For v1: **treat abandoned lessons as not started.** Simpler. Lesson is either complete or not.

If the abandoned lesson's first card already triggered SRS updates, those stay. But the lesson itself isn't "in progress" — user has to start over.

## Content-driven unit metadata

Unit titles, descriptions, and optional icons come from `course.json`. Don't hard-code any of them — pull from the loaded content. Unit 1 might be "Family," unit 2 might be "Food," etc., depending on what the teacher finalizes in review.

## Tests (write these first)

1. Unit list shows 20 units
2. Unlocked/locked state matches progression (unit 1 unlocked after IAP, rest locked until predecessor complete)
3. Tapping an unlocked unit navigates to its lesson list
4. Tapping a locked unit does nothing (or shows a "locked" message)
5. Lesson list within a unit shows 5 lessons
6. Lesson 1 is unlocked when the unit is unlocked
7. Lesson N>1 is locked until lesson N-1 is complete
8. Completed lessons remain tappable
9. Completing the last lesson of a unit triggers the "unit complete" flow and unlocks the next unit
10. Global progress counter updates as words are mastered
11. Abandoning a lesson mid-flow does not mark it complete

## Done when

- User can navigate from unit list → lesson list → lesson → back, reliably
- Gating logic enforces linear progression
- Progress indicators are accurate
- All tests pass
- `DECISIONS.md` documents re-study behavior and abandonment handling

## Open questions to flag

- **Unit themes and order.** Content-driven; no decisions here. Pull from course.json.
- **Progress reset.** Is there a "reset my progress" button somewhere? Not for v1. Add in settings later if users ask.
- **Visual polish.** Progress bars, animations, unit icons — match the existing Write Lao app's visual style. Don't introduce a new design language.
