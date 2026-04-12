import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';

void main() {
  group('PracticeController', () {
    late ProviderContainer container;
    late CharacterRepository charRepo;
    late PracticeController controller;

    setUp(() {
      charRepo = CharacterRepository();
      container = ProviderContainer(
        overrides: [
          characterRepositoryProvider.overrideWithValue(charRepo),
        ],
      );
      controller = container.read(practiceControllerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has no lesson', () {
      final state = container.read(practiceControllerProvider);
      expect(state.currentLesson, isNull);
      expect(state.currentCharacter, isNull);
      expect(state.currentCharacterIndex, 0);
      expect(state.isCharacterComplete, isFalse);
      expect(state.practicedCharacters, isEmpty);
    });

    test('setLesson loads first character of lesson', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);

      final state = container.read(practiceControllerProvider);
      expect(state.currentLesson, equals(firstLesson));
      expect(state.currentCharacter, isNotNull);
      expect(state.currentCharacterIndex, 0);
      expect(state.isCharacterComplete, isFalse);
      expect(state.practicedCharacters, isEmpty);
    });

    test('nextCharacter advances to next character', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);
      expect(container.read(practiceControllerProvider).currentCharacterIndex, 0);

      controller.nextCharacter();
      final state = container.read(practiceControllerProvider);
      expect(state.currentCharacterIndex, 1);
    });

    test('previousCharacter goes back to previous character', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);
      controller.nextCharacter(); // Now at index 1
      expect(container.read(practiceControllerProvider).currentCharacterIndex, 1);

      controller.previousCharacter();
      final state = container.read(practiceControllerProvider);
      expect(state.currentCharacterIndex, 0);
    });

    test('previousCharacter does not go below 0', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);

      controller.previousCharacter();
      final state = container.read(practiceControllerProvider);
      expect(state.currentCharacterIndex, 0);
    });

    test('nextCharacter stops at last character', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;
      final totalChars = firstLesson.characterCodepoints.length;

      controller.setLesson(firstLesson);

      // Navigate to last character
      for (var i = 0; i < totalChars + 5; i++) {
        controller.nextCharacter();
      }

      final state = container.read(practiceControllerProvider);
      expect(state.currentCharacterIndex, lessThan(totalChars));
    });

    test('onCharacterComplete adds to practiced set', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);
      expect(container.read(practiceControllerProvider).practicedCharacters, isEmpty);

      controller.onCharacterComplete();
      final state = container.read(practiceControllerProvider);
      expect(state.practicedCharacters.length, 1);
      expect(state.isCharacterComplete, isTrue);
    });

    test('canProceedToTest is true when all characters practiced', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);

      // Practice all characters
      for (var i = 0; i < firstLesson.characterCodepoints.length; i++) {
        controller.onCharacterComplete();
        if (!container.read(practiceControllerProvider).isLastCharacter) {
          controller.nextCharacter();
        }
      }

      final state = container.read(practiceControllerProvider);
      expect(state.canProceedToTest, isTrue);
    });

    test('reset returns to initial state with same lesson', () {
      final lessons = charRepo.getAllLessons();
      final firstLesson = lessons.first;

      controller.setLesson(firstLesson);
      controller.onCharacterComplete();
      controller.nextCharacter();

      controller.reset();

      final state = container.read(practiceControllerProvider);
      expect(state.currentLesson, equals(firstLesson));
      expect(state.currentCharacterIndex, 0);
      expect(state.isCharacterComplete, isFalse);
      expect(state.practicedCharacters, isEmpty);
    });
  });
}
