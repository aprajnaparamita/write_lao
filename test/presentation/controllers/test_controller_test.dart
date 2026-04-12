import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/controllers/test_controller.dart';

void main() {
  group('TestController', () {
    late ProviderContainer container;
    late CharacterRepository charRepo;

    setUp(() {
      charRepo = CharacterRepository();
      container = ProviderContainer(
        overrides: [
          characterRepositoryProvider.overrideWithValue(charRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no lesson', () {
      final state = container.read(testControllerProvider);
      expect(state.lesson, isNull);
      expect(state.characters, isEmpty);
      expect(state.currentIndex, 0);
      expect(state.elapsedMs, 0);
      expect(state.isComplete, isFalse);
    });

    test('startTest initializes state with lesson characters', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);

      final state = container.read(testControllerProvider);
      expect(state.lesson, equals(firstLesson));
      expect(state.characters.length, equals(firstLesson.characterCodepoints.length));
      expect(state.currentIndex, 0);
      expect(state.elapsedMs, 0);
      expect(state.isComplete, isFalse);
    });

    test('updateTime updates elapsed time', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);
      container.read(testControllerProvider.notifier).updateTime(5000);

      final state = container.read(testControllerProvider);
      expect(state.elapsedMs, 5000);
    });

    test('onCharacterCorrect advances to next character', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);
      expect(container.read(testControllerProvider).currentIndex, 0);

      container.read(testControllerProvider.notifier).onCharacterCorrect(5000);

      final state = container.read(testControllerProvider);
      expect(state.currentIndex, 1);
    });

    test('onCharacterFailed increments attempt count', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);
      expect(container.read(testControllerProvider).currentAttemptCount, 0);

      container.read(testControllerProvider.notifier).onCharacterFailed();

      final state = container.read(testControllerProvider);
      expect(state.currentAttemptCount, 1);
    });

    test('requestHint increments hints and attempts', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);
      expect(container.read(testControllerProvider).hintsUsed, 0);

      container.read(testControllerProvider.notifier).requestHint();

      final state = container.read(testControllerProvider);
      expect(state.hintsUsed, 1);
      expect(state.currentAttemptCount, 1);
    });

    test('isComplete becomes true when all characters done', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;
      final totalChars = firstLesson.characterCodepoints.length;

      container.read(testControllerProvider.notifier).startTest(firstLesson);

      // Complete all characters
      for (var i = 0; i < totalChars; i++) {
        container.read(testControllerProvider.notifier).onCharacterCorrect(5000 * (i + 1));
      }

      final state = container.read(testControllerProvider);
      expect(state.isComplete, isTrue);
      expect(state.result, isNotNull);
    });

    test('finishTest produces QuizResult', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);

      // Complete all characters
      final totalChars = firstLesson.characterCodepoints.length;
      for (var i = 0; i < totalChars; i++) {
        container.read(testControllerProvider.notifier).onCharacterCorrect(1000);
      }

      final result = container.read(testControllerProvider.notifier).finishTest();

      expect(result, isNotNull);
      expect(result!.lessonId, firstLesson.id);
      expect(result.totalCharacters, totalChars);
      expect(result.stars, greaterThanOrEqualTo(1));
    });

    test('reset clears all state', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      container.read(testControllerProvider.notifier).startTest(firstLesson);
      container.read(testControllerProvider.notifier).updateTime(5000);
      container.read(testControllerProvider.notifier).requestHint();
      container.read(testControllerProvider.notifier).onCharacterCorrect(5000);

      container.read(testControllerProvider.notifier).reset();

      final state = container.read(testControllerProvider);
      expect(state.lesson, isNull);
      expect(state.characters, isEmpty);
      expect(state.currentIndex, 0);
      expect(state.elapsedMs, 0);
      expect(state.isComplete, isFalse);
    });
  });
}
