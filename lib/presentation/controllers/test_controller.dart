import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_lao/data/models/lao_character.dart';
import 'package:write_lao/data/models/lesson.dart';
import 'package:write_lao/data/models/quiz_result.dart';
import 'package:write_lao/data/repositories/character_repository.dart';
import 'package:write_lao/domain/services/quiz_service.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';

class TestState {
  final Lesson? lesson;
  final List<LaoCharacter> characters;
  final int currentIndex;
  final int elapsedMs;
  final List<CharacterAttempt> attempts;
  final int hintsUsed;
  final int currentAttemptCount;
  final bool isComplete;
  final QuizResult? result;
  final int? earnedStars;

  const TestState({
    this.lesson,
    this.characters = const [],
    this.currentIndex = 0,
    this.elapsedMs = 0,
    this.attempts = const [],
    this.hintsUsed = 0,
    this.currentAttemptCount = 0,
    this.isComplete = false,
    this.result,
    this.earnedStars,
  });

  TestState copyWith({
    Lesson? lesson,
    List<LaoCharacter>? characters,
    int? currentIndex,
    int? elapsedMs,
    List<CharacterAttempt>? attempts,
    int? hintsUsed,
    int? currentAttemptCount,
    bool? isComplete,
    QuizResult? result,
    int? earnedStars,
  }) {
    return TestState(
      lesson: lesson ?? this.lesson,
      characters: characters ?? this.characters,
      currentIndex: currentIndex ?? this.currentIndex,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      attempts: attempts ?? this.attempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      currentAttemptCount: currentAttemptCount ?? this.currentAttemptCount,
      isComplete: isComplete ?? this.isComplete,
      result: result ?? this.result,
      earnedStars: earnedStars ?? this.earnedStars,
    );
  }

  LaoCharacter? get currentCharacter {
    if (currentIndex >= characters.length) return null;
    return characters[currentIndex];
  }

  int get totalCharacters => characters.length;

  String get formattedTime {
    final seconds = (elapsedMs / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class TestController extends StateNotifier<TestState> {
  final CharacterRepository _characterRepo;
  final QuizService _quizService;

  TestController(this._characterRepo, this._quizService) : super(const TestState());

  void startTest(Lesson lesson) {
    final characters = _characterRepo.getCharactersForLesson(lesson.id);

    state = TestState(
      lesson: lesson,
      characters: characters,
      currentIndex: 0,
      elapsedMs: 0,
      attempts: const [],
      hintsUsed: 0,
      currentAttemptCount: 0,
      isComplete: false,
    );
  }

  void updateTime(int elapsedMs) {
    state = state.copyWith(elapsedMs: elapsedMs);
  }

  void onCharacterCorrect(int timeMs) {
    final character = state.currentCharacter;
    if (character == null) return;

    final attempt = CharacterAttempt(
      codepoint: character.codepoint,
      correct: true,
      attemptsNeeded: state.currentAttemptCount + 1,
      timeMs: timeMs,
    );

    final newAttempts = [...state.attempts, attempt];
    final nextIndex = state.currentIndex + 1;

    if (nextIndex >= state.characters.length) {
      // All characters completed
      _completeTest(newAttempts);
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        attempts: newAttempts,
        currentAttemptCount: 0,
      );
    }
  }

  void onCharacterFailed() {
    state = state.copyWith(
      currentAttemptCount: state.currentAttemptCount + 1,
    );
  }

  void requestHint() {
    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      currentAttemptCount: state.currentAttemptCount + 1,
    );
  }

  void _completeTest(List<CharacterAttempt> attempts) {
    final stars = _quizService.calculateStars(
      totalCharacters: state.characters.length,
      hintsUsed: state.hintsUsed,
      totalTimeMs: state.elapsedMs,
    );

    final result = _quizService.createResult(
      lessonId: state.lesson!.id,
      attempts: attempts,
      totalTimeMs: state.elapsedMs,
      hintsUsed: state.hintsUsed,
    );

    state = state.copyWith(
      isComplete: true,
      attempts: attempts,
      result: result,
      earnedStars: stars,
    );
  }

  QuizResult? finishTest() {
    if (!state.isComplete || state.result == null) {
      // If not complete, create partial result
      _completeTest(state.attempts);
    }
    return state.result;
  }

  void reset() {
    state = const TestState();
  }
}

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService();
});

final testControllerProvider = StateNotifierProvider<TestController, TestState>((ref) {
  final characterRepo = ref.watch(characterRepositoryProvider);
  final quizService = ref.watch(quizServiceProvider);
  return TestController(characterRepo, quizService);
});
