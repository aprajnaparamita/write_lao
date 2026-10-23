Write Lao — Audit Fix Plan

 Context

 The Write Lao Flutter app was built from 10 prompt files (prompts/00-09). An audit found that prompts 01-03 are
 fully implemented, but prompts 04-09 have bugs, missing wiring, and missing tests. There are 12 compile errors
 (visible via flutter analyze), multiple screens using hardcoded placeholder data instead of real repositories,
 and 11+ missing test files.

 Current state: 152 tests pass, but flutter analyze shows 12 errors and 39 warnings/infos.

 ---
 Phase 1: Fix Compile Errors (12 errors)

 1A. Fix progress_repository.dart — bestTimeMs doesn't exist on QuizResult

 File: lib/data/repositories/progress_repository.dart (lines 47-49)

 The recordTestResult method references result.bestTimeMs but QuizResult (in lib/data/models/quiz_result.dart) has
  totalTimeMs, not bestTimeMs. Fix by using result.totalTimeMs instead:

 // CURRENT (broken):
 bestTimeMs: result.bestTimeMs != null &&
     (current.bestTimeMs == null || result.bestTimeMs! < current.bestTimeMs!)
     ? result.bestTimeMs
     : current.bestTimeMs,

 // FIX TO:
 bestTimeMs: current.bestTimeMs == null || result.totalTimeMs < current.bestTimeMs!
     ? result.totalTimeMs
     : current.bestTimeMs,

 1B. Fix progress_repository.dart — getLessonsByPhase doesn't exist

 File: lib/data/repositories/progress_repository.dart (line 135)
 File: lib/data/repositories/character_repository.dart

 getPhaseProgress() calls _characterRepo.getLessonsByPhase(phase) which doesn't exist on CharacterRepository. Add
 it:

 // Add to CharacterRepository:
 List<Lesson> getLessonsByPhase(int phase) =>
     _lessons.where((l) => l.phase == phase).toList();

 1C. Fix review_screen.dart — LaoCharacter constructors missing required fields

 File: lib/presentation/screens/review_screen.dart (lines 31, 39, 47)

 The hardcoded LaoCharacter constructors are missing required notes and strokeCount parameters. But this entire
 block should be replaced with real data anyway (see Phase 2). For now, add the missing fields:

 const LaoCharacter(
   codepoint: 'U+0E81',
   char: 'ກ',
   name: 'ko',
   romanization: 'k',
   phase: 1,
   order: 1,
   notes: 'mid class',    // ADD
   strokeCount: 2,        // ADD
 ),

 Do this for all 3 LaoCharacter instances (lines 31, 39, 47). But better yet, replace the entire _loadCharacters()
  method with real repository data (Phase 2).

 1D. Fix integration_test/full_lesson_flow_test.dart — same LaoCharacter issue

 File: integration_test/full_lesson_flow_test.dart (line 118)

 Add missing notes and strokeCount fields to the LaoCharacter constructor in the test.

 ---
 Phase 2: Wire Screens to Real Data (Replace Placeholders)

 2A. Initialize Hive in main.dart

 File: lib/main.dart

 Currently Hive is never initialized. The app will crash when any progress operation runs. Fix:

 import 'package:hive_flutter/hive_flutter.dart';
 import 'package:path_provider/path_provider.dart';
 import 'package:write_lao/data/datasources/progress_hive_adapters.dart';
 import 'package:write_lao/data/models/user_progress.dart';

 void main() async {
   WidgetsFlutterBinding.ensureInitialized();

   // Initialize Hive
   final appDir = await getApplicationDocumentsDirectory();
   Hive.init(appDir.path);
   Hive.registerAdapter(CharacterProgressAdapter());
   Hive.registerAdapter(LessonProgressAdapter());
   await Hive.openBox<CharacterProgress>('character_progress');
   await Hive.openBox<LessonProgress>('lesson_progress');

   runApp(const ProviderScope(child: WriteLaoApp()));
 }

 2B. Create proper Riverpod providers

 File: lib/presentation/controllers/practice_controller.dart

 The characterRepositoryProvider currently throws UnimplementedError. Fix it to return a real instance:

 final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
   return CharacterRepository();
 });

 Create providers for the progress system. Either add to an existing file or create a new providers file. Need:

 final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
   final characterBox = Hive.box<CharacterProgress>('character_progress');
   final lessonBox = Hive.box<LessonProgress>('lesson_progress');
   return ProgressLocalDataSource(characterBox: characterBox, lessonBox: lessonBox);
 });

 final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
   final dataSource = ref.watch(progressLocalDataSourceProvider);
   final characterRepo = ref.watch(characterRepositoryProvider);
   return ProgressRepository(dataSource: dataSource, characterRepo: characterRepo);
 });

 final characterStrokeDataSourceProvider = Provider<CharacterStrokeDataSource>((ref) {
   return CharacterStrokeDataSource();
 });

 2C. Wire LessonListScreen to real data

 File: lib/presentation/screens/lesson_list_screen.dart

 Replace _getPlaceholderLessons() with real data from characterRepositoryProvider. The screen should:
 - Get all 21 lessons from CharacterRepository.getAllLessons()
 - Get the first character of each lesson for the preview
 - Get star count from ProgressRepository.getLessonProgress()
 - Show all lessons, not just 3 hardcoded ones

 2D. Wire LessonDetailScreen to real data

 File: lib/presentation/screens/lesson_detail_screen.dart

 Replace the _PlaceholderLesson class and _getPlaceholderLesson() with real data:
 - Get the actual Lesson from CharacterRepository.getLesson(lessonId)
 - Get actual characters from CharacterRepository.getCharactersForLesson(lessonId)
 - Get stars and bestTime from ProgressRepository.getLessonProgress(lessonId)
 - Replace the _CharacterBadge hardcoded switch statement with actual character lookup

 2E. Wire PracticeScreen to load stroke data

 File: lib/presentation/screens/practice_screen.dart

 The _loadStrokeData() method is stubbed (commented out). Fix:
 - Uncomment and implement loading from CharacterStrokeDataSource
 - Call _loadStrokeData() when character changes (in _loadLesson and when navigating)
 - Replace the placeholder lessonByIdProvider with a real provider that uses CharacterRepository.getLesson()
 - Wire the clear button onPressed to actually clear the canvas controller
 - Add an audio button (spec requires it — use AudioPlayerService)

 2F. Wire ProgressScreen to real data

 File: lib/presentation/screens/progress_screen.dart

 Replace hardcoded 0 values:
 - Uncomment provider access (lines 13-14)
 - Use ProgressRepository.totalLessonsCompleted(), totalStarsEarned(), maxPossibleStars()
 - Use ProgressRepository.getPhaseProgress() for each of the 5 phase progress bars

 2G. Wire ReviewScreen to real data

 File: lib/presentation/screens/review_screen.dart

 Replace _loadCharacters() hardcoded list:
 - Load all characters with stroke data from CharacterRepository.getAllCharacters() filtered by those that have
 strokeCount > 0
 - Load weak characters from ProgressRepository.getWeakCharacters()
 - Implement phase filtering logic (the FilterChip onSelected handlers are empty)
 - Fix navigation: uses Navigator.pushNamed('/practice/review') but should use go_router (context.push(...))

 2H. Wire TestResultScreen route to pass real data

 File: lib/config/routes.dart (lines 106-112)

 The test result route hardcodes stars: 0 and characterList: const ['ກ', 'ຂ', 'ຄ']. It should read from the
 TestController state to get actual results.

 2I. Wire SettingsScreen reset to actually clear Hive data

 File: lib/presentation/screens/settings_screen.dart (line 238)

 The reset button calls settingsControllerProvider.resetToDefaults() but doesn't actually clear progress data from
  Hive. It should also call progressRepository.resetAllProgress().

 2J. Fix TestScreen empty clear button and stroke data loading

 File: lib/presentation/screens/test_screen.dart

 - The clear button onPressed (line 189) is empty — wire to canvas controller
 - _startTest() doesn't load the lesson — should call testControllerProvider.notifier.startTest(lesson) with a
 real lesson from the repository
 - The WritingCanvas (line 157) doesn't pass strokeData — need to load it from CharacterStrokeDataSource

 ---
 Phase 3: Fix QuizService API

 3A. Simplify QuizService.calculateStars signature

 File: lib/domain/services/quiz_service.dart

 Remove the extra correctCharacters and stars params that aren't in the spec and create circular logic (stars
 being passed to calculateStars):

 // Change from:
 int calculateStars({
   required int totalCharacters,
   required int correctCharacters,  // REMOVE
   required int stars,              // REMOVE
   required int hintsUsed,
   required int totalTimeMs,
 })

 // Change to:
 int calculateStars({
   required int totalCharacters,
   required int hintsUsed,
   required int totalTimeMs,
 })

 Remove the if (stars > 0) return stars; early-return line.

 3B. Simplify QuizService.createResult signature

 Same file. Remove extra params, calculate stars internally:

 // Change from:
 QuizResult createResult({
   required String lessonId,
   required int totalCharacters,
   required int correctCharacters,
   required int totalTimeMs,
   required int stars,
   required List<CharacterAttempt> attempts,
 })

 // Change to:
 QuizResult createResult({
   required String lessonId,
   required List<CharacterAttempt> attempts,
   required int totalTimeMs,
 })

 Derive totalCharacters and correctCharacters from the attempts list.

 3C. Update TestController._completeTest to match

 File: lib/presentation/controllers/test_controller.dart (lines 141-156)

 Update the calculateStars() and createResult() calls to use the simplified signatures.

 3D. Update integration test to match

 File: integration_test/full_lesson_flow_test.dart

 Update all calculateStars() and createResult() calls to use the new signatures.

 ---
 Phase 4: Add Missing Tests

 Test files to create:

 1. test/domain/services/quiz_service_test.dart
   - calculateStars with 0 hints + fast time → 3 stars
   - calculateStars with 0 hints + slow time → 2 stars
   - calculateStars with hints → 1 star
   - createResult produces correct QuizResult
 2. test/presentation/controllers/practice_controller_test.dart
   - Initial state: first character of lesson
   - nextCharacter advances index
   - previousCharacter goes back
   - Clamps at bounds (doesn't go below 0 or above max)
   - canProceedToTest true when all chars practiced
   - onCharacterComplete adds to practiced set
 3. test/presentation/controllers/test_controller_test.dart
   - startTest initializes state
   - onCharacterCorrect advances
   - onCharacterFailed increments attempt count
   - requestHint increments hints
   - finishTest produces QuizResult
   - isComplete true when all done
 4. test/data/datasources/progress_local_datasource_test.dart
   - Save and retrieve character progress
   - Save and retrieve lesson progress
   - Get non-existent → default values
   - clearAllProgress empties boxes
   - Update existing progress overwrites
 5. test/data/repositories/progress_repository_test.dart
   - recordPractice increments count
   - recordTestResult updates stars/bestTime
   - totalLessonsCompleted counts correctly
   - isLessonUnlocked checks previous lesson
   - getWeakCharacters returns sorted by accuracy
 6. test/presentation/widgets/character_card_test.dart
   - Renders character text
   - Shows star count
   - Lock icon when unavailable
   - Tap fires callback
 7. test/presentation/widgets/star_rating_test.dart
   - 0 stars → 3 gray
   - 2 stars → 2 gold + 1 gray
   - 3 stars → 3 gold
 8. Expand existing test files:
   - test/presentation/controllers/canvas_controller_test.dart — add startStroke/addPoint/endStroke workflow,
 correct stroke advancing, wrong stroke not advancing
   - test/presentation/widgets/writing_canvas_test.dart — add ghost stroke visibility by mode
   - test/presentation/widgets/stroke_animator_test.dart — add onComplete callback test

 ---
 Phase 5: Fix Remaining Issues

 5A. Fix CI/CD YAML syntax error

 File: .github/workflows/ci.yml (lines 80-84)

 The build-android job has a step that combines run: and uses: — that's invalid YAML for GitHub Actions. Split
 into two steps:

       - name: Build APK
         run: flutter build apk --debug
       - name: Upload APK artifact
         uses: actions/upload-artifact@v4
         with:
           name: debug-apk
           path: build/app/outputs/flutter-apk/app-debug.apk

 5B. Fix analyzer warnings

 - lib/presentation/widgets/canvas_painter.dart lines 173, 273, 292: Replace .withOpacity() with
 .withValues(alpha: ...)
 - lib/presentation/screens/test_result_screen.dart line 4: Remove unused import of star_rating.dart
 - Various test files: Remove unused imports and local variables

 5C. Remove the build-web CI job

 The overview (prompt 00) explicitly says "Web is NOT a target." Remove the build-web job from ci.yml.

 ---
 Verification

 After all changes:

 1. flutter analyze — 0 errors, 0 warnings (infos for tool/ prints are OK)
 2. flutter test — all existing 152+ tests pass, new tests pass
 3. flutter run — app launches, shows all 21 lessons (not 3), can navigate to lesson detail with real characters,
 practice loads stroke data for ກ
 4. Progress persists: complete a test → see stars on lesson list → kill and restart → stars still there

 ---
 Files Summary

 ┌───────────────────────────────────────────────────────┬─────────────────────────────────────────────────────┐
 │                         File                          │                       Action                        │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/main.dart                                         │ Add Hive initialization                             │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/data/repositories/character_repository.dart       │ Add getLessonsByPhase()                             │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/data/repositories/progress_repository.dart        │ Fix bestTimeMs → totalTimeMs                        │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/domain/services/quiz_service.dart                 │ Simplify signatures                                 │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/controllers/test_controller.dart     │ Update callers                                      │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/controllers/practice_controller.dart │ Fix characterRepositoryProvider, add other          │
 │                                                       │ providers                                           │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/lesson_list_screen.dart      │ Wire to real data                                   │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/lesson_detail_screen.dart    │ Wire to real data                                   │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/practice_screen.dart         │ Wire stroke loading, fix buttons                    │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/test_screen.dart             │ Wire lesson loading, fix buttons                    │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/progress_screen.dart         │ Wire to real data                                   │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/review_screen.dart           │ Wire to real data, fix constructors                 │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/screens/settings_screen.dart         │ Wire reset to Hive                                  │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/config/routes.dart                                │ Wire test result to real data                       │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ lib/presentation/widgets/canvas_painter.dart          │ Fix deprecation warnings                            │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ .github/workflows/ci.yml                              │ Fix YAML syntax, remove web build                   │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ integration_test/full_lesson_flow_test.dart           │ Fix constructors & signatures                       │
 ├───────────────────────────────────────────────────────┼─────────────────────────────────────────────────────┤
 │ 8+ new test files                                     │ See Phase 4 list                                    │
 └───────────────────────────────────────────────────────┴─────────────────────────────────────────────────────┘

