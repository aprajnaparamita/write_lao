import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke_data.freezed.dart';
part 'stroke_data.g.dart';

@freezed
class StrokeData with _$StrokeData {
  const factory StrokeData({
    required int index,
    required List<List<double>> points,
    required double startAngle,
    @Default("") String direction,
  }) = _StrokeData;

  const StrokeData._();

  List<Point<double>> get pointsAsPoints =>
      points.map((p) => Point<double>(p[0], p[1])).toList();

  factory StrokeData.fromJson(Map<String, dynamic> json) =>
      _$StrokeDataFromJson(json);
}

@Freezed(toJson: true, fromJson: true)
class CharacterStrokeData with _$CharacterStrokeData {
  const factory CharacterStrokeData({
    required String codepoint,
    @Default("") String char,
    required int strokeCount,
    required List<StrokeData> strokes,
    @Default(512) int canvasSize,
  }) = _CharacterStrokeData;

  factory CharacterStrokeData.fromJson(Map<String, dynamic> json) =>
      _$CharacterStrokeDataFromJson(json);
}
