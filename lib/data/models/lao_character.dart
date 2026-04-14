import 'package:freezed_annotation/freezed_annotation.dart';

part 'lao_character.freezed.dart';
part 'lao_character.g.dart';

@freezed
class LaoCharacter with _$LaoCharacter {
  const LaoCharacter._();

  const factory LaoCharacter({
    required String codepoint,
    required String char,
    required String name,
    required String romanization,
    required int phase,
    required int order,
    required String notes,
    required int strokeCount,
    String? audioAsset,
    String? letterName,
    String? letterNameRomanized,
    String? acrophonicalMeaning,
  }) = _LaoCharacter;

  factory LaoCharacter.fromJson(Map<String, dynamic> json) =>
      _$LaoCharacterFromJson(json);

  /// Whether this character is a combining mark (above/below vowel or tone mark)
  /// that needs a base character to display correctly.
  bool get isCombining {
    if (char.isEmpty) return false;
    final cp = char.codeUnitAt(0);
    // U+0EB4–U+0EBC: combining vowel marks and tua lo
    // U+0EC8–U+0ECB: tone marks
    return (cp >= 0x0EB4 && cp <= 0x0EBC) || (cp >= 0x0EC8 && cp <= 0x0ECB);
  }

  /// Character string for display purposes.
  /// Combining marks are shown with a dotted circle (◌) as the base.
  String get displayChar => isCombining ? '\u25CC$char' : char;
}
