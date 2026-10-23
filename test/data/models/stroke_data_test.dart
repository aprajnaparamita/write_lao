import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/stroke_data.dart';

void main() {
  group('StrokeData', () {
    test('can be constructed with required fields', () {
      const stroke = StrokeData(
        index: 0,
        points: [[10.0, 20.0], [30.0, 40.0]],
        startAngle: 90.0,
        direction: 'clockwise',
      );

      expect(stroke.index, 0);
      expect(stroke.points.length, 2);
      expect(stroke.startAngle, 90.0);
      expect(stroke.direction, 'clockwise');
    });

    test('direction defaults to empty string', () {
      const stroke = StrokeData(
        index: 0,
        points: [[0.0, 0.0]],
        startAngle: 0.0,
      );
      expect(stroke.direction, '');
    });

    test('pointsAsPoints converts to Point<double> list', () {
      const stroke = StrokeData(
        index: 0,
        points: [[10.0, 20.0], [30.0, 40.0]],
        startAngle: 90.0,
      );
      final pts = stroke.pointsAsPoints;
      expect(pts.length, 2);
      expect(pts[0], const Point<double>(10.0, 20.0));
      expect(pts[1], const Point<double>(30.0, 40.0));
    });

    test('JSON roundtrip', () {
      const original = StrokeData(
        index: 1,
        points: [[100.0, 200.0], [300.0, 400.0], [500.0, 600.0]],
        startAngle: 270.0,
        direction: 'down',
      );

      final json = original.toJson();
      final restored = StrokeData.fromJson(json);

      expect(restored.index, original.index);
      expect(restored.points, original.points);
      expect(restored.startAngle, original.startAngle);
      expect(restored.direction, original.direction);
    });

    test('empty points list', () {
      const stroke = StrokeData(
        index: 0,
        points: [],
        startAngle: 0.0,
      );
      expect(stroke.points, isEmpty);
      expect(stroke.pointsAsPoints, isEmpty);
    });
  });

  group('CharacterStrokeData', () {
    test('can be constructed with required fields', () {
      const data = CharacterStrokeData(
        codepoint: 'U+0E81',
        strokeCount: 2,
        strokes: [],
      );

      expect(data.codepoint, 'U+0E81');
      expect(data.strokeCount, 2);
      expect(data.strokes, isEmpty);
      expect(data.canvasSize, 512); // default
    });

    test('canvasSize defaults to 512', () {
      const data = CharacterStrokeData(
        codepoint: 'U+0E81',
        strokeCount: 0,
        strokes: [],
      );
      expect(data.canvasSize, 512);
    });

    test('custom canvasSize', () {
      const data = CharacterStrokeData(
        codepoint: 'U+0E81',
        strokeCount: 0,
        strokes: [],
        canvasSize: 1024,
      );
      expect(data.canvasSize, 1024);
    });

    test('JSON roundtrip with strokes', () {
      const original = CharacterStrokeData(
        codepoint: 'U+0E81',
        strokeCount: 2,
        strokes: [
          StrokeData(
            index: 0,
            points: [[185.0, 160.0], [183.0, 155.0]],
            startAngle: 270.0,
            direction: 'clockwise',
          ),
          StrokeData(
            index: 1,
            points: [[230.0, 95.0], [232.0, 130.0]],
            startAngle: 180.0,
            direction: 'down',
          ),
        ],
      );

      final json = original.toJson();
      final restored = CharacterStrokeData.fromJson(json);

      expect(restored.codepoint, original.codepoint);
      expect(restored.strokeCount, original.strokeCount);
      expect(restored.strokes.length, 2);
      expect(restored.strokes[0].direction, 'clockwise');
      expect(restored.strokes[1].direction, 'down');
    });

    test('JSON roundtrip with empty strokes', () {
      const original = CharacterStrokeData(
        codepoint: 'U+0E82',
        strokeCount: 0,
        strokes: [],
      );

      final json = original.toJson();
      final restored = CharacterStrokeData.fromJson(json);

      expect(restored, original);
    });
  });
}
