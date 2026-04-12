import 'package:freezed_annotation/freezed_annotation.dart';

part 'lao_character.freezed.dart';
part 'lao_character.g.dart';

@freezed
class LaoCharacter with _$LaoCharacter {
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
  }) = _LaoCharacter;

  factory LaoCharacter.fromJson(Map<String, dynamic> json) =>
      _$LaoCharacterFromJson(json);
}
