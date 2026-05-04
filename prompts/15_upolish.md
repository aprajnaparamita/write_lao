UX Fixes — Write It Lao

Make a plan and check off each.

---
Prompt 1 — Navigation & Wayfinding

▎ Problem: The vocab section and writing practice section feel like two separate apps stitched together. The
▎ vocab tile is buried in the lessons list with no visual distinction. Once inside vocab, the bottom nav
▎ disappears entirely, leaving users with only a back arrow. AppBars show generic titles ("Lessons",
▎ "Vocabulary") with no context about where in the hierarchy the user is.
▎
▎ Implement the following:
▎ 1. Replace the single-tile entry on the home screen with a tabbed layout at the top of LessonListScreen — two
▎ tabs: "Writing" (current lessons) and "Vocabulary". This makes both sections equally discoverable at the top
▎ level.
▎ 2. Add a subtitle to the vocab lesson list AppBar showing the unit name (e.g., "Unit 1 · Greetings" instead of
▎ just "Lessons"). Pass unit.title into LessonListScreen and display it as AppBar(title: ..., bottom: ...) or as
▎ a subtitle row.
▎ 3. Add a subtitle to the vocab practice screen AppBar showing the lesson number within the unit (e.g., "Lesson
▎ 2 of 5") alongside the existing "X / Y cards" counter.
▎ 4. On the UnitListScreen, rename the AppBar from "Vocabulary" to "Vocabulary · 500 Words" or add the mastered
▎ counter as a subtitle rather than as a separate text widget inside the body — it currently reads awkwardly as a
▎  floating label above the list.

---
Prompt 2 — "What's Next" Guidance

▎ Problem: After completing any action (vocab lesson, writing test, practice), the user is shown multiple
▎ equal-weight buttons with no guidance on what to do next. The progress screen shows stats but gives no
▎ recommendation. First-time users on the home screen have no signpost for where to begin.
▎
▎ Implement the following:
▎ 1. On LessonCompleteScreen: below the Continue button, add a small text preview of the next lesson if one
▎ exists — e.g., "Next: Lesson 3 — ສະ ບາຍ ດີ". Derive this by querying the lesson engine for the next unstarted
▎ lesson in the unit.
▎ 2. On TestResultScreen: change the three-button layout to a primary action (highlighted FilledButton) and
▎ secondary actions (outlined). The primary should be "Next Lesson" if the test passed, or "Practice Again" if
▎ they scored 1 star. Move "Main Menu" to a small text button at the bottom.
▎ 3. On ProgressScreen: add a "Suggested Next" card below the phase bars. Show the first incomplete lesson with a
▎  direct "Start" button that navigates to /lessons/{lessonId}. If all lessons are complete, show a "Review Weak
▎ Characters" card instead.
▎ 4. On the home screen (LessonListScreen), visually highlight the lesson the user should do next — add a colored
▎  left border or a "▶ Continue" chip to the current lesson card rather than all lessons appearing visually
▎ equal.

---
Prompt 3 — Free vs. Paid Visual Clarity

▎ Problem: Unit 1 is now free, but nothing on screen communicates this. Users see the unit list and can't tell
▎ what they get for free vs. what requires purchase. The lock icon on unit 2 provides no context about what
▎ unlocking would give them.
▎
▎ Implement the following:
▎ 1. On UnitListScreen, add a small "FREE" badge (a colored Chip widget) to unit 1's trailing area alongside or
▎ replacing the current progress text. Style it in green. For locked units (unit 2+), add a word count hint to
▎ the subtitle: e.g., change description to show "25 words · Unlock required" in muted text.
▎ 2. On LessonListScreen (vocab), if the unit is unit 1 and IAP is not purchased, add a banner at the top of the
▎ lesson list: a single-line card reading "Unit 1 is free — no purchase needed" with a dismiss button. Store the
▎ dismiss state in a Hive preference so it doesn't re-appear.
▎ 3. On UpsellScreen, add a "What's included in unit 1 (free)" and "What you unlock with purchase" two-column
▎ comparison section above the feature bullets. This gives users concrete context for the value proposition
▎ rather than abstract features.

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

---
Prompt 5 — Writing Practice Screen Polish

▎ Problem: The practice and test screens have several small friction points: the hint button is not discoverable
▎ (no label, just an icon), the "Next" button on practice has no visual weight distinction from the other action
▎ buttons, the instruction text ("Trace the character") is small and easily missed, and the progress counter is
▎ positioned in the AppBar where users rarely look during writing.
▎
▎ Implement the following:
▎ 1. Move the "X / Y" character progress indicator from the AppBar to a visible position above the canvas — a
▎ LinearProgressIndicator with a "Character X of Y" label, mirroring the pattern used in
▎ VocabLessonPracticeScreen.
▎ 2. On PracticeScreen and TestScreen, add a text label beneath the hint icon button: "Hint" under the eye icon.
▎ Use Column(children: [Icon(...), Text('Hint', style: caption)]) to make the action self-explanatory.
▎ 3. Give the "Next" button on PracticeScreen FilledButton styling (it currently uses the same style as Clear and
▎  Play buttons) so it reads as the primary action. Disable it with a muted appearance until the character stroke
▎  is accepted rather than hiding it entirely.
▎ 4. On LessonDetailScreen, replace the plain "Content" label + character badge wrap with a mini animated preview
▎  — show each character badge with a small stroke-count indicator below it (e.g., "3 strokes") and a color
▎ indicating whether the user has practiced it before (grey = new, green = practiced). This gives users a better
▎ preview of what a lesson contains before committing to it.

---
These five prompts are independent and can be implemented in any order. Prompts 1 and 2 have the most structural
impact; Prompts 3–5 are more targeted and lower risk.
