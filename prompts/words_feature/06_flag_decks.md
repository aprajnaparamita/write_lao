# Phase 06 — Flag Decks (Personal Study Decks)

**Depends on:** `01`, `02`, `03`

## Objective

Implement user-created decks of flagged words for personal extra-review. The schema was defined in Phase 01; this phase implements the UI and the study-from-deck flow.

## Data model (recap from Phase 01)

- `flag_deck` — a named collection
- `flag_deck_word` — join table between decks and words

One word can be in multiple decks. No deck size limit (v1).

## User actions

### From the outro card (Phase 03)

- Tap the flag icon
- Sheet/modal opens showing the user's existing decks plus "Create new deck"
- User picks one or more decks (multi-select is fine)
- Action is idempotent: re-flagging a word that's already in the deck is a no-op
- If the user creates a new deck here, it's added to the list and the word is flagged to it

### From a dedicated "My Decks" screen

- User can view their list of decks
- Create new deck, rename deck, delete deck
- View deck contents (list of words)
- Remove individual words from a deck
- Start a study session for a deck (see below)

## Study-from-deck flow

This is a separate entry point from the unit/lesson flow. Purpose: extra practice on flagged words without affecting normal course progression.

### Session contents

When a user starts a deck study:

- Pull all words in the deck
- Order: words with oldest `last_reviewed_at` first; words never reviewed first
- Present them as standard cards (intro → practice/test → outro)
- Use the same SRS logic — this is a real review, it updates user_word state

### Session size

- Default: 10 cards per deck study session
- If the deck has fewer than 10 words, use all of them
- If the deck has more than 10, pick 10 based on ordering above
- User can tap "study more" at the end to pull the next 10

### Mode choice

For deck study, the card mode (practice vs test) follows the same rule as regular lessons:
- If `status in ('new', 'learning')` → practice
- If `status in ('reviewing', 'mature')` → test

Retired words can be in flagged decks but are skipped during deck study (or optionally re-tested — TBD; for v1, skip them).

## UI

### Deck picker (shown from outro card)

```
Flag to deck:
[ ] Tricky words
[ ] Words I keep forgetting
[ ] Favorites
+ Create new deck
```

### My Decks screen

```
My Decks
─────────────────
Tricky words (12 words)       [Study] [...]
Words I keep forgetting (8)    [Study] [...]
Favorites (3)                  [Study] [...]

[+ Create new deck]
```

The "..." menu has Rename / Delete.

### Deck contents screen

A list of words in a deck. Each row shows:
- Lao word
- English gloss
- Small indicator of SRS status (optional, helpful)
- Swipe/tap action to remove from deck

## Tests (write these first)

1. Flag a word to a new deck creates the deck and adds the word
2. Flag the same word twice to the same deck is idempotent (no duplicate row)
3. Flag a word to multiple decks creates rows in each
4. Rename a deck updates its name and `updated_at`
5. Delete a deck removes the deck and its flag_deck_word rows (cascade)
6. Remove a word from a deck removes the flag_deck_word row but not the word from other decks
7. Starting a deck study returns words ordered by `last_reviewed_at` ascending
8. Deck study session pulls up to 10 cards
9. Deck study with retired words skips them (for v1)
10. Completing cards in deck study updates SRS state for those words
11. Completing cards in deck study does NOT advance course progress (current_lesson_id unchanged)

## Done when

- Flag decks can be created, viewed, and studied
- Flagging from the outro card works end-to-end
- Deck study sessions run independently of course progression
- All tests pass
- `DECISIONS.md` notes decisions about retired words and session size

## Open questions to flag

- **Default deck.** Should there be a default "Favorites" deck that always exists, or does the user create their first deck manually? v1: user creates manually. Simpler.
- **Deck size cap.** Is there a limit? Probably not necessary for v1. Very large decks just paginate in the UI.
- **Reorder decks in the list.** Nice-to-have. Alphabetical or by creation date for v1.
- **Export deck.** v2 feature. Skip for v1.
