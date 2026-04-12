# Prompt 01 — Project Scaffolding, Data Models & Character Database

## Context

You are building "Write Lao", a Flutter app that teaches Lao script handwriting through stroke-by-stroke practice and testing. Read `00_OVERVIEW.md` for full architecture. This is the first prompt in a TDD series.

## Goal

Set up the Flutter project, define all data models, create the static character database, and write comprehensive unit tests for the models.

## Tasks

### 1. Create Flutter Project

```bash
flutter create --org com.writeitlao --project-name write_it_lao .
```

Remove all default counter app code. Set up the directory structure from `00_OVERVIEW.md`.

### 2. Add Dependencies

Add all dependencies from `00_OVERVIEW.md` to `pubspec.yaml`. Run `flutter pub get`.

### 3. Define Data Models (with Freezed)

Create the following immutable data models using `freezed` + `json_serializable`:

#### `lao_character.dart`
```dart
@freezed
class LaoCharacter with _$LaoCharacter {
  const factory LaoCharacter({
    required String codepoint,    // e.g. "U+0E81"
    required String char,         // e.g. "ກ"
    required String name,         // e.g. "ko"
    required String romanization, // e.g. "k"
    required int phase,           // 1-5
    required int order,           // order within phase
    required String notes,        // e.g. "mid class"
    required int strokeCount,
    String? audioAsset,           // path to audio file, nullable
  }) = _LaoCharacter;

  factory LaoCharacter.fromJson(Map<String, dynamic> json) =>
      _$LaoCharacterFromJson(json);
}
```

#### `stroke_data.dart`
```dart
@freezed
class StrokeData with _$StrokeData {
  const factory StrokeData({
    required int index,                     // 0-based stroke order
    required List<Point<double>> points,    // resampled center-line points
    required double startAngle,             // degrees, direction of first segment
    @Default("") String direction,          // human-readable hint: "clockwise", "down", etc.
  }) = _StrokeData;

  factory StrokeData.fromJson(Map<String, dynamic> json) =>
      _$StrokeDataFromJson(json);
}

@freezed
class CharacterStrokeData with _$CharacterStrokeData {
  const factory CharacterStrokeData({
    required String codepoint,
    required int strokeCount,
    required List<StrokeData> strokes,
    @Default(512) int canvasSize,           // reference coordinate system size
  }) = _CharacterStrokeData;

  factory CharacterStrokeData.fromJson(Map<String, dynamic> json) =>
      _$CharacterStrokeDataFromJson(json);
}
```

#### `lesson.dart`
```dart
@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,                     // e.g. "consonants_1"
    required String title,                  // e.g. "Consonants 1"
    required int phase,
    required int lessonNumber,              // within phase
    required List<String> characterCodepoints, // ordered list of codepoints
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) =>
      _$LessonFromJson(json);
}
```

#### `user_progress.dart`
```dart
@freezed
class CharacterProgress with _$CharacterProgress {
  const factory CharacterProgress({
    required String codepoint,
    @Default(0) int practiceCount,
    @Default(0) int testCorrectCount,
    @Default(0) int testAttemptCount,
    @Default(0) int stars,                  // 0-3
    int? bestTimeMs,                        // best test completion time
    DateTime? lastPracticed,
  }) = _CharacterProgress;

  factory CharacterProgress.fromJson(Map<String, dynamic> json) =>
      _$CharacterProgressFromJson(json);
}

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String lessonId,
    @Default(false) bool isUnlocked,
    @Default(false) bool isCompleted,
    @Default(0) int stars,                  // 0-3, based on test performance
    int? bestTimeMs,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}
```

#### `quiz_result.dart`
```dart
@freezed
class QuizResult with _$QuizResult {
  const factory QuizResult({
    required String lessonId,
    required int totalCharacters,
    required int correctCharacters,
    required int totalTimeMs,
    required int stars,                     // calculated: 1=pass, 2=good, 3=fast+perfect
    required DateTime completedAt,
    required List<CharacterAttempt> attempts,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) =>
      _$QuizResultFromJson(json);
}

@freezed
class CharacterAttempt with _$CharacterAttempt {
  const factory CharacterAttempt({
    required String codepoint,
    required bool correct,
    required int attemptsNeeded,            // how many tries before correct
    required int timeMs,
  }) = _CharacterAttempt;

  factory CharacterAttempt.fromJson(Map<String, dynamic> json) =>
      _$CharacterAttemptFromJson(json);
}
```

### 4. Create Static Character Database

Create `lib/data/lao_characters.dart` containing the full character list. Use this data (from the Ruby script's CHARACTERS array):

```dart
const List<Map<String, dynamic>> kLaoCharacters = [
  // Phase 1 — 27 Basic Consonants
  {"codepoint": "U+0E81", "char": "ກ", "name": "ko", "romanization": "k", "phase": 1, "order": 1, "notes": "mid class", "strokeCount": 2},
  {"codepoint": "U+0E82", "char": "ຂ", "name": "kho sung", "romanization": "kh", "phase": 1, "order": 2, "notes": "high class", "strokeCount": 0},
  // ... (include ALL 58 characters from the Ruby CHARACTERS array)
  // Set strokeCount to 0 for all characters that don't have stroke data yet.
  // Only ກ (U+0E81) has stroke data in the initial version.
];
```

**Important:** The `strokeCount` field should be 0 for characters that don't have authored stroke data yet. The app must handle this gracefully — characters with strokeCount=0 can be displayed but not practiced.

### 5. Create Lesson Definitions

Create `lib/data/lesson_definitions.dart` grouping characters into lessons:

```dart
const List<Map<String, dynamic>> kLessonDefinitions = [
  {
    "id": "consonants_1",
    "title": "Consonants 1",
    "phase": 1,
    "lessonNumber": 1,
    "characterCodepoints": ["U+0E81", "U+0E82", "U+0E84"]
  },
  {
    "id": "consonants_2",
    "title": "Consonants 2",
    "phase": 1,
    "lessonNumber": 2,
    "characterCodepoints": ["U+0E87", "U+0E88", "U+0E8A"]
  },
  // ... define all 21 lessons
];
```

### 6. Create Character Repository

```dart
class CharacterRepository {
  List<LaoCharacter> getAllCharacters();
  LaoCharacter? getCharacter(String codepoint);
  List<LaoCharacter> getCharactersByPhase(int phase);
  List<Lesson> getAllLessons();
  Lesson? getLesson(String lessonId);
  List<LaoCharacter> getCharactersForLesson(String lessonId);
}
```

This loads from the static const data. No async needed.

### 7. Write Tests

Create tests FIRST (TDD), then implement to pass:

#### `test/data/models/lao_character_test.dart`
- Test JSON serialization/deserialization roundtrip
- Test factory construction with all required fields
- Test that optional fields default correctly

#### `test/data/models/stroke_data_test.dart`
- Test JSON roundtrip with point lists
- Test empty strokes list
- Test canvasSize default

#### `test/data/models/lesson_test.dart`
- Test JSON roundtrip
- Test lesson with empty character list (should still work, edge case)

#### `test/data/models/user_progress_test.dart`
- Test default values (0 stars, 0 practice count, etc.)
- Test JSON roundtrip with nullable fields

#### `test/data/repositories/character_repository_test.dart`
- Test `getAllCharacters()` returns 58 characters
- Test `getCharacter("U+0E81")` returns correct character
- Test `getCharacter("U+FFFF")` returns null
- Test `getCharactersByPhase(1)` returns 27 consonants
- Test `getAllLessons()` returns 21 lessons
- Test `getCharactersForLesson("consonants_1")` returns 3 characters in correct order
- Test every lesson's characters exist in the character database (no dangling references)
- Test no duplicate codepoints in the character database
- Test lesson ordering is sequential within each phase

### 8. Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

Ensure all generated files compile and all tests pass.

## Acceptance Criteria

- [ ] Flutter project builds for iOS, Android, and at least one desktop platform
- [ ] All 5 data models defined with Freezed, JSON serialization works
- [ ] Character database contains all 58 Lao characters with correct metadata
- [ ] 21 lessons defined covering all characters
- [ ] CharacterRepository passes all unit tests
- [ ] `flutter test` passes with 0 failures
- [ ] No compiler warnings
