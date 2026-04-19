import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocab_unit.freezed.dart';
part 'vocab_unit.g.dart';

@freezed
class VocabUnit with _$VocabUnit {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VocabUnit({
    required String unitId,
    required int unitNumber,
    required String title,
    required String description,
    required List<String> lessonIds,
  }) = _VocabUnit;

  factory VocabUnit.fromJson(Map<String, dynamic> json) =>
      _$VocabUnitFromJson(json);
}
