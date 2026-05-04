UX Fixes — Write It Lao

Make a plan and check off each. Use TDD and ensure all tests pass.

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

