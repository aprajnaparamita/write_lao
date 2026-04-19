import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocab_word.freezed.dart';
part 'vocab_word.g.dart';

enum CharacterType {
  @JsonValue('consonant')
  consonant,
  @JsonValue('vowel')
  vowel,
  @JsonValue('tone')
  tone,
}

@freezed
class WordCharacter with _$WordCharacter {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WordCharacter({
    required int position,
    required String character,
    required CharacterType type,
  }) = _WordCharacter;

  factory WordCharacter.fromJson(Map<String, dynamic> json) =>
      _$WordCharacterFromJson(json);
}

@freezed
class WordExample with _$WordExample {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WordExample({
    required String exampleId,
    required String laoScript,
    required String romanization,
    required Map<String, String> translations,
    required String audioPath,
  }) = _WordExample;

  factory WordExample.fromJson(Map<String, dynamic> json) =>
      _$WordExampleFromJson(json);
}

@freezed
class VocabWord with _$VocabWord {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory VocabWord({
    required String wordId,
    required String laoWord,
    required String romanization,
    required Map<String, String> definitions,
    required String partOfSpeech,
    required List<WordCharacter> characters,
    required String imagePath,
    required String audioPath,
    required List<WordExample> examples,
  }) = _VocabWord;

  factory VocabWord.fromJson(Map<String, dynamic> json) =>
      _$VocabWordFromJson(json);
}
