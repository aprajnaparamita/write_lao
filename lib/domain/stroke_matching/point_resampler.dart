import 'dart:math';
import 'path_utils.dart';

class PointResampler {
  /// Resample a list of raw points to exactly [targetCount] evenly-spaced points.
  List<Point<double>> resample(List<Point<double>> rawPoints, int targetCount) {
    if (rawPoints.length < 2 || targetCount < 2) return [];

    final totalLen = pathLength(rawPoints);
    if (totalLen == 0) {
      return List.filled(targetCount, rawPoints.first);
    }

    final spacing = totalLen / (targetCount - 1);
    final result = <Point<double>>[rawPoints.first];
    var currentPos = 0; // Index in rawPoints for the segment start
    var distanceAlongPath = 0.0; // Distance traveled along the path
    var exhausted = false;

    while (result.length < targetCount && !exhausted) {
      final targetDistance = result.length * spacing;
      var placed = false;
      
      // Advance through segments until we reach the target distance
      while (currentPos + 1 < rawPoints.length) {
        final segLen = PathUtils.distance(rawPoints[currentPos], rawPoints[currentPos + 1]);
        
        if (distanceAlongPath + segLen >= targetDistance) {
          // We can place the next point on this segment
          final t = (targetDistance - distanceAlongPath) / segLen;
          final nx = rawPoints[currentPos].x + t * (rawPoints[currentPos + 1].x - rawPoints[currentPos].x);
          final ny = rawPoints[currentPos].y + t * (rawPoints[currentPos + 1].y - rawPoints[currentPos].y);
          result.add(Point<double>(nx, ny));
          // Update position to where we placed the point
          distanceAlongPath = targetDistance;
          placed = true;
          break;
        } else {
          // Move to next segment
          distanceAlongPath += segLen;
          currentPos++;
        }
      }
      
      // If we couldn't place a point, we've exhausted the path
      if (!placed) {
        exhausted = true;
      }
    }

    // Fill remaining with last point if needed
    while (result.length < targetCount) {
      result.add(rawPoints.last);
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
