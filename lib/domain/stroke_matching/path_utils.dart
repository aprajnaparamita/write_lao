import 'dart:math';
import 'dart:ui' show Rect;

class PathUtils {
  /// Euclidean distance between two points.
  static double distance(Point<double> a, Point<double> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Angle in degrees from point a to point b.
  /// 0=right, 90=down, 180=left, 270=up (screen coordinates).
  static double angleBetween(Point<double> a, Point<double> b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    var angle = atan2(dy, dx) * 180.0 / pi;
    if (angle < 0) angle += 360.0;
    return angle;
  }

  /// Compute the bounding box of a point list.
  static Rect boundingBox(List<Point<double>> points) {
    if (points.isEmpty) return Rect.zero;
    var minX = points[0].x;
    var maxX = points[0].x;
    var minY = points[0].y;
    var maxY = points[0].y;
    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Compute centroid of a point list.
  static Point<double> centroid(List<Point<double>> points) {
    if (points.isEmpty) return const Point(0, 0);
    var sx = 0.0;
    var sy = 0.0;
    for (final p in points) {
      sx += p.x;
      sy += p.y;
    }
    return Point(sx / points.length, sy / points.length);
  }

  /// Translate points so the centroid is at the origin.
  static List<Point<double>> centerOnOrigin(List<Point<double>> points) {
    if (points.isEmpty) return [];
    final c = centroid(points);
    return points.map((p) => Point(p.x - c.x, p.y - c.y)).toList();
  }

  /// Scale points to fit within a target size, preserving aspect ratio.
  static List<Point<double>> scaleToFit(
      List<Point<double>> points, double targetSize) {
    if (points.isEmpty) return [];
    final bb = boundingBox(points);
    final w = bb.width;
    final h = bb.height;
    if (w == 0 && h == 0) return List.from(points);
    final scale = targetSize / max(w, h);
    return points.map((p) => Point(p.x * scale, p.y * scale)).toList();
  }

  /// Compute the average directed Hausdorff distance from A to B.
  static double averageDirectedHausdorff(
      List<Point<double>> a, List<Point<double>> b) {
    if (a.isEmpty || b.isEmpty) return double.infinity;
    var total = 0.0;
    for (final pa in a) {
      var minDist = double.infinity;
      for (final pb in b) {
        final d = distance(pa, pb);
        if (d < minDist) minDist = d;
      }
      total += minDist;
    }
    return total / a.length;
  }

  /// Compute the symmetric average Hausdorff distance.
  static double averageHausdorffDistance(
      List<Point<double>> a, List<Point<double>> b) {
    return max(averageDirectedHausdorff(a, b), averageDirectedHausdorff(b, a));
  }

  /// Check if point sequence goes in roughly the same direction as reference.
  static bool isSameDirection(
    List<Point<double>> drawn,
    List<Point<double>> reference, {
    double toleranceDegrees = 90,
  }) {
    if (drawn.length < 2 || reference.length < 2) return true;
    final drawnAngle = angleBetween(drawn.first, drawn.last);
    final refAngle = angleBetween(reference.first, reference.last);
    return _angleDifference(drawnAngle, refAngle) <= toleranceDegrees;
  }

  /// Smallest angular difference between two angles in degrees (0-180).
  static double _angleDifference(double a, double b) {
    var diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  /// Public version for testing.
  static double angleDifference(double a, double b) => _angleDifference(a, b);
}
