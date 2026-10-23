import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/lao_character.dart';
import 'package:write_lao/data/models/lesson.dart';
import 'package:write_lao/data/models/quiz_result.dart';
import 'package:write_lao/domain/services/quiz_service.dart';

void main() {
  group('Full Lesson Flow', () {
    late QuizService quizService;

    setUp(() {
      quizService = QuizService();
    });

    test('quiz service calculates stars correctly for perfect performance', () {
      final stars = quizService.calculateStars(
        totalCharacters: 3,
        hintsUsed: 0,
        totalTimeMs: 25000, // 25 seconds, under 30 seconds (3 * 10)
      );
      expect(stars, 3);
    });

    test('quiz service calculates stars correctly for slow but no hints', () {
      final stars = quizService.calculateStars(
        totalCharacters: 3,
        hintsUsed: 0,
        totalTimeMs: 45000, // 45 seconds, over 30 seconds (3 * 10)
      );
      expect(stars, 2);
    });

    test('quiz service calculates stars correctly when hints used', () {
      final stars = quizService.calculateStars(
        totalCharacters: 3,
        hintsUsed: 2,
        totalTimeMs: 10000,
      );
      expect(stars, 1);
    });

    test('quiz service creates valid QuizResult', () {
      final attempts = [
        const CharacterAttempt(
          codepoint: 'U+0E81',
          correct: true,
          attemptsNeeded: 1,
          timeMs: 5000,
        ),
        const CharacterAttempt(
          codepoint: 'U+0E82',
          correct: true,
          attemptsNeeded: 1,
          timeMs: 6000,
        ),
        const CharacterAttempt(
          codepoint: 'U+0E84',
          correct: true,
          attemptsNeeded: 1,
          timeMs: 4000,
        ),
      ];

      final result = quizService.createResult(
        lessonId: 'consonants_1',
        attempts: attempts,
        totalTimeMs: 15000,
      );

      expect(result.lessonId, 'consonants_1');
      expect(result.totalCharacters, 3);
      expect(result.correctCharacters, 3);
      expect(result.totalTimeMs, 15000);
      expect(result.stars, 3);
      expect(result.attempts.length, 3);
    });
  });

  group('Stroke Matching Integration', () {
    test('character attempt records correct data', () {
      const attempt = CharacterAttempt(
        codepoint: 'U+0E81',
        correct: true,
        attemptsNeeded: 1,
        timeMs: 5000,
      );

      expect(attempt.codepoint, 'U+0E81');
      expect(attempt.correct, true);
      expect(attempt.attemptsNeeded, 1);
      expect(attempt.timeMs, 5000);
    });

    test('character attempt can represent failed attempt', () {
      const attempt = CharacterAttempt(
        codepoint: 'U+0E81',
        correct: false,
        attemptsNeeded: 3,
        timeMs: 10000,
      );

      expect(attempt.correct, false);
      expect(attempt.attemptsNeeded, 3);
    });
  });

  group('Character Data', () {
    test('LaoCharacter has required fields', () {
      const character = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );

      expect(character.codepoint, 'U+0E81');
      expect(character.char, 'ກ');
      expect(character.name, 'ko');
      expect(character.romanization, 'k');
      expect(character.phase, 1);
      expect(character.order, 1);
      expect(character.notes, 'mid class');
      expect(character.strokeCount, 2);
    });

    test('Lesson has correct structure', () {
      const lesson = Lesson(
        id: 'consonants_1',
        title: 'Consonants 1',
        phase: 1,
        lessonNumber: 1,
        characterCodepoints: ['U+0E81', 'U+0E82', 'U+0E84'],
      );

      expect(lesson.id, 'consonants_1');
      expect(lesson.title, 'Consonants 1');
      expect(lesson.phase, 1);
      expect(lesson.lessonNumber, 1);
      expect(lesson.characterCodepoints.length, 3);
    });
  });
}
