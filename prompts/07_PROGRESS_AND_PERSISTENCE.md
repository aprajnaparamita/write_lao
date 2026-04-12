# Prompt 07 — Progress Tracking, Persistence & Review Mode

## Context

You are building "Write Lao". The full UI flow works (Prompts 01–06). Read `00_OVERVIEW.md` for architecture. This prompt adds data persistence so progress survives app restarts, and builds the Review and Progress screens.

## Goal

Wire up Hive for local persistence, implement the progress tracking service, build the Review and Progress screens.

## Tasks

### 1. Hive Setup

Initialize Hive in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  // Register adapters
  Hive.registerAdapter(CharacterProgressAdapter());
  Hive.registerAdapter(LessonProgressAdapter());
  // Open boxes
  await Hive.openBox<CharacterProgress>('character_progress');
  await Hive.openBox<LessonProgress>('lesson_progress');
  runApp(const WriteItLaoApp());
}
```

Create Hive type adapters for `CharacterProgress` and `LessonProgress`. Since these are Freezed classes, you'll need manual adapters or use `hive_generator`.

### 2. Progress Data Source (`lib/data/datasources/progress_local_datasource.dart`)

```dart
class ProgressLocalDataSource {
  final Box<CharacterProgress> _characterBox;
  final Box<LessonProgress> _lessonBox;

  // Character progress
  CharacterProgress getCharacterProgress(String codepoint);
  void saveCharacterProgress(CharacterProgress progress);
  List<CharacterProgress> getAllCharacterProgress();

  // Lesson progress
  LessonProgress getLessonProgress(String lessonId);
  void saveLessonProgress(LessonProgress progress);
  List<LessonProgress> getAllLessonProgress();

  // Reset
  Future<void> clearAllProgress();
}
```

### 3. Progress Repository (`lib/data/repositories/progress_repository.dart`)

```dart
class ProgressRepository {
  final ProgressLocalDataSource _dataSource;

  // Record a practice session for a character
  void recordPractice(String codepoint);

  // Record a test result
  void recordTestResult(QuizResult result);

  // Get progress for display
  CharacterProgress getCharacterProgress(String codepoint);
  LessonProgress getLessonProgress(String lessonId);

  // Aggregate stats
  int totalLessonsCompleted();
  int totalStarsEarned();
  int maxPossibleStars();  // 3 × total lessons
  List<LaoCharacter> getWeakCharacters(CharacterRepository charRepo, {int limit = 10});

  // Check if lesson is unlocked (previous lesson has ≥1 star)
  bool isLessonUnlocked(String lessonId, CharacterRepository charRepo);
}
```

### 4. Wire Progress Into Existing Screens

Update the following to read/write progress:

- **LessonListScreen:** Show actual stars per lesson, lock unavailable lessons
- **LessonDetailScreen:** Show actual best time and stars
- **TestResultScreen:** Save `QuizResult` via `ProgressRepository.recordTestResult()`
- **PracticeScreen:** Call `ProgressRepository.recordPractice()` on each character completion

Use Riverpod providers:

```dart
@riverpod
ProgressRepository progressRepository(Ref ref) {
  final dataSource = ref.watch(progressLocalDataSourceProvider);
  return ProgressRepository(dataSource);
}
```

### 5. Progress Screen (`lib/presentation/screens/progress_screen.dart`)

```
┌─────────────────────────────┐
│  WRITE IT!   Lao        ⚙️  │
├─────────────────────────────┤
│                             │
│     Lessons Complete        │
│         2 / 21              │  ← Lessons with ≥1 star
│                             │
│     Stars Obtained          │
│         6 / 63              │  ← Total stars / max possible
│                             │
│     ┌───────────────┐       │
│     │               │       │
│     │  🖊️ 🖊️ 🖊️       │       │  ← Decorative pencil illustration
│     │               │       │     (or a simple progress bar/chart)
│     └───────────────┘       │
│                             │
│  Phase Progress:            │
│  Consonants    ████░░░ 4/9  │  ← Per-phase progress bars
│  Vowels        ░░░░░░░ 0/5  │
│  Tone Marks    ░░░░░░░ 0/2  │
│  Numerals      ░░░░░░░ 0/4  │
│  Ligatures     ░░░░░░░ 0/1  │
│                             │
└─────────────────────────────┘
```

### 6. Review Screen (`lib/presentation/screens/review_screen.dart`)

Allows users to select characters for custom review practice.

```
┌─────────────────────────────┐
│  ← Review                   │
├─────────────────────────────┤
│  Select characters to review │
│                             │
│  ☑️ ກ  ☑️ ຂ  ☐ ຄ  ☐ ງ  ... │  ← Grid of toggleable characters
│  ☐ ຈ  ☐ ສ  ☐ ຍ  ☐ ດ  ... │     Only chars with stroke data
│                             │
│  Quick select:              │
│  [Weak characters] [All]    │  ← Preset filters
│  [Phase 1] [Phase 2] ...   │
│                             │
│  ┌─────────────────────┐    │
│  │  Practice Selected   │    │  ← Start review session
│  │      (3 chars)       │    │
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

**Review behavior:**
- User selects characters from a grid
- "Weak characters" auto-selects characters with lowest accuracy
- "Practice Selected" opens the practice screen with the selected characters as an ad-hoc lesson
- Characters without stroke data are shown grayed out and not selectable

### 7. Settings Screen (`lib/presentation/screens/settings_screen.dart`)

Minimal settings for now:

```
┌─────────────────────────────┐
│  ← Settings                 │
├─────────────────────────────┤
│                             │
│  Stroke Tolerance           │
│  ──────●──────              │  ← Slider: forgiving ↔ strict
│  Forgiving    Strict        │
│                             │
│  Sound Effects        [ON]  │  ← Toggle
│  Haptic Feedback      [ON]  │  ← Toggle (mobile only)
│                             │
│  ───────────────────────    │
│                             │
│  [Reset All Progress]       │  ← Destructive action with confirmation
│                             │
│  Version 1.0.0              │
│  © 2026 Write Lao      │
│                             │
└─────────────────────────────┘
```

Store settings in a separate Hive box (`settings`).

The stroke tolerance slider should map to the `similarityThreshold` in `StrokeMatcher`. Range: 0.55 (very forgiving) to 0.85 (strict). Default: 0.70.

### 8. Write Tests

#### `test/data/datasources/progress_local_datasource_test.dart`
- Save and retrieve character progress
- Save and retrieve lesson progress
- Get non-existent progress → returns default (zero) values
- Clear all progress → all data removed
- Update existing progress → overwrites correctly

#### `test/data/repositories/progress_repository_test.dart`
- `recordPractice` increments practice count and sets lastPracticed
- `recordTestResult` updates stars, best time, attempt counts
- `totalLessonsCompleted` counts lessons with ≥1 star
- `totalStarsEarned` sums all lesson stars
- `isLessonUnlocked` returns true for first lesson, checks previous lesson for others
- `getWeakCharacters` returns characters sorted by lowest accuracy

#### Widget Tests
- Progress screen shows correct counts
- Progress screen shows phase progress bars
- Review screen renders character grid
- Review screen "Weak characters" button selects correct characters
- Settings screen slider changes tolerance value
- Settings reset shows confirmation dialog

## Acceptance Criteria

- [ ] Progress persists across app restarts
- [ ] Lesson stars and best times update after completing tests
- [ ] Practice count increments after each character practice
- [ ] Progress screen shows accurate aggregate stats
- [ ] Review screen allows custom character selection
- [ ] Settings screen controls stroke tolerance
- [ ] Reset progress works with confirmation
- [ ] All persistence and repository tests pass
- [ ] All widget tests pass
