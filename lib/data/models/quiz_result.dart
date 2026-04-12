import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'quiz_result.freezed.dart';
part 'quiz_result.g.dart';

@freezed
class QuizResult with _$QuizResult {
  @JsonSerializable(explicitToJson: true)
  const factory QuizResult({
    required String lessonId,
    required int totalCharacters,
    required int correctCharacters,
    required int totalTimeMs,
    required int stars,
    required DateTime completedAt,
    required List<CharacterAttempt> attempts,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) =>
      _$QuizResultFromJson(json);
}

@freezed
class CharacterAttempt with _$CharacterAttempt {
  const factory CharacterAttempt({
    required String codepoint,
    required bool correct,
    required int attemptsNeeded,
    required int timeMs,
  }) = _CharacterAttempt;

  factory CharacterAttempt.fromJson(Map<String, dynamic> json) =>
      _$CharacterAttemptFromJson(json);
}
