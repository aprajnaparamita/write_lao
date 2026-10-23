import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/repositories/character_repository.dart';

void main() {
  late CharacterRepository repo;

  setUp(() {
    repo = CharacterRepository();
  });

  group('CharacterRepository', () {
    test('getAllCharacters returns 58 characters', () {
      final chars = repo.getAllCharacters();
      expect(chars.length, 58);
    });

    test('getCharacter returns correct character for U+0E81', () {
      final char = repo.getCharacter('U+0E81');
      expect(char, isNotNull);
      expect(char!.char, 'ກ');
      expect(char.name, 'ko');
      expect(char.romanization, 'k');
      expect(char.phase, 1);
      expect(char.order, 1);
      expect(char.strokeCount, 2);
    });

    test('getCharacter returns null for non-existent codepoint', () {
      final char = repo.getCharacter('U+FFFF');
      expect(char, isNull);
    });

    test('getCharactersByPhase(1) returns 27 consonants', () {
      final chars = repo.getCharactersByPhase(1);
      expect(chars.length, 27);
      expect(chars.every((c) => c.phase == 1), true);
    });

    test('getCharactersByPhase(2) returns 15 vowels', () {
      final chars = repo.getCharactersByPhase(2);
      expect(chars.length, 15);
    });

    test('getCharactersByPhase(3) returns 4 tone marks', () {
      final chars = repo.getCharactersByPhase(3);
      expect(chars.length, 4);
    });

    test('getCharactersByPhase(4) returns 10 numerals', () {
      final chars = repo.getCharactersByPhase(4);
      expect(chars.length, 10);
    });

    test('getCharactersByPhase(5) returns 2 ligatures', () {
      final chars = repo.getCharactersByPhase(5);
      expect(chars.length, 2);
    });

    test('getAllLessons returns 21 lessons', () {
      final lessons = repo.getAllLessons();
      expect(lessons.length, 21);
    });

    test('getLesson returns correct lesson', () {
      final lesson = repo.getLesson('consonants_1');
      expect(lesson, isNotNull);
      expect(lesson!.title, 'Consonants 1');
      expect(lesson.phase, 1);
      expect(lesson.characterCodepoints.length, 3);
    });

    test('getLesson returns null for non-existent lesson', () {
      final lesson = repo.getLesson('nonexistent');
      expect(lesson, isNull);
    });

    test('getCharactersForLesson returns correct characters in order', () {
      final chars = repo.getCharactersForLesson('consonants_1');
      expect(chars.length, 3);
      expect(chars[0].codepoint, 'U+0E81');
      expect(chars[1].codepoint, 'U+0E82');
      expect(chars[2].codepoint, 'U+0E84');
    });

    test('getCharactersForLesson returns empty for non-existent lesson', () {
      final chars = repo.getCharactersForLesson('nonexistent');
      expect(chars, isEmpty);
    });

    test('every lesson character exists in the character database', () {
      final lessons = repo.getAllLessons();
      for (final lesson in lessons) {
        for (final codepoint in lesson.characterCodepoints) {
          final char = repo.getCharacter(codepoint);
          expect(char, isNotNull,
              reason:
                  'Character $codepoint in lesson ${lesson.id} not found in database');
        }
      }
    });

    test('no duplicate codepoints in the character database', () {
      final chars = repo.getAllCharacters();
      final codepoints = chars.map((c) => c.codepoint).toSet();
      expect(codepoints.length, chars.length,
          reason: 'Duplicate codepoints found in character database');
    });

    test('lesson ordering is sequential within each phase', () {
      final lessons = repo.getAllLessons();
      final byPhase = <int, List<int>>{};
      for (final lesson in lessons) {
        byPhase.putIfAbsent(lesson.phase, () => []);
        byPhase[lesson.phase]!.add(lesson.lessonNumber);
      }

      for (final entry in byPhase.entries) {
        final numbers = entry.value..sort();
        for (var i = 0; i < numbers.length; i++) {
          expect(numbers[i], i + 1,
              reason:
                  'Phase ${entry.key} lesson numbers should be sequential starting at 1');
        }
      }
    });

    test('all characters are assigned to exactly one lesson', () {
      final lessons = repo.getAllLessons();
      final allCodepoints = <String>[];
      for (final lesson in lessons) {
        allCodepoints.addAll(lesson.characterCodepoints);
      }
      // Check no duplicates in lessons
      final uniqueInLessons = allCodepoints.toSet();
      expect(uniqueInLessons.length, allCodepoints.length,
          reason: 'Some characters appear in multiple lessons');

      // All characters should be covered
      final allChars = repo.getAllCharacters();
      expect(uniqueInLessons.length, allChars.length,
          reason: 'Not all characters are covered by lessons');
    });

    test('phase character counts sum to 58', () {
      var total = 0;
      for (var phase = 1; phase <= 5; phase++) {
        total += repo.getCharactersByPhase(phase).length;
      }
      expect(total, 58);
    });
  });
}
