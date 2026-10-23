UX Fixes — Write Lao

Make a plan and check off each. Use TDD and ensure all tests pass.

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

