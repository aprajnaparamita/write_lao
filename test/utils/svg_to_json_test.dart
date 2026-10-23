import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/utils/svg_parser.dart';
import 'package:write_lao/domain/stroke_matching/point_resampler.dart';

void main() {
  group('SVG to JSON Integration', () {
    late SvgFileParser parser;
    late PointResampler resampler;

    setUp(() {
      parser = SvgFileParser();
      resampler = PointResampler();
    });

    test('processes a simple SVG and produces correct structure', () {
      const svgContent = '''
        <svg data-lao-codepoint="U+0E81" data-lao-char="ເก" data-lao-name="ko" width="512" height="512">
          <g id="strokes">
            <path d="M 100,100 L 200,200" />
            <path d="M 300,300 L 400,100" />
          </g>
        </svg>
      ''';

      // Extract metadata
      final metadata = parser.extractMetadata(svgContent);
      expect(metadata['codepoint'], 'U+0E81');
      expect(metadata['char'], 'ເก');
      expect(metadata['name'], 'ko');

      // Parse strokes
      final rawStrokes = parser.parseFile(svgContent);
      expect(rawStrokes.length, 2);

      // Process first stroke
      final stroke1 = rawStrokes[0];
      expect(stroke1.length, greaterThanOrEqualTo(2));

      // Resample to target count
      final resampled1 = resampler.resample(stroke1, 48);
      expect(resampled1.length, 48);

      // Compute direction - check it returns a valid direction
      final direction1 = computeDirectionHint(resampled1);
      expect(direction1.isNotEmpty, true);
    });

    test('filters out strokes shorter than minimum length', () {
      const minLength = 50.0;

      const svgContent = '''
        <svg>
          <g id="strokes">
            <path d="M 100,100 L 101,101" />  <!-- Very short -->
            <path d="M 0,0 L 200,200" />      <!-- Long enough -->
          </g>
        </svg>
      ''';

      final rawStrokes = parser.parseFile(svgContent);

      // Filter by length
      final filteredStrokes = rawStrokes.where((stroke) {
        return _calculatePathLength(stroke) >= minLength;
      }).toList();

      expect(filteredStrokes.length, 1);
    });

    test('handles the example SVG from lao_svgs directory', () async {
      final file = File('lao_svgs/01_01_ko_U0E81.svg');
      if (!await file.exists()) {
        // Skip test if file doesn't exist
        return;
      }

      final svgContent = await file.readAsString();

      // Should not crash
      final metadata = parser.extractMetadata(svgContent);
      expect(metadata['codepoint'], 'U+0E81');

      // The file has a path outside the strokes group, but parser should handle it
      final strokes = parser.parseFile(svgContent);
      expect(strokes.isNotEmpty, true);

      // Each stroke should have some points
      for (final stroke in strokes) {
        expect(stroke.isNotEmpty, true);
      }
    });

    test('resampling produces correct point count', () {
      final rawPoints = [
        const Point(0.0, 0.0),
        const Point(50.0, 50.0),
        const Point(100.0, 100.0),
        const Point(150.0, 150.0),
        const Point(200.0, 200.0),
      ];

      final resampled48 = resampler.resample(rawPoints, 48);
      expect(resampled48.length, 48);

      final resampled32 = resampler.resample(rawPoints, 32);
      expect(resampled32.length, 32);

      final resampled16 = resampler.resample(rawPoints, 16);
      expect(resampled16.length, 16);
    });

    test('stroke direction hint computation is consistent', () {
      // Straight line down
      final downStroke = List.generate(
        10,
        (i) => Point(100.0, i * 10.0),
      );
      expect(computeDirectionHint(downStroke), 'down');

      // Straight line right
      final rightStroke = List.generate(
        10,
        (i) => Point(i * 10.0, 100.0),
      );
      expect(computeDirectionHint(rightStroke), 'right');

      // Curved stroke - should return a valid direction
      final curvedStroke = [
        const Point(0.0, 0.0),
        const Point(50.0, 25.0),
        const Point(100.0, 75.0),
        const Point(150.0, 150.0),
        const Point(200.0, 250.0),
        const Point(250.0, 300.0),
      ];
      final hint = computeDirectionHint(curvedStroke);
      // Curved stroke should return a valid direction string
      expect(
        [
          'down-left',
          'left',
          'down',
          'up-left',
          'up',
          'up-right',
          'down-right',
          'right',
          'clockwise',
          'counterclockwise'
        ].contains(hint),
        true,
      );
    });
  });
}

double _calculatePathLength(List<Point<double>> points) {
  if (points.length < 2) return 0.0;
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    final dx = points[i].x - points[i - 1].x;
    final dy = points[i].y - points[i - 1].y;
    total += sqrt(dx * dx + dy * dy);
  }
  return total;
}
