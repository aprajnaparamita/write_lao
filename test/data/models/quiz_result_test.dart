import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/quiz_result.dart';

void main() {
  group('CharacterAttempt', () {
    test('JSON roundtrip', () {
      const original = CharacterAttempt(
        codepoint: 'U+0E81',
        correct: true,
        attemptsNeeded: 1,
        timeMs: 3000,
      );

      final json = original.toJson();
      final restored = CharacterAttempt.fromJson(json);
      expect(restored, original);
    });
  });

  group('QuizResult', () {
    test('can be constructed with all fields', () {
      final now = DateTime(2026, 1, 15);
      final result = QuizResult(
        lessonId: 'consonants_1',
        totalCharacters: 3,
        correctCharacters: 3,
        totalTimeMs: 25000,
        stars: 3,
        completedAt: now,
        attempts: const [
          CharacterAttempt(
            codepoint: 'U+0E81',
            correct: true,
            attemptsNeeded: 1,
            timeMs: 8000,
          ),
          CharacterAttempt(
            codepoint: 'U+0E82',
            correct: true,
            attemptsNeeded: 2,
            timeMs: 10000,
          ),
          CharacterAttempt(
            codepoint: 'U+0E84',
            correct: true,
            attemptsNeeded: 1,
            timeMs: 7000,
          ),
        ],
      );

      expect(result.lessonId, 'consonants_1');
      expect(result.totalCharacters, 3);
      expect(result.stars, 3);
      expect(result.attempts.length, 3);
    });

    test('JSON roundtrip', () {
      final now = DateTime(2026, 1, 15);
      final original = QuizResult(
        lessonId: 'consonants_1',
        totalCharacters: 3,
        correctCharacters: 2,
        totalTimeMs: 30000,
        stars: 1,
        completedAt: now,
        attempts: const [
          CharacterAttempt(
            codepoint: 'U+0E81',
            correct: true,
            attemptsNeeded: 1,
            timeMs: 10000,
          ),
          CharacterAttempt(
            codepoint: 'U+0E82',
            correct: true,
            attemptsNeeded: 3,
            timeMs: 15000,
          ),
          CharacterAttempt(
            codepoint: 'U+0E84',
            correct: false,
            attemptsNeeded: 4,
            timeMs: 5000,
          ),
        ],
      );

      final json = original.toJson();
      final restored = QuizResult.fromJson(json);

      expect(restored.lessonId, original.lessonId);
      expect(restored.totalCharacters, original.totalCharacters);
      expect(restored.correctCharacters, original.correctCharacters);
      expect(restored.stars, original.stars);
      expect(restored.attempts.length, 3);
      expect(restored.attempts[2].correct, false);
    });
  });
}
