UX Fixes — Write Lao

Make a plan and check off each. Use TDD and ensure all tests pass.

---
Prompt 4 — Vocab Lesson Flow Polish

▎ Problem: The three-phase card flow (intro → practice → outro) is invisible to the user — the progress bar just
▎ shows "X / Y" without indicating card type, so users don't know if they're about to write a character or hear a
▎  word. The hear-identify cards appear without warning, which can be disorienting. The outro card is essentially
▎  identical visually to the intro card, causing confusion about whether the lesson has advanced.
▎
▎ Implement the following:
▎ 1. Add a pill label below the progress bar in VocabLessonPracticeScreen that shows the current card type:
▎ "Listen", "Write", or "Review" — mapping to intro, practice/hear-identify, and outro phases respectively. Use a
▎  small AnimatedSwitcher so it fades when the type changes.
▎ 2. On HearIdentifyCard, add a brief "Listen and choose" instruction label at the top of the card before the
▎ grid of options. Currently the card just shows four images with no explanation of the task.
▎ 3. Visually differentiate OutroCard from IntroCard — change the outro card's action button from plain "Next" to
▎  "Got it →" and add a subtle background tint (e.g., Colors.green.shade50) so users perceive the outro as a
▎ confirmation step, not a repeat of the intro.
▎ 4. On LessonCompleteScreen, replace the plain checkmark with the word count and a breakdown: "You practiced 5
▎ words · 2 errors". Make the encouragement message larger and more prominent, and reduce the vertical padding so
▎  the Continue button is visible without scrolling on small screens.

