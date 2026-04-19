import 'package:freezed_annotation/freezed_annotation.dart';
import 'vocab_lesson.dart';
import 'vocab_unit.dart';
import 'vocab_word.dart';

part 'course_content.freezed.dart';
part 'course_content.g.dart';

@freezed
class CourseContent with _$CourseContent {
  @JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
  const factory CourseContent({
    required String version,
    required String language,
    required String targetAudience,
    required List<VocabUnit> units,
    required List<VocabLesson> lessons,
    required List<VocabWord> words,
  }) = _CourseContent;

  factory CourseContent.fromJson(Map<String, dynamic> json) =>
      _$CourseContentFromJson(json);
}
