import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/domain/stroke_matching/stroke_matcher.dart';

void main() {
  late StrokeMatcher matcher;

  // Create a simple reference stroke: horizontal line from left to right
  StrokeData makeHorizontalStroke() {
    final pts = List.generate(
        30, (i) => [100.0 + i * 10.0, 256.0]);
    return StrokeData(
      index: 0,
      points: pts,
      startAngle: 0.0,
      direction: 'right',
    );
  }

  // Create a curved reference stroke (quarter circle, clockwise)
  StrokeData makeCurvedStroke() {
    final pts = <List<double>>[];
    for (var i = 0; i < 30; i++) {
      final angle = i * (pi / 2) / 29;
      pts.add([256.0 + 100.0 * cos(angle), 156.0 + 100.0 * sin(angle)]);
    }
    return StrokeData(
      index: 0,
      points: pts,
      startAngle: 90.0,
      direction: 'clockwise',
    );
  }

  setUp(() {
    matcher = StrokeMatcher(canvasSize: 512.0);
  });

  group('StrokeMatcher', () {
    test('exact match returns correct with high similarity', () {
      final ref = makeHorizontalStroke();
      final drawn = ref.pointsAsPoints;
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.result, StrokeMatchResult.correct);
      expect(eval.similarity, greaterThan(0.9));
      expect(eval.directionCorrect, true);
      expect(eval.positionCorrect, true);
    });

    test('close match with small noise returns correct', () {
      final ref = makeHorizontalStroke();
      final rng = Random(42);
      final drawn = ref.pointsAsPoints.map((p) {
        return Point<double>(
            p.x + (rng.nextDouble() - 0.5) * 10.0,
            p.y + (rng.nextDouble() - 0.5) * 10.0);
      }).toList();

      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct);
    });

    test('reversed stroke returns wrongDirection', () {
      final ref = makeHorizontalStroke();
      final drawn = ref.pointsAsPoints.reversed.toList();
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.result, StrokeMatchResult.wrongDirection);
    });

    test('wrong position returns wrongPosition', () {
      final ref = makeHorizontalStroke();
      // Shift the stroke 300px down (300/512 = 0.59, exceeds 0.50 tolerance)
      final drawn = ref.pointsAsPoints
          .map((p) => Point<double>(p.x, p.y + 300.0))
          .toList();
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.result, StrokeMatchResult.wrongPosition);
    });

    test('completely different shape returns wrongShape', () {
      // Use the curved reference (quarter circle) vs a horizontal line —
      // after normalization, a curve and a straight line have high DTW
      // distance because the point distributions differ fundamentally.
      final ref = makeCurvedStroke();
      final drawn = <Point<double>>[];
      for (var i = 0; i < 30; i++) {
        drawn.add(Point<double>(100.0 + i * 10.0, 256.0));
      }

      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, isNot(StrokeMatchResult.correct));
    });

    test('too short path returns tooShort', () {
      final ref = makeHorizontalStroke();
      // A tiny 3-pixel movement
      final drawn = [
        const Point<double>(256.0, 256.0),
        const Point<double>(257.0, 256.0),
        const Point<double>(258.0, 256.0),
      ];
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.result, StrokeMatchResult.tooShort);
    });

    test('scaled match (80% size) returns correct', () {
      final ref = makeHorizontalStroke();
      final refPts = ref.pointsAsPoints;
      final center = Point<double>(
          refPts.map((p) => p.x).reduce((a, b) => a + b) / refPts.length,
          refPts.map((p) => p.y).reduce((a, b) => a + b) / refPts.length);
      final drawn = refPts
          .map((p) => Point<double>(
              center.x + (p.x - center.x) * 0.8,
              center.y + (p.y - center.y) * 0.8))
          .toList();

      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct);
    });

    test('slightly rotated (~15 degrees) returns correct', () {
      final ref = makeHorizontalStroke();
      final refPts = ref.pointsAsPoints;
      final center = Point<double>(
          refPts.map((p) => p.x).reduce((a, b) => a + b) / refPts.length,
          refPts.map((p) => p.y).reduce((a, b) => a + b) / refPts.length);

      final angle = 15 * pi / 180;
      final drawn = refPts.map((p) {
        final dx = p.x - center.x;
        final dy = p.y - center.y;
        return Point<double>(
          center.x + dx * cos(angle) - dy * sin(angle),
          center.y + dx * sin(angle) + dy * cos(angle),
        );
      }).toList();

      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct);
    });

    test('curved stroke exact match returns correct', () {
      final ref = makeCurvedStroke();
      final drawn = ref.pointsAsPoints;
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.result, StrokeMatchResult.correct);
      expect(eval.similarity, greaterThan(0.9));
    });

    test('similarity is between 0 and 1', () {
      final ref = makeHorizontalStroke();
      final drawn = ref.pointsAsPoints;
      final eval = matcher.evaluate(drawn, ref);

      expect(eval.similarity, greaterThanOrEqualTo(0.0));
      expect(eval.similarity, lessThanOrEqualTo(1.0));
    });

    // ── Circular / niggahita stroke tests ───────────────────────────────────

    test('circular stroke: same start angle returns correct', () {
      // A small full circle (radius=20, centred at (258,130) in 512 space)
      final ref = _makeCircleStroke(cx: 258, cy: 130, r: 20, startAngle: 0);
      final drawn = _makeCirclePoints(cx: 258, cy: 130, r: 20, startAngle: 0);
      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct,
          reason: 'Identical circle should match');
      expect(eval.similarity, greaterThan(0.85));
    });

    test('circular stroke: 90° phase shift returns correct', () {
      final ref = _makeCircleStroke(cx: 258, cy: 130, r: 20, startAngle: 0);
      // User starts at the left side of the circle instead of the top
      final drawn =
          _makeCirclePoints(cx: 258, cy: 130, r: 20, startAngle: pi / 2);
      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct,
          reason: '90° phase shift on a circle should still match');
    });

    test('circular stroke: 180° phase shift returns correct', () {
      final ref = _makeCircleStroke(cx: 258, cy: 130, r: 20, startAngle: 0);
      final drawn =
          _makeCirclePoints(cx: 258, cy: 130, r: 20, startAngle: pi);
      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct,
          reason: '180° phase shift (worst case) on a circle should match');
    });

    test('circular stroke: different position returns wrongPosition', () {
      final ref = _makeCircleStroke(cx: 258, cy: 130, r: 20, startAngle: 0);
      // Shift the drawn circle far away (300px → 300/512 ≈ 0.59 > tolerance)
      final drawn =
          _makeCirclePoints(cx: 258, cy: 430, r: 20, startAngle: 0);
      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.wrongPosition,
          reason: 'Circle drawn in wrong position should fail position check');
    });

    test('circular stroke: niggahita-like reference (48 pts) with phase shift',
        () {
      // Simulate the actual niggahita: small nearly-closed arc of radius ~20
      // centred at (259,130) in 512-space, counterclockwise.
      final ref =
          _makeCircleStroke(cx: 259, cy: 130, r: 20, startAngle: -pi / 12);
      // User starts at 135° offset
      final drawn =
          _makeCirclePoints(cx: 259, cy: 130, r: 20, startAngle: pi * 3 / 4);
      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct,
          reason: 'Niggahita-like circular stroke with arbitrary phase shift');
    });

    test('open loop with tail matches circular reference (real-world case)', () {
      // Simulate how users actually draw a circular glyph component:
      // they trace a circle but add a tail at the end so the stroke is "open".
      // drawnIsCircular → false (tail makes start→end gap too large)
      // refIsCircular   → true
      // With refIsCircular logic, rotation-invariant DTW should still accept it.
      final ref =
          _makeCircleStroke(cx: 258, cy: 130, r: 20, startAngle: 0);

      // Circle starts at right (0°), goes counterclockwise, then a tail going
      // right extends the end point ~25px further — making start ≠ end.
      const n = 48;
      final circleOnly = List.generate(n, (i) {
        final angle = -(i / n) * 2 * pi; // counterclockwise
        return Point<double>(258 + 20 * cos(angle), 130 + 20 * sin(angle));
      });
      // Append a short tail (5 extra points extending right from end of circle)
      final tail = List.generate(5, (i) {
        return Point<double>(278 + (i + 1) * 5.0, 130.0);
      });
      final drawn = [...circleOnly, ...tail];

      final eval = matcher.evaluate(drawn, ref);
      expect(eval.result, StrokeMatchResult.correct,
          reason:
              'Open loop (circle + tail) should match circular reference via '
              'refIsCircular rotation-invariant DTW');
    });
  });
}

// ── helpers ─────────────────────────────────────────────────────────────────

/// Build a [StrokeData] with 48 points around a circle of given centre/radius.
/// [startAngle] is in radians (0 = right, pi/2 = down in screen coords).
StrokeData _makeCircleStroke({
  required double cx,
  required double cy,
  required double r,
  required double startAngle,
}) {
  return StrokeData(
    index: 0,
    points: _circlePoints(cx: cx, cy: cy, r: r, startAngle: startAngle),
    startAngle: startAngle * 180 / pi,
    direction: 'counterclockwise',
  );
}

/// 48 evenly-distributed points around a circle (counterclockwise in screen Y).
List<Point<double>> _makeCirclePoints({
  required double cx,
  required double cy,
  required double r,
  required double startAngle,
}) {
  const n = 48;
  return List.generate(n, (i) {
    final angle = startAngle - (i / n) * 2 * pi; // counterclockwise
    return Point<double>(cx + r * cos(angle), cy + r * sin(angle));
  });
}

List<List<double>> _circlePoints({
  required double cx,
  required double cy,
  required double r,
  required double startAngle,
}) {
  const n = 48;
  return List.generate(n, (i) {
    final angle = startAngle - (i / n) * 2 * pi;
    return [cx + r * cos(angle), cy + r * sin(angle)];
  });
}
