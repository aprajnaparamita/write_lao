import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocab_lesson.freezed.dart';
part 'vocab_lesson.g.dart';

@freezed
class VocabLesson with _$VocabLesson {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VocabLesson({
    required String lessonId,
    required String unitId,
    required int lessonNumber,
    required List<String> newWordIds,
    @Default(<String>[]) List<String> reviewWordIds,
  }) = _VocabLesson;

  factory VocabLesson.fromJson(Map<String, dynamic> json) =>
      _$VocabLessonFromJson(json);
}
