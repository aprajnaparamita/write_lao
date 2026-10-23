import 'dart:math';
import 'dart:ui' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/domain/stroke_matching/path_utils.dart';

void main() {
  group('PathUtils.distance', () {
    test('distance between (0,0) and (3,4) is 5.0', () {
      expect(
        PathUtils.distance(
            const Point(0.0, 0.0), const Point(3.0, 4.0)),
        closeTo(5.0, 0.001),
      );
    });

    test('distance between same point is 0', () {
      expect(
        PathUtils.distance(
            const Point(5.0, 5.0), const Point(5.0, 5.0)),
        0.0,
      );
    });
  });

  group('PathUtils.angleBetween', () {
    test('(0,0) to (1,0) is 0 degrees (right)', () {
      expect(
        PathUtils.angleBetween(
            const Point(0.0, 0.0), const Point(1.0, 0.0)),
        closeTo(0.0, 0.001),
      );
    });

    test('(0,0) to (0,1) is 90 degrees (down)', () {
      expect(
        PathUtils.angleBetween(
            const Point(0.0, 0.0), const Point(0.0, 1.0)),
        closeTo(90.0, 0.001),
      );
    });

    test('(0,0) to (-1,0) is 180 degrees (left)', () {
      expect(
        PathUtils.angleBetween(
            const Point(0.0, 0.0), const Point(-1.0, 0.0)),
        closeTo(180.0, 0.001),
      );
    });

    test('(0,0) to (0,-1) is 270 degrees (up)', () {
      expect(
        PathUtils.angleBetween(
            const Point(0.0, 0.0), const Point(0.0, -1.0)),
        closeTo(270.0, 0.001),
      );
    });
  });

  group('PathUtils.boundingBox', () {
    test('bounding box of known points', () {
      final points = [
        const Point<double>(10.0, 20.0),
        const Point<double>(50.0, 5.0),
        const Point<double>(30.0, 40.0),
      ];
      final bb = PathUtils.boundingBox(points);
      expect(bb.left, 10.0);
      expect(bb.top, 5.0);
      expect(bb.right, 50.0);
      expect(bb.bottom, 40.0);
    });

    test('bounding box of empty list', () {
      expect(PathUtils.boundingBox([]), Rect.zero);
    });

    test('bounding box of single point', () {
      final bb =
          PathUtils.boundingBox([const Point<double>(5.0, 5.0)]);
      expect(bb.width, 0.0);
      expect(bb.height, 0.0);
    });
  });

  group('PathUtils.centerOnOrigin', () {
    test('centroid is at origin after centering', () {
      final points = [
        const Point<double>(10.0, 10.0),
        const Point<double>(20.0, 10.0),
        const Point<double>(15.0, 20.0),
      ];
      final centered = PathUtils.centerOnOrigin(points);
      final c = PathUtils.centroid(centered);
      expect(c.x, closeTo(0.0, 0.001));
      expect(c.y, closeTo(0.0, 0.001));
    });

    test('empty list returns empty', () {
      expect(PathUtils.centerOnOrigin([]), isEmpty);
    });
  });

  group('PathUtils.scaleToFit', () {
    test('bounding box fits within target size', () {
      final points = [
        const Point<double>(0.0, 0.0),
        const Point<double>(100.0, 0.0),
        const Point<double>(100.0, 50.0),
      ];
      final scaled = PathUtils.scaleToFit(points, 1.0);
      final bb = PathUtils.boundingBox(scaled);
      expect(bb.width, closeTo(1.0, 0.001));
      expect(bb.height, closeTo(0.5, 0.001));
    });

    test('empty list returns empty', () {
      expect(PathUtils.scaleToFit([], 1.0), isEmpty);
    });
  });

  group('PathUtils.averageHausdorffDistance', () {
    test('identical point sets have distance 0', () {
      final points = [
        const Point<double>(0.0, 0.0),
        const Point<double>(10.0, 0.0),
        const Point<double>(10.0, 10.0),
      ];
      expect(PathUtils.averageHausdorffDistance(points, points),
          closeTo(0.0, 0.001));
    });

    test('shifted point sets have expected distance', () {
      final a = [
        const Point<double>(0.0, 0.0),
        const Point<double>(10.0, 0.0),
      ];
      final b = [
        const Point<double>(5.0, 0.0),
        const Point<double>(15.0, 0.0),
      ];
      // Each point in a: closest in b is 5 away → avg 5
      // Each point in b: closest in a is 5 away → avg 5
      expect(PathUtils.averageHausdorffDistance(a, b),
          closeTo(5.0, 0.001));
    });
  });

  group('PathUtils.isSameDirection', () {
    test('same-direction paths return true', () {
      final a = [
        const Point<double>(0.0, 0.0),
        const Point<double>(100.0, 0.0),
      ];
      final b = [
        const Point<double>(10.0, 10.0),
        const Point<double>(90.0, 10.0),
      ];
      expect(PathUtils.isSameDirection(a, b), true);
    });

    test('reversed paths return false', () {
      final a = [
        const Point<double>(100.0, 0.0),
        const Point<double>(0.0, 0.0),
      ];
      final b = [
        const Point<double>(0.0, 0.0),
        const Point<double>(100.0, 0.0),
      ];
      expect(PathUtils.isSameDirection(a, b), false);
    });

    test('perpendicular paths return false with tight tolerance', () {
      final a = [
        const Point<double>(0.0, 0.0),
        const Point<double>(100.0, 0.0),
      ];
      final b = [
        const Point<double>(0.0, 0.0),
        const Point<double>(0.0, 100.0),
      ];
      expect(
          PathUtils.isSameDirection(a, b, toleranceDegrees: 45), false);
    });

    test('short sequences default to true', () {
      final a = [const Point<double>(0.0, 0.0)];
      final b = [const Point<double>(100.0, 100.0)];
      expect(PathUtils.isSameDirection(a, b), true);
    });
  });

  group('PathUtils.angleDifference', () {
    test('0 and 360 differ by 0', () {
      expect(PathUtils.angleDifference(0, 360), closeTo(0.0, 0.001));
    });

    test('10 and 350 differ by 20', () {
      expect(PathUtils.angleDifference(10, 350), closeTo(20.0, 0.001));
    });

    test('0 and 180 differ by 180', () {
      expect(PathUtils.angleDifference(0, 180), closeTo(180.0, 0.001));
    });
  });
}
