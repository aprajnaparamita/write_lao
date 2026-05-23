import 'dart:math';
import 'dart:ui' show Rect;
import '../../data/models/stroke_data.dart';
import 'dtw.dart';
import 'matching_result.dart';
import 'path_utils.dart';
import 'point_resampler.dart';

class StrokeMatcher {
  final PointResampler _resampler = PointResampler();
  final double _canvasSize;

  static const int resamplePointCount = 48;

  /// DTW similarity must reach this value to be "correct".
  /// Raised from 0.50 → 0.75 so that rough/wrong strokes (~0.67) are rejected.
  static const double similarityThreshold = 0.75;

  static const double distanceToleranceFraction = 0.12;
  static const double minPathLengthFraction = 0.05;
  static const double directionToleranceDegrees = 90.0;
  static const double positionToleranceFraction = 0.40;

  /// If the reference has significant extent along an axis (> this fraction of
  /// canvas size), the drawn stroke must cover at least [minExtentFraction] of
  /// that extent — prevents a flat line from matching a curved/tall stroke.
  static const double significantExtentFraction = 0.08;
  static const double minExtentFraction = 0.20;

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

    // Detect circular strokes early — used in Steps 3 and 7.
    // For a closed/near-closed path the start→end direction vector is nearly
    // zero and can point anywhere, so the direction check is meaningless and
    // must be skipped.
    // We key off refIsCircular only: when the reference is a circle, we use
    // rotation-invariant DTW regardless of whether the drawn stroke is detected
    // as circular — users often draw open loops (circle + tail) that fail the
    // circularity test even though they are correctly tracing a circular glyph.
    final refIsCircular = _isCircularStroke(refResampled);

    // Step 3: Check direction.
    // Skipped whenever the reference is circular because the start→end vector
    // is ~0 and its angle depends on where the user began the circle, not on
    // stroke direction. Rotation-invariant DTW (Step 7) handles alignment.
    final bool directionCorrect;
    final bool reversedDirectionCorrect;
    final List<Point<double>> reversedDrawn;
    if (refIsCircular) {
      directionCorrect         = true;
      reversedDirectionCorrect = false;
      reversedDrawn            = const [];
    } else {
      directionCorrect = PathUtils.isSameDirection(
        drawnResampled,
        refResampled,
        toleranceDegrees: directionToleranceDegrees,
      );
      reversedDrawn = drawnResampled.reversed.toList();
      reversedDirectionCorrect = PathUtils.isSameDirection(
        reversedDrawn,
        refResampled,
        toleranceDegrees: directionToleranceDegrees,
      );
    }

    // Step 4: Check position
    final drawnCentroid = PathUtils.centroid(drawnResampled);
    final refCentroid = PathUtils.centroid(refResampled);
    final centroidOffset = PathUtils.distance(drawnCentroid, refCentroid);
    final positionCorrect =
        centroidOffset <= positionToleranceFraction * _canvasSize;

    // Step 5: Bounding-box extent check (before normalization, in canvas coords).
    // Prevents a flat horizontal/vertical line from passing a complex curved stroke.
    final drawnBB = PathUtils.boundingBox(drawnResampled);
    final refBB   = PathUtils.boundingBox(refResampled);
    if (!_extentsConsistent(drawnBB, refBB)) {
      return const StrokeEvaluation(
        result: StrokeMatchResult.wrongShape,
        similarity: 0.0,
        distanceScore: 1.0,
        directionCorrect: false,
        positionCorrect: false,
      );
    }

    // Step 6: Normalize for comparison
    final drawnNorm =
        PathUtils.scaleToFit(PathUtils.centerOnOrigin(drawnResampled), 1.0);
    final refNorm =
        PathUtils.scaleToFit(PathUtils.centerOnOrigin(refResampled), 1.0);

    // Step 7: Compute DTW distance.
    // When the reference is a circular glyph the drawn sequence may be
    // phase-shifted (different starting angle, or an open loop with a tail).
    // Standard DTW punishes this heavily, so we try 8 rotational offsets and
    // keep the best (lowest) distance whenever the reference is circular.
    final dtwDist = refIsCircular
        ? _rotationInvariantDTW(drawnNorm, refNorm)
        : DTW.distance(drawnNorm, refNorm);

    // Step 8: Compute similarity
    final similarity = (1.0 - dtwDist.clamp(0.0, 1.0));

    // Step 9: Decision
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

  /// Returns true if the drawn bounding box has sufficient extent along every
  /// axis where the reference bounding box is "significant".
  bool _extentsConsistent(Rect drawn, Rect ref) {
    final threshold = _canvasSize * significantExtentFraction;
    if (ref.width  > threshold && drawn.width  < ref.width  * minExtentFraction) return false;
    if (ref.height > threshold && drawn.height < ref.height * minExtentFraction) return false;
    return true;
  }

  /// Returns true when the stroke is approximately circular — i.e. the gap
  /// between start and end is small relative to the diagonal of the bounding
  /// box AND the bounding box is roughly square (aspect ratio 0.4 – 2.5).
  ///
  /// Used to trigger rotation-invariant DTW matching so that a user who
  /// begins their circle at a different angular position still scores well.
  bool _isCircularStroke(List<Point<double>> resampled) {
    if (resampled.length < 4) return false;
    final bb = PathUtils.boundingBox(resampled);
    final diagonal = sqrt(bb.width * bb.width + bb.height * bb.height);
    if (diagonal < 1e-9) return false;
    final gap = PathUtils.distance(resampled.first, resampled.last);
    final aspectRatio = bb.width == 0 ? 1.0 : bb.height / bb.width;
    // Gap < 40% of diagonal  AND  aspect ratio between 0.4 and 2.5
    return gap < diagonal * 0.40 && aspectRatio > 0.40 && aspectRatio < 2.50;
  }

  /// DTW distance using the best rotational offset of [drawn] against [ref].
  ///
  /// Tries 8 evenly-spaced phase shifts (0°, 45°, 90°, … 315°) and returns
  /// the minimum DTW distance found.  This makes circular-stroke matching
  /// independent of the starting angle the user chose.
  double _rotationInvariantDTW(
    List<Point<double>> drawn,
    List<Point<double>> ref,
  ) {
    final n = drawn.length;
    var best = double.infinity;
    for (var k = 0; k < 8; k++) {
      final offset = (n * k / 8).round() % n;
      final rotated = <Point<double>>[
        ...drawn.sublist(offset),
        ...drawn.sublist(0, offset),
      ];
      final d = DTW.distance(rotated, ref);
      if (d < best) best = d;
    }
    return best;
  }
}
