import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/user_progress.dart';

void main() {
  group('CharacterProgress', () {
    test('default values are zero/null', () {
      const progress = CharacterProgress(codepoint: 'U+0E81');

      expect(progress.practiceCount, 0);
      expect(progress.testCorrectCount, 0);
      expect(progress.testAttemptCount, 0);
      expect(progress.stars, 0);
      expect(progress.bestTimeMs, isNull);
      expect(progress.lastPracticed, isNull);
    });

    test('can set all fields', () {
      final now = DateTime(2026, 1, 15);
      final progress = CharacterProgress(
        codepoint: 'U+0E81',
        practiceCount: 5,
        testCorrectCount: 3,
        testAttemptCount: 4,
        stars: 2,
        bestTimeMs: 5000,
        lastPracticed: now,
      );

      expect(progress.practiceCount, 5);
      expect(progress.testCorrectCount, 3);
      expect(progress.testAttemptCount, 4);
      expect(progress.stars, 2);
      expect(progress.bestTimeMs, 5000);
      expect(progress.lastPracticed, now);
    });

    test('JSON roundtrip with all fields', () {
      final now = DateTime(2026, 1, 15);
      final original = CharacterProgress(
        codepoint: 'U+0E81',
        practiceCount: 5,
        testCorrectCount: 3,
        testAttemptCount: 4,
        stars: 2,
        bestTimeMs: 5000,
        lastPracticed: now,
      );

      final json = original.toJson();
      final restored = CharacterProgress.fromJson(json);

      expect(restored.codepoint, original.codepoint);
      expect(restored.practiceCount, original.practiceCount);
      expect(restored.stars, original.stars);
      expect(restored.bestTimeMs, original.bestTimeMs);
      expect(restored.lastPracticed, original.lastPracticed);
    });

    test('JSON roundtrip with nullable fields as null', () {
      const original = CharacterProgress(codepoint: 'U+0E82');

      final json = original.toJson();
      final restored = CharacterProgress.fromJson(json);

      expect(restored.bestTimeMs, isNull);
      expect(restored.lastPracticed, isNull);
    });

    test('copyWith updates specific fields', () {
      const original = CharacterProgress(
        codepoint: 'U+0E81',
        practiceCount: 1,
      );
      final updated = original.copyWith(practiceCount: 2, stars: 3);
      expect(updated.practiceCount, 2);
      expect(updated.stars, 3);
      expect(updated.codepoint, 'U+0E81');
    });
  });

  group('LessonProgress', () {
    test('default values', () {
      const progress = LessonProgress(lessonId: 'consonants_1');

      expect(progress.isUnlocked, false);
      expect(progress.isCompleted, false);
      expect(progress.stars, 0);
      expect(progress.bestTimeMs, isNull);
    });

    test('JSON roundtrip', () {
      const original = LessonProgress(
        lessonId: 'consonants_1',
        isUnlocked: true,
        isCompleted: true,
        stars: 3,
        bestTimeMs: 25000,
      );

      final json = original.toJson();
      final restored = LessonProgress.fromJson(json);

      expect(restored, original);
    });

    test('JSON roundtrip with null bestTimeMs', () {
      const original = LessonProgress(
        lessonId: 'consonants_2',
        isUnlocked: true,
      );

      final json = original.toJson();
      final restored = LessonProgress.fromJson(json);

      expect(restored.bestTimeMs, isNull);
      expect(restored.isUnlocked, true);
    });
  });
}
