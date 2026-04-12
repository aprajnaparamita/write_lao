import 'dart:math';
import '../../data/models/stroke_data.dart';
import 'dtw.dart';
import 'matching_result.dart';
import 'path_utils.dart';
import 'point_resampler.dart';

class StrokeMatcher {
  final PointResampler _resampler = PointResampler();
  final double _canvasSize;

  static const int resamplePointCount = 48;
  static const double similarityThreshold = 0.70;
  static const double distanceToleranceFraction = 0.12;
  static const double minPathLengthFraction = 0.05;
  static const double directionToleranceDegrees = 90.0;
  static const double positionToleranceFraction = 0.25;

  StrokeMatcher({double canvasSize = 512.0}) : _canvasSize = canvasSize;

  /// Compare a user-drawn stroke against the expected reference stroke.
  StrokeEvaluation evaluate(
    List<Point<double>> drawnPoints,
    StrokeData referenceStroke,
  ) {
    final refPoints = referenceStroke.pointsAsPoints;

    // Step 1: Filter short paths
    final drawnLength = _resampler.pathLength(drawnPoints);
    if (drawnLength < minPathLengthFraction * _canvasSize) {
      return const StrokeEvaluation(
        result: StrokeMatchResult.tooShort,
        similarity: 0.0,
        distanceScore: 1.0,
        directionCorrect: false,
        positionCorrect: false,
      );
    }

    // Step 2: Resample both
    final drawnResampled =
        _resampler.resample(List.from(drawnPoints), resamplePointCount);
    final refResampled =
        _resampler.resample(List.from(refPoints), resamplePointCount);

    if (drawnResampled.isEmpty || refResampled.isEmpty) {
      return const StrokeEvaluation(
        result: StrokeMatchResult.wrongShape,
        similarity: 0.0,
        distanceScore: 1.0,
        directionCorrect: false,
        positionCorrect: false,
      );
    }

    // Step 3: Check direction
    final directionCorrect = PathUtils.isSameDirection(
      drawnResampled,
      refResampled,
      toleranceDegrees: directionToleranceDegrees,
    );

    // Check if reversed direction matches
    final reversedDrawn = drawnResampled.reversed.toList();
    final reversedDirectionCorrect = PathUtils.isSameDirection(
      reversedDrawn,
      refResampled,
      toleranceDegrees: directionToleranceDegrees,
    );

    // Step 4: Check position
    final drawnCentroid = PathUtils.centroid(drawnResampled);
    final refCentroid = PathUtils.centroid(refResampled);
    final centroidOffset = PathUtils.distance(drawnCentroid, refCentroid);
    final positionCorrect =
        centroidOffset <= positionToleranceFraction * _canvasSize;

    // Step 5: Normalize for comparison
    final drawnNorm =
        PathUtils.scaleToFit(PathUtils.centerOnOrigin(drawnResampled), 1.0);
    final refNorm =
        PathUtils.scaleToFit(PathUtils.centerOnOrigin(refResampled), 1.0);

    // Step 6: Compute DTW distance
    final dtwDist = DTW.distance(drawnNorm, refNorm);

    // Step 7: Compute similarity
    final similarity = (1.0 - dtwDist.clamp(0.0, 1.0));

    // Step 8: Decision
    StrokeMatchResult result;
    if (similarity >= similarityThreshold) {
      if (!directionCorrect && reversedDirectionCorrect) {
        result = StrokeMatchResult.wrongDirection;
      } else if (!positionCorrect) {
        result = StrokeMatchResult.wrongPosition;
      } else {
        result = StrokeMatchResult.correct;
      }
    } else {
      // Even with low shape similarity, check if it's a direction issue
      if (!directionCorrect && reversedDirectionCorrect) {
        // Try matching with reversed points
        final reversedNorm =
            PathUtils.scaleToFit(PathUtils.centerOnOrigin(reversedDrawn), 1.0);
        final reversedDtwDist = DTW.distance(reversedNorm, refNorm);
        final reversedSimilarity = 1.0 - reversedDtwDist.clamp(0.0, 1.0);
        if (reversedSimilarity >= similarityThreshold) {
          result = StrokeMatchResult.wrongDirection;
        } else {
          result = StrokeMatchResult.wrongShape;
        }
      } else {
        result = StrokeMatchResult.wrongShape;
      }
    }

    return StrokeEvaluation(
      result: result,
      similarity: similarity,
      distanceScore: dtwDist,
      directionCorrect: directionCorrect,
      positionCorrect: positionCorrect,
    );
  }
}
