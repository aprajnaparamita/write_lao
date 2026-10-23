import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/quiz_result.dart';
import 'package:write_lao/domain/services/quiz_service.dart';

void main() {
  group('QuizService', () {
    late QuizService quizService;

    setUp(() {
      quizService = QuizService();
    });

    group('calculateStars', () {
      test('returns 3 stars for fast time with no hints', () {
        final stars = quizService.calculateStars(
          totalCharacters: 3,
          hintsUsed: 0,
          totalTimeMs: 20000, // 20 seconds, under 30 seconds (3 * 10)
        );
        expect(stars, 3);
      });

      test('returns 2 stars for slow time with no hints', () {
        final stars = quizService.calculateStars(
          totalCharacters: 3,
          hintsUsed: 0,
          totalTimeMs: 40000, // 40 seconds, over 30 seconds
        );
        expect(stars, 2);
      });

      test('returns 1 star when hints are used', () {
        final stars = quizService.calculateStars(
          totalCharacters: 3,
          hintsUsed: 2,
          totalTimeMs: 10000, // Fast time but with hints
        );
        expect(stars, 1);
      });

      test('returns 1 star regardless of time when hints used', () {
        final stars = quizService.calculateStars(
          totalCharacters: 5,
          hintsUsed: 1,
          totalTimeMs: 5000, // Very fast but with hints
        );
        expect(stars, 1);
      });

      test('boundary condition: exactly at max time gets 3 stars', () {
        final stars = quizService.calculateStars(
          totalCharacters: 3,
          hintsUsed: 0,
          totalTimeMs: 30000, // Exactly 30 seconds
        );
        expect(stars, 3);
      });
    });

    group('createResult', () {
      test('creates QuizResult with correct counts derived from attempts', () {
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
            attemptsNeeded: 2,
            timeMs: 8000,
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
          totalTimeMs: 17000,
        );

        expect(result.lessonId, 'consonants_1');
        expect(result.totalCharacters, 3);
        expect(result.correctCharacters, 3);
        expect(result.totalTimeMs, 17000);
        expect(result.stars, 3); // 3 chars, 0 hints (attempts > 1 is not counted as hint), under 30s
        expect(result.attempts.length, 3);
      });

      test('creates QuizResult with stars derived correctly', () {
        final attempts = [
          const CharacterAttempt(
            codepoint: 'U+0E81',
            correct: true,
            attemptsNeeded: 3, // Multiple attempts = hint used
            timeMs: 5000,
          ),
          const CharacterAttempt(
            codepoint: 'U+0E82',
            correct: true,
            attemptsNeeded: 1,
            timeMs: 5000,
          ),
        ];

        final result = quizService.createResult(
          lessonId: 'test_lesson',
          attempts: attempts,
          totalTimeMs: 10000,
          hintsUsed: 1,
        );

        expect(result.lessonId, 'test_lesson');
        expect(result.stars, 1); // Hint was used
      });
    });
  });
}
