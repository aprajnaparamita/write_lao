# Phase 04 — Card Flow: Practice and Test

**Depends on:** `01`, `02`, `03`. **Must integrate with:** the existing Write Lao drawing/practice control (see below).

## Objective

Implement the per-character drawing cards that form the core of the vocabulary-practice experience. There are two modes:

- **Practice mode** — used on first encounter and early reviews. Shows a stroke guide. User traces the character.
- **Test mode** — used on spaced-repetition reviews. No guide. User draws from memory, knowing only the character *type* (consonant / vowel / tone).

Both modes reuse the drawing/validation control that already exists in Write Lao's alphabet section. Do not re-implement the drawing engine. Integrate with the existing one.

## Integration requirement (read this first)

Write Lao already has a handwriting practice control for teaching individual letters. This phase **extends** that control, not replaces it. Before writing any code:

1. Locate the existing drawing/practice control in the Write Lao codebase
2. Document its API (how it's instantiated, what character it accepts, what events/callbacks it provides, what "correct" and "error" mean)
3. Propose how to reuse it for both practice and test modes

If the existing control doesn't expose a "no-guide / test-mode" variant, extend it with one. Do not fork it.

## Practice card

Shown for each character of a word being newly introduced (or a word in early review stages, TBD in integration plan).

### Contents

- Small indicator of progress: "Character 1 of 3" or similar
- The character being practiced, shown with stroke guide (light gray, animated if the control supports it)
- Prompt: "Trace this character"
- The drawing canvas (from the existing Write Lao control)
- Below the canvas: the current word being built, with already-completed characters in black and the current character highlighted / pending

### Behavior

- User traces the character on the canvas
- The drawing control validates strokes (reusing existing Write Lao logic)
- On successful completion, the character appears in "built-up" word preview below
- Automatic advance to the next character's practice card
- If the user errors, the existing control's error feedback applies (e.g., flash, retry). Count errors for SM-2 scoring.

### Per-character error counting

Every error on every character contributes to the **word's total error count**, which feeds the SM-2 rating at the end. Track this per-word, not per-character. The practice sequence for one word shares one error accumulator.

## Test card

Shown for each character of a word in review, where the user must recall the word from memory.

### Contents

- Progress indicator: "Character 2 of 3"
- A hint about the character *type*: "Draw a consonant" or "Draw a vowel" or "Draw a tone mark"
- The drawing canvas (no guide)
- The already-drawn previous characters shown in a preview strip, but **the current slot is blank**
- No image, no gloss (those are test-mode spoilers)

### Behavior

- User draws the expected character from memory on the canvas
- The drawing control validates against the expected character (same validation logic as practice, just without the visual guide)
- On successful completion, the character is revealed in the preview and the card advances
- On repeated errors, the card can offer a "show hint" button that reveals the stroke guide (costs SRS rating — counts as extra errors)
- Count errors toward the word's total for SM-2 scoring

### What test mode does NOT show

- The word's Lao script as a whole
- The image
- The English gloss
- The audio (no pronunciation hint)

All those come on the outro card *after* the test is complete.

## Mode selection — practice vs test

Based on the word's SRS status:

- `new` or `learning` → practice mode (with guide)
- `reviewing` or `mature` → test mode (no guide)

This mapping is owned by the lesson engine (Phase 02). The card just receives a "mode" parameter. Don't embed mode logic in the card itself.

## Character-type hint strings

For test mode, the hint text is:

- `"consonant"` → "Draw a consonant"
- `"vowel"` → "Draw a vowel"
- `"tone"` → "Draw a tone mark"

Keep these in a localization-ready string table (English-only v1, but structured so v2 can localize).

## Error handling during drawing

Integrate with whatever error feedback the existing Write Lao control provides. If the existing control has "wrong stroke → flash red + reset," use that. If it allows partial progress, use that. Don't invent new error mechanics.

## Word completion

When the last character of a word is completed:

- Finalize the word's error count for SRS
- Emit a `wordCompleted` event with `{ wordId, errorCount, durationMs }`
- The lesson engine consumes this to call `recordCardOutcome` (Phase 02)
- The flow advances to the outro card (Phase 03)

## Tests (write these first)

1. Practice card loads with correct character and visual guide
2. Practice card tracks errors from the drawing control
3. Practice card advances on successful character completion
4. Test card loads with no visual guide but correct character-type hint
5. Test card accepts correct character and advances
6. Test card rejects incorrect character (via the drawing control's validation)
7. Test card's "show hint" button reveals the guide and increments error count
8. Errors accumulate across all characters of a word into a single count
9. Word completion emits correct event with accurate error total
10. Mode selection returns "practice" for new words, "test" for reviewing words
11. The practice sequence advances smoothly from character 1 to character 2 to character 3 without UI glitches
12. Aborting mid-word (user backs out) does not record a completion

Use a mock drawing control for unit tests — don't test the actual stroke recognition here. That's owned by the existing Write Lao tests.

## Done when

- Practice and test cards both function end-to-end with the existing drawing control
- Error counts feed correctly into SRS
- Lesson flow correctly transitions: intro → N practice/test cards → outro
- All tests pass
- `DECISIONS.md` documents integration with existing drawing control and any changes made

## Open questions to flag

- **Should the user be able to "skip" a character in test mode?** If they truly don't know, tapping "skip" could mark the word as failed and move on. Probably yes, at cost of an SM-2 "Again" rating. Confirm before implementing.
- **Retry limits.** How many times can a user mis-stroke a character before being forced to retry the word from the start? Default: unlimited retries within a character, but errors accumulate toward SRS rating.
- **Stroke order enforcement.** If the existing control enforces stroke order on characters, that's what we use. If it allows any-order-as-long-as-it-looks-right, that's what we use. Match existing behavior.
- **Handwriting tolerance.** Whatever the existing control's tolerance is, use it. Don't tighten or loosen for the vocabulary feature.
