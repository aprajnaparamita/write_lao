import 'dart:math';
import 'path_utils.dart';

class PointResampler {
  /// Resample a list of raw points to exactly [targetCount] evenly-spaced points.
  ///
  /// Uses the $1 unistroke recognizer resampling algorithm: walk the input path,
  /// accumulate distance, and whenever the accumulated distance reaches the
  /// target spacing, interpolate a new point and insert it into the working
  /// list so that subsequent distance calculations start from that new point.
  List<Point<double>> resample(List<Point<double>> rawPoints, int targetCount) {
    if (rawPoints.length < 2 || targetCount < 2) return [];

    final totalLen = pathLength(rawPoints);
    if (totalLen == 0) {
      return List.filled(targetCount, rawPoints.first);
    }

    final spacing = totalLen / (targetCount - 1);
    // Work on a mutable copy so we can insert interpolated points.
    final pts = List<Point<double>>.from(rawPoints);
    final result = <Point<double>>[pts.first];
    var D = 0.0;
    var i = 1;

    while (i < pts.length && result.length < targetCount) {
      final d = PathUtils.distance(pts[i - 1], pts[i]);
      if ((D + d) >= spacing) {
        // Interpolate new point on this segment.
        final t = (spacing - D) / d;
        final nx = pts[i - 1].x + t * (pts[i].x - pts[i - 1].x);
        final ny = pts[i - 1].y + t * (pts[i].y - pts[i - 1].y);
        final q = Point<double>(nx, ny);
        result.add(q);
        // Insert q so the next iteration measures from q, not pts[i-1].
        pts.insert(i, q);
        D = 0.0;
      } else {
        D += d;
      }
      i++;
    }

    // Fill remaining with last point if needed (rounding edge case).
    while (result.length < targetCount) {
      result.add(pts.last);
    }

    return result;
  }

  /// Calculate total path length of a point sequence.
  double pathLength(List<Point<double>> points) {
    if (points.length < 2) return 0.0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += PathUtils.distance(points[i - 1], points[i]);
    }
    return total;
  }
}
