import 'package:freezed_annotation/freezed_annotation.dart';

part 'matching_result.freezed.dart';

enum StrokeMatchResult {
  correct,
  wrongDirection,
  wrongShape,
  tooShort,
  wrongPosition,
}

@freezed
class StrokeEvaluation with _$StrokeEvaluation {
  const factory StrokeEvaluation({
    required StrokeMatchResult result,
    required double similarity,
    required double distanceScore,
    required bool directionCorrect,
    required bool positionCorrect,
  }) = _StrokeEvaluation;
}
