UX Fixes — Write Lao

Make a plan and check off each. Use TDD and ensure all tests pass.

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

