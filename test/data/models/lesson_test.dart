import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/data/models/lesson.dart';

void main() {
  group('Lesson', () {
    test('can be constructed with all fields', () {
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

    test('JSON serialization roundtrip', () {
      const original = Lesson(
        id: 'consonants_1',
        title: 'Consonants 1',
        phase: 1,
        lessonNumber: 1,
        characterCodepoints: ['U+0E81', 'U+0E82', 'U+0E84'],
      );

      final json = original.toJson();
      final restored = Lesson.fromJson(json);

      expect(restored, original);
    });

    test('empty character list is valid', () {
      const lesson = Lesson(
        id: 'empty_lesson',
        title: 'Empty',
        phase: 1,
        lessonNumber: 99,
        characterCodepoints: [],
      );

      expect(lesson.characterCodepoints, isEmpty);

      final json = lesson.toJson();
      final restored = Lesson.fromJson(json);
      expect(restored.characterCodepoints, isEmpty);
    });

    test('equality works', () {
      const a = Lesson(
        id: 'consonants_1',
        title: 'Consonants 1',
        phase: 1,
        lessonNumber: 1,
        characterCodepoints: ['U+0E81', 'U+0E82', 'U+0E84'],
      );
      const b = Lesson(
        id: 'consonants_1',
        title: 'Consonants 1',
        phase: 1,
        lessonNumber: 1,
        characterCodepoints: ['U+0E81', 'U+0E82', 'U+0E84'],
      );
      expect(a, b);
    });
  });
}
