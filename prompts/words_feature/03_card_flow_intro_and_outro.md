# Phase 03 — Card Flow: Intro and Outro

**Depends on:** `01`, `02`

## Objective

Implement the two non-practice card types that bookend each word: the **intro card** (first thing a user sees for a word) and the **outro card** (final reveal after practice).

The practice cards in between are Phase 04.

## Intro card

Shown at the start of each word (both new encounters and reviews).

### Contents

- The Lao word in large, readable script with a play button next to it
- The IPA / romanization below it
- The English definition
- The part-of-speech tag (e.g., "noun", "verb")
- The associated image
- The example1 in lao with a play button next to it
- The translation in the user's l18n locale language for example
- The example 2 in lao with a play button next to it
- The translation in the user's l18n locale language for example2
- A "Continue" or "I'm ready" button to advance to the practice cards

### Behavior

- When the card appears, auto-play the audio for the headword play
  button enlarges slightly and turns green while playing, tapping it
stops play for this card and it returns to a neutral color. but if
tapped while neautral it would play only this.
- After headword audio finishes, auto-play example sentence 1 audio with
  a visual cue while it's playing which stops when it ends while playing
the play button turns green and enlarges slightly to indicate it's
playing. tapping it while playing stops all audio for this card
- Example 2 auto-plays after a short delay with a visual cue showing it is
  playing of turning green. similarly after playing can be tapped to
play again
- If the user taps Continue before audio finishes, stop playback gracefully
- If the device is muted, show a visual indication (speaker icon with slash) so user knows audio was attempted

### No scoring on this card

The intro card does not feed into SRS. It's purely presentational. User cannot "fail" it.

## Outro card

Shown after the user has completed the practice sequence for a word.

### Contents

- The Lao word in large, readable script with a play button next to it
- The IPA / romanization below it
- The English definition
- The part-of-speech tag (e.g., "noun", "verb")
- The associated image
- The example1 in lao with a play button next to it
- The translation in the user's l18n locale language for example
- The example 2 in lao with a play button next to it
- The translation in the user's l18n locale language for example2
- A "Flag to deck" action (icon button) — opens deck picker (see Phase 06)
- A "Next" button to advance to the next card in the lesson

### Behavior

- Auto-play the headword audio on card reveal
- The two other play buttons are on-demand — they do not auto-play
- Flag-to-deck opens a sheet/modal with the user's existing decks + a "Create new deck" option (Phase 06 implements this)
- "Next" button is always available (user can skip any time)

### No scoring

Like the intro card, the outro is presentational. The scoring happens in the practice cards.

## Card component architecture

Design these as reusable components that can be driven by data. The intro and outro are data-different but structurally similar — both show word + image + audio + metadata. Don't duplicate code.

Suggested structure:

```
WordCardBase (shared)
├── WordDisplay (lao script, romanization)
├── WordMetadata (gloss, part of speech)
├── WordImage
├── AudioPlayer (reusable)
└── ActionRow (buttons, varies per card type)

IntroCard = WordCardBase + auto-play-sequence + continue-button
OutroCard = WordCardBase + on-demand-play + flag-button + next-button
```

## Audio player

Build a small audio player abstraction. Responsibilities:

- Play an audio file from the bundled path
- Queue multiple files to play in sequence (for intro's auto-play chain)
- Handle interruption (user taps away, another card starts)
- Respect device mute state
- Report playback state (playing, stopped, error) to the card for UI feedback

### Audio file reference

Audio paths in the content are relative (e.g., `audio/w_0001_word.wav`). The audio player resolves these against the app bundle's content directory.

Support `.wav` at minimum. If the app's existing audio system prefers another format, the content pipeline can re-encode — flag this with the user.

## Tests (write these first)

1. Intro card renders with correct word, gloss, and image
2. Intro card auto-plays headword audio on mount
3. Intro card auto-plays example 1 audio after headword audio completes
4. Intro card does NOT auto-play example 2 audio
5. Intro card "Continue" button stops audio playback and advances
6. Outro card renders with correct word and all three audio buttons
7. Outro card auto-plays only headword audio on mount
8. Outro card's three play buttons each play the correct audio
9. Outro card's "Flag to deck" button invokes flag flow (can be stubbed until Phase 06)
10. Outro card's "Next" button advances to next card in lesson
11. Muted device state is detected and shown visually
12. Audio player stops cleanly when card is unmounted mid-playback

Use mocked audio in tests — don't actually play sound in the test environment.

## UI/UX notes (not strict requirements)

- Keep the intro card and outro card visually distinct so the user knows where they are in the flow. Intro = "meet the word," Outro = "you've got it, confirm."
- Tap-to-replay on the image or the Lao script is a nice affordance (tap the word → replay audio).
- "Flag to deck" icon should be recognizable. A bookmark or heart works; avoid ambiguous icons.

## Done when

- Both card types render correctly in isolation and in the lesson flow
- Audio auto-plays and on-demand-plays work as specified
- Flag button has a stubbed action (real implementation in Phase 06)
- All tests pass
- `DECISIONS.md` notes audio format choice, any card-variant decisions

## Open questions to flag

- **Transition animation** between cards? Default: simple slide or fade. Not critical for v1.
- **Accessibility.** Screen reader support for the card contents (word, gloss, image description). Build this in from the start — don't retrofit.
- **Landscape vs portrait.** Assume portrait-only, don't design for landscape
