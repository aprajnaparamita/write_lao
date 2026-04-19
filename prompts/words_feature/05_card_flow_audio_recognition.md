# Phase 05 — Card Flow: Hear and Identify

**Depends on:** `01`, `02`, `03`, `04`

## Objective

Implement the occasional "hear and identify" card type. This addresses listening and tone discrimination, which matters for Lao specifically.

## When does this card appear

Not on every lesson. Occasionally, as a review slot substitute:

- On review lessons (not lesson 1 of any unit) where the user has enough learned words (at least 5) to populate distractors
- With probability ~25% — roughly 1 in 4 review slots gets converted to a hear-and-identify
- Cap: at most 1 per lesson (don't spam the user with listening cards)

This is a v1 heuristic. Make it tunable from a single config value (e.g., `HEAR_IDENTIFY_PROBABILITY = 0.25`).

## Card contents

- Prompt: "Which word did you hear?"
- A "Play audio" button (or auto-plays on card load — see behavior below)
- Four options arranged in a 2×2 grid. Each option shows:
  - The Lao word in script
  - The associated image
- No romanization, no English gloss (those are spoilers)

## Distractor selection

The correct answer is a word the user has learned (`status in ('learning', 'reviewing', 'mature')`). The three distractors are:

- Also words the user has learned (not retired, not new)
- Different from the correct answer
- Ideally, similar to the correct answer phonologically or tonally (better practice) — but that requires tone-pair data that may not exist yet. **v1 heuristic:** random distractors from the learned pool.
- Deduped (no repeats within the card)

When the teacher's review adds tone-pair metadata later, the distractor selection can become smarter. For v1, random learned-pool distractors are fine.

## Behavior

- On card appearance, auto-play the correct word's audio once
- User can tap the play button to hear it again (unlimited replays; replays do not penalize)
- User taps one of the four options
- **On correct answer:** the chosen option highlights green, the word's full info (gloss, romanization) briefly appears for reinforcement, card advances after ~1 second
- **On wrong answer:** the wrong option highlights red, the correct option highlights green, the word's full info appears, card advances after ~2 seconds
- User cannot change their answer after tapping (no un-selecting)

## SRS integration

Treat this card as a review of the **correct word**, not all four. The rating feeds SM-2 for the correct word only:

| Outcome | SM-2 quality |
|---|---|
| Correct on first try | 4 (Good) |
| Wrong | 2 (Again) |

We don't track Hard or Easy on this card type — the binary right/wrong signal is all there is.

## Audio

Use the same `AudioPlayer` abstraction from Phase 03. The correct word's `audio_path` plays; distractor audio is never played.

## Tests (write these first)

1. Card selects 4 unique words — 1 correct + 3 distractors
2. Distractors are drawn only from learned words (not new, not retired)
3. Correct answer highlights green on selection
4. Wrong answer highlights red, correct answer highlights green
5. Audio auto-plays on card load
6. Audio can be replayed via button
7. Correct answer records SM-2 quality 4 for the correct word
8. Wrong answer records SM-2 quality 2 for the correct word
9. Distractors' SRS state is not modified
10. Card is skipped (not displayed) when fewer than 4 learned words exist
11. Probability gate (25%) controls whether card appears in eligible lessons

## Done when

- Card type integrates with the lesson engine
- Appears occasionally, not every lesson
- SM-2 updates correctly for the correct word
- All tests pass
- `DECISIONS.md` notes probability tuning and distractor selection strategy

## Open questions to flag

- **Is this on by default in v1, or behind a setting?** Default: on. But worth having a "disable listening practice" setting for users who don't care.
- **If the correct word is retired, does this card use it as a correct answer?** Default: no. Retired means the user has fully learned it; re-testing it via this card isn't valuable.
- **Should wrong answers be weighted (harder distractors lower SRS rating)?** Not for v1. Simple right/wrong.
- **Accessibility.** Deaf users cannot use this card. It should be skippable at the user level (disable the feature in settings) or provide a visible-only variant (show IPA and ask which script matches). Flag this.
