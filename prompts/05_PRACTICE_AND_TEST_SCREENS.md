# Prompt 05 — Practice Screen & Test Screen

## Context

You are building "Write Lao". Canvas widget and stroke matching are working (Prompts 01–04). Read `00_OVERVIEW.md` for architecture. This prompt builds the two core learning screens.

## Goal

Build the Practice and Test screens — the two modes where users actually write characters.

## Practice Screen

### Layout (Mobile)

```
┌─────────────────────────────┐
│  ← Back        ko           │  ← App bar: character name + romanization
│              consonant       │     and category label
├─────────────────────────────┤
│                             │
│   ┌───────────────────────┐ │
│   │                       │ │
│   │                       │ │
│   │    WritingCanvas       │ │  ← Square canvas, centered
│   │    (practice mode)     │ │
│   │                       │ │
│   │                       │ │
│   └───────────────────────┘ │
│                             │
│   🗑️         🔊         👁️   │  ← Action buttons: clear, audio, show/hide hint
│                             │
│      Trace the character     │  ← Instruction text
│                             │
│   ←  1/3  →                 │  ← Character navigation (prev/next in lesson)
└─────────────────────────────┘
```

### Practice Mode Behavior

1. Canvas starts in practice mode — ghost stroke visible for stroke 1
2. User traces the stroke. On correct: ✓ feedback, ghost for stroke 2 appears
3. On incorrect: ✗ feedback, stroke fades, user retries same stroke
4. After all strokes complete: brief success animation, then either:
   - Auto-advance to next character in lesson (after 1s delay), OR
   - Show "Next" button
5. After all characters in lesson practiced: show "Ready for test?" prompt

### Action Buttons

- **🗑️ Clear:** Erase all drawn strokes, restart from stroke 1
- **🔊 Audio:** Play pronunciation audio (if available). Show disabled state if no audio file.
- **👁️ Show/Hide:** Toggle ghost stroke visibility. In practice mode, ghost starts visible. Tapping hides it for self-testing within practice.

### Navigation

- Swipe left/right or use arrows to move between characters in the lesson
- Changing character resets the canvas
- Show current position: "2/3" (character 2 of 3 in this lesson)

## Test Screen

### Layout (Mobile)

```
┌─────────────────────────────┐
│  ← Back              00:30  │  ← App bar with countdown timer
├─────────────────────────────┤
│           ກ                 │  ← Large character display (what to write)
│          /k/                │     with romanization
│                             │
│   ┌───────────────────────┐ │
│   │                       │ │
│   │    WritingCanvas       │ │  ← Canvas in TEST mode (no guides)
│   │    (test mode)         │ │
│   │                       │ │
│   └───────────────────────┘ │
│                             │
│      Write this character    │
│                             │
│        🗑️ Clear              │  ← Only clear button, no hints
│                             │
└─────────────────────────────┘
```

### Test Mode Behavior

1. Characters from the lesson are presented one at a time
2. Timer counts UP from 00:00 (not countdown)
3. Canvas is in test mode — no ghost strokes, no start indicators
4. Character to write is shown above the canvas as a large rendered glyph
5. User draws from memory
6. On correct: canvas clears, next character appears, brief ✓ flash
7. On incorrect: two options based on attempt count:
   - Attempts 1-2: ✗ flash, canvas clears, user retries
   - Attempt 3+: show "Hint" button that briefly animates the stroke order, then let user retry. This attempt counts against their score.
8. After all characters: show results screen

### Test Results

After completing all characters in the test:

```
┌─────────────────────────────┐
│                             │
│         ⭐ ⭐ ⭐             │  ← Stars (1-3)
│                             │
│       Best Time             │
│        00:30                │
│                             │
│       Content               │
│       ກ ຂ ຄ                │  ← Characters in this lesson
│                             │
│    ┌─────────────────┐      │
│    │    Practice      │      │  ← Back to practice mode
│    └─────────────────┘      │
│    ┌─────────────────┐      │
│    │      Test        │      │  ← Retry test
│    └─────────────────┘      │
│                             │
└─────────────────────────────┘
```

**Star calculation:**
- 1 star: All characters completed (regardless of hints used)
- 2 stars: All characters completed with ≤1 hint total
- 3 stars: All characters completed with 0 hints AND time ≤ (characterCount × 10) seconds

### Quiz Service (`lib/domain/services/quiz_service.dart`)

```dart
class QuizService {
  /// Start a new quiz for a lesson. Returns the sequence of characters.
  List<LaoCharacter> startQuiz(Lesson lesson, CharacterRepository charRepo);

  /// Evaluate whether the quiz result earns stars.
  int calculateStars({
    required int totalCharacters,
    required int totalHintsUsed,
    required int totalTimeMs,
  });

  /// Create a QuizResult from the completed quiz data.
  QuizResult createResult({
    required String lessonId,
    required List<CharacterAttempt> attempts,
    required int totalTimeMs,
  });
}
```

## Practice Controller (`lib/presentation/controllers/practice_controller.dart`)

```dart
@riverpod
class PracticeController extends _$PracticeController {
  // State:
  // - currentLesson: the active Lesson
  // - currentCharacterIndex: which character in the lesson
  // - currentCharacter: LaoCharacter for current index
  // - currentStrokeData: CharacterStrokeData for current character
  // - isCharacterComplete: whether all strokes are done

  void setLesson(Lesson lesson);
  void nextCharacter();
  void previousCharacter();
  void onCharacterComplete();
  bool get isLastCharacter;
  bool get canProceedToTest;  // true if all chars in lesson have been practiced at least once
}
```

## Test Controller (`lib/presentation/controllers/test_controller.dart`)

```dart
@riverpod
class TestController extends _$TestController {
  // State:
  // - lesson: the Lesson being tested
  // - characters: ordered list to test
  // - currentIndex: which character
  // - timer: elapsed time in ms
  // - attempts: list of CharacterAttempt being built
  // - hintsUsed: total hints used
  // - currentAttemptCount: attempts on current character

  void startTest(Lesson lesson);
  void onCharacterCorrect(int timeMs);
  void onCharacterFailed();
  void requestHint();
  bool get isComplete;
  QuizResult? finishTest();
}
```

## Write Tests

### `test/domain/services/quiz_service_test.dart`
- `calculateStars` with 0 hints and fast time → 3 stars
- `calculateStars` with 0 hints and slow time → 2 stars
- `calculateStars` with 2 hints → 1 star
- `createResult` produces correct QuizResult with all fields

### `test/presentation/controllers/practice_controller_test.dart`
- Initial state: first character of lesson
- `nextCharacter` advances index
- `previousCharacter` goes back
- Navigation wraps or clamps at bounds
- `canProceedToTest` logic

### `test/presentation/controllers/test_controller_test.dart`
- `startTest` initializes state correctly
- `onCharacterCorrect` advances to next character
- `onCharacterFailed` increments attempt count
- `requestHint` increments hints used
- `finishTest` produces correct QuizResult
- `isComplete` true when all characters done

### Widget Tests
- Practice screen renders character name and canvas
- Practice screen shows navigation arrows
- Practice screen audio button exists
- Test screen renders timer
- Test screen shows character to write
- Test results screen shows correct star count

## Acceptance Criteria

- [ ] Practice screen shows character with guided tracing
- [ ] Practice screen supports navigation between characters in a lesson
- [ ] Test screen presents characters without guides
- [ ] Timer tracks elapsed time during test
- [ ] Hint system works (shows stroke animation after 3 failed attempts)
- [ ] Star calculation is correct
- [ ] Test results screen shows stars, time, and character list
- [ ] All controller and service tests pass
- [ ] All widget tests pass
