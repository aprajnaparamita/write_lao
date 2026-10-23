import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/lao_character.dart';

void main() {
  group('LaoCharacter', () {
    test('can be constructed with all required fields', () {
      const char = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );

      expect(char.codepoint, 'U+0E81');
      expect(char.char, 'ກ');
      expect(char.name, 'ko');
      expect(char.romanization, 'k');
      expect(char.phase, 1);
      expect(char.order, 1);
      expect(char.notes, 'mid class');
      expect(char.strokeCount, 2);
      expect(char.audioAsset, isNull);
    });

    test('optional audioAsset defaults to null', () {
      const char = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );
      expect(char.audioAsset, isNull);
    });

    test('can set audioAsset', () {
      const char = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
        audioAsset: 'audio/ko.mp3',
      );
      expect(char.audioAsset, 'audio/ko.mp3');
    });

    test('JSON serialization roundtrip', () {
      const original = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
        audioAsset: 'audio/ko.mp3',
      );

      final json = original.toJson();
      final restored = LaoCharacter.fromJson(json);

      expect(restored, original);
    });

    test('JSON roundtrip with null audioAsset', () {
      const original = LaoCharacter(
        codepoint: 'U+0E82',
        char: 'ຂ',
        name: 'kho sung',
        romanization: 'kh',
        phase: 1,
        order: 2,
        notes: 'high class',
        strokeCount: 0,
      );

      final json = original.toJson();
      final restored = LaoCharacter.fromJson(json);

      expect(restored, original);
      expect(restored.audioAsset, isNull);
    });

    test('fromJson with map literal', () {
      final char = LaoCharacter.fromJson({
        'codepoint': 'U+0E81',
        'char': 'ກ',
        'name': 'ko',
        'romanization': 'k',
        'phase': 1,
        'order': 1,
        'notes': 'mid class',
        'strokeCount': 2,
      });

      expect(char.codepoint, 'U+0E81');
      expect(char.strokeCount, 2);
    });

    test('equality works', () {
      const a = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );
      const b = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );
      expect(a, b);
    });

    test('copyWith works', () {
      const original = LaoCharacter(
        codepoint: 'U+0E81',
        char: 'ກ',
        name: 'ko',
        romanization: 'k',
        phase: 1,
        order: 1,
        notes: 'mid class',
        strokeCount: 2,
      );
      final modified = original.copyWith(strokeCount: 3);
      expect(modified.strokeCount, 3);
      expect(modified.codepoint, 'U+0E81');
    });
  });
}
