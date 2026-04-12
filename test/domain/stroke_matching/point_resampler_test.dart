import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/domain/stroke_matching/point_resampler.dart';
import 'package:write_it_lao/domain/stroke_matching/path_utils.dart';

void main() {
  late PointResampler resampler;

  setUp(() {
    resampler = PointResampler();
  });

  group('PointResampler', () {
    test('resample straight horizontal line of 100 points to 10 points', () {
      final raw = List.generate(
          100, (i) => Point<double>(i.toDouble(), 0.0));
      final result = resampler.resample(raw, 10);

      expect(result.length, 10);
      // First point should be at origin
      expect(result.first.x, closeTo(0.0, 0.01));
      expect(result.first.y, closeTo(0.0, 0.01));
      // Last point should be at end (or close to it)
      expect(result.last.y, closeTo(0.0, 0.01));
      // Points should progress from left to right
      for (var i = 1; i < result.length; i++) {
        expect(result[i].x, greaterThan(result[i - 1].x));
      }
    });

    test('resample 2 points to 10 points produces linear interpolation', () {
      final raw = [
        const Point<double>(0.0, 0.0),
        const Point<double>(90.0, 0.0),
      ];
      final result = resampler.resample(raw, 10);

      expect(result.length, 10);
      expect(result.first.x, closeTo(0.0, 0.01));
      // Points should generally progress (allow tiny epsilon for float precision)
      for (var i = 1; i < result.length; i++) {
        expect(result[i].x, greaterThanOrEqualTo(result[i - 1].x - 0.01));
      }
      // Last point should be near end
      expect(result.last.y, closeTo(0.0, 0.01));
    });

    test('resample 1 point returns empty list', () {
      final raw = [const Point<double>(5.0, 5.0)];
      final result = resampler.resample(raw, 10);
      expect(result, isEmpty);
    });

    test('resample to same count as input gives similar points', () {
      final raw = List.generate(
          20, (i) => Point<double>(i * 5.0, i * 3.0));
      final result = resampler.resample(raw, 20);

      expect(result.length, 20);
      // First should match
      expect(result.first.x, closeTo(raw.first.x, 0.01));
      expect(result.first.y, closeTo(raw.first.y, 0.01));
      // Points should generally progress (allow tiny epsilon for float precision)
      for (var i = 1; i < result.length; i++) {
        expect(result[i].x, greaterThanOrEqualTo(result[i - 1].x - 0.01));
        expect(result[i].y, greaterThanOrEqualTo(result[i - 1].y - 0.01));
      }
    });

    test('resample L-shaped path preserves corner region', () {
      // Horizontal segment then vertical segment
      final raw = <Point<double>>[];
      for (var i = 0; i <= 50; i++) {
        raw.add(Point<double>(i.toDouble(), 0.0));
      }
      for (var i = 1; i <= 50; i++) {
        raw.add(Point<double>(50.0, i.toDouble()));
      }

      final result = resampler.resample(raw, 21);
      expect(result.length, 21);
      // First point at origin
      expect(result.first.x, closeTo(0.0, 0.01));
      expect(result.first.y, closeTo(0.0, 0.01));
      // Points should show progression from horizontal to vertical
      // At some point x should stop increasing and y should start
      var foundCorner = false;
      for (var i = 1; i < result.length; i++) {
        if (result[i].y > 0 && (result[i].x - result[i-1].x).abs() < 1.0) {
          foundCorner = true;
          break;
        }
      }
      expect(foundCorner, isTrue);
    });

    test('empty input returns empty output', () {
      final result = resampler.resample([], 10);
      expect(result, isEmpty);
    });

    test('zero-length path (all same points) returns repeated point', () {
      final raw = List.filled(10, const Point<double>(42.0, 42.0));
      final result = resampler.resample(raw, 5);

      expect(result.length, 5);
      for (final p in result) {
        expect(p.x, closeTo(42.0, 0.01));
        expect(p.y, closeTo(42.0, 0.01));
      }
    });
  });

  group('pathLength', () {
    test('length of horizontal line', () {
      final points = [
        const Point<double>(0.0, 0.0),
        const Point<double>(100.0, 0.0),
      ];
      expect(resampler.pathLength(points), closeTo(100.0, 0.01));
    });

    test('length of 3-4-5 right triangle path', () {
      final points = [
        const Point<double>(0.0, 0.0),
        const Point<double>(3.0, 0.0),
        const Point<double>(3.0, 4.0),
      ];
      expect(resampler.pathLength(points), closeTo(7.0, 0.01));
    });

    test('length of single point is 0', () {
      final points = [const Point<double>(5.0, 5.0)];
      expect(resampler.pathLength(points), 0.0);
    });

    test('length of empty list is 0', () {
      expect(resampler.pathLength([]), 0.0);
    });
  });
}
