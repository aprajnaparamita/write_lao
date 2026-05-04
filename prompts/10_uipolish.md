UX Fixes — Write It Lao

Make a plan and check off each. Use TDD and ensure all tests pass.

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

