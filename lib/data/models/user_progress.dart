import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class CharacterProgress with _$CharacterProgress {
  const factory CharacterProgress({
    required String codepoint,
    @Default(0) int practiceCount,
    @Default(0) int testCorrectCount,
    @Default(0) int testAttemptCount,
    @Default(0) int stars,
    int? bestTimeMs,
    DateTime? lastPracticed,
  }) = _CharacterProgress;

  factory CharacterProgress.fromJson(Map<String, dynamic> json) =>
      _$CharacterProgressFromJson(json);
}

@freezed
class LessonProgress with _$LessonProgress {
  const factory LessonProgress({
    required String lessonId,
    @Default(false) bool isUnlocked,
    @Default(false) bool isCompleted,
    @Default(0) int stars,
    int? bestTimeMs,
  }) = _LessonProgress;

  factory LessonProgress.fromJson(Map<String, dynamic> json) =>
      _$LessonProgressFromJson(json);
}
