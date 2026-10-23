import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/utils/svg_parser.dart';

void main() {
  group('SvgPathParser', () {
    late SvgPathParser parser;

    setUp(() {
      parser = SvgPathParser();
    });

    test('parses M L commands to form an L shape', () {
      final result = parser.parse('M 0,0 L 100,0 L 100,100');
      expect(result.length, 1);
      expect(result[0].length, 3);

      expect(result[0][0].x, 0);
      expect(result[0][0].y, 0);
      expect(result[0][1].x, 100);
      expect(result[0][1].y, 0);
      expect(result[0][2].x, 100);
      expect(result[0][2].y, 100);
    });

    test('parses cubic bezier curve with sampling', () {
      final result = parser.parse('M 0,0 C 25,0 75,100 100,100', curveResolution: 20);

      expect(result.length, 1);
      // Cubic bezier should sample at least 20 points for the curve
      expect(result[0].length, greaterThanOrEqualTo(20));

      // First point should be near start
      expect(result[0].first.x, closeTo(0, 1));
      expect(result[0].first.y, closeTo(0, 1));

      // Last point should be near end
      expect(result[0].last.x, closeTo(100, 1));
      expect(result[0].last.y, closeTo(100, 1));
    });

    test('parses relative commands m and l', () {
      final result = parser.parse('m 0,0 l 100,0');

      expect(result.length, 1);
      expect(result[0].length, 2);
      expect(result[0][0].x, 0);
      expect(result[0][0].y, 0);
      expect(result[0][1].x, 100);
      expect(result[0][1].y, 0);
    });

    test('parses multiple sub-paths separated by M commands', () {
      final result = parser.parse('M 0,0 L 100,0 M 0,100 L 100,100');

      expect(result.length, 2);
      expect(result[0].length, 2);
      expect(result[1].length, 2);

      // First subpath
      expect(result[0][0].x, 0);
      expect(result[0][0].y, 0);
      expect(result[0][1].x, 100);
      expect(result[0][1].y, 0);

      // Second subpath
      expect(result[1][0].x, 0);
      expect(result[1][0].y, 100);
      expect(result[1][1].x, 100);
      expect(result[1][1].y, 100);
    });

    test('handles implicit lineto after moveto', () {
      // SVG spec: after M, coordinates are treated as L if no command letter
      final result = parser.parse('M 0,0 50,0 100,0');

      expect(result.length, 1);
      expect(result[0].length, 3);
      expect(result[0][1].x, 50);
      expect(result[0][1].y, 0);
    });

    test('parses quadratic bezier Q command', () {
      final result = parser.parse('M 0,0 Q 50,100 100,0', curveResolution: 10);

      expect(result.length, 1);
      expect(result[0].first.x, closeTo(0, 1));
      expect(result[0].first.y, closeTo(0, 1));
      expect(result[0].last.x, closeTo(100, 1));
      expect(result[0].last.y, closeTo(0, 1));
    });

    test('handles closepath Z command', () {
      final result = parser.parse('M 0,0 L 100,0 L 100,100 Z');

      expect(result.length, 1);
      expect(result[0].length, 4);
      // Last point should return to start
      expect(result[0].last.x, closeTo(0, 0.1));
      expect(result[0].last.y, closeTo(0, 0.1));
    });

    test('parses empty string to empty result', () {
      final result = parser.parse('');
      expect(result, isEmpty);
    });

    test('handles path with spaces and commas', () {
      final result = parser.parse('M 0, 0 L 50, 50 L 100, 100');
      expect(result.length, 1);
      expect(result[0].length, 3);
    });

    test('handles negative numbers', () {
      final result = parser.parse('M 100,100 L 50,50 L -50,-50');
      expect(result.length, 1);
      expect(result[0].length, 3);
      expect(result[0][2].x, -50);
      expect(result[0][2].y, -50);
    });
  });

  group('SvgFileParser', () {
    late SvgFileParser parser;

    setUp(() {
      parser = SvgFileParser();
    });

    test('extracts paths from strokes group', () {
      const svg = '''
        <svg>
          <g id="background">
            <rect />
          </g>
          <g id="strokes">
            <path d="M 0,0 L 100,100" />
            <path d="M 50,50 L 150,150" />
          </g>
        </svg>
      ''';

      final result = parser.parseFile(svg);
      expect(result.length, 2);
    });

    test('falls back to all paths when strokes group not found', () {
      const svg = '''
        <svg>
          <g id="other">
            <path d="M 0,0 L 100,100" />
          </g>
          <path d="M 50,50 L 150,150" />
        </svg>
      ''';

      final result = parser.parseFile(svg);
      // When no strokes group found, all paths are included
      // (2 paths in this case: one in "other" group and one root-level)
      expect(result.length, 2);
    });

    test('excludes paths from background, reference, and label groups', () {
      const svg = '''
        <svg>
          <g id="background">
            <path d="M 0,0 L 10,10" />
          </g>
          <g id="reference">
            <path d="M 1,1 L 2,2" />
          </g>
          <g id="label">
            <path d="M 3,3 L 4,4" />
          </g>
          <path d="M 100,100 L 200,200" />
        </svg>
      ''';

      final result = parser.parseFile(svg);
      expect(result.length, 1);
      expect(result[0].first.x, 100);
    });

    test('extracts metadata from data-lao-* attributes', () {
      const svg = '''
        <svg data-lao-char="A" data-lao-codepoint="U+0041" data-lao-name="a">
        </svg>
      ''';

      final metadata = parser.extractMetadata(svg);
      expect(metadata['char'], 'A');
      expect(metadata['codepoint'], 'U+0041');
      expect(metadata['name'], 'a');
    });

    test('handles SVG with no metadata', () {
      const svg = '<svg></svg>';
      final metadata = parser.extractMetadata(svg);
      expect(metadata, isEmpty);
    });

    test('splits path with multiple M commands into separate strokes', () {
      const svg = '''
        <svg>
          <g id="strokes">
            <path d="M 0,0 L 100,0 M 50,50 L 150,50" />
          </g>
        </svg>
      ''';

      final result = parser.parseFile(svg);
      expect(result.length, 2); // Two separate subpaths
    });
  });

  group('computeDirectionHint', () {
    test('returns right for horizontal rightward stroke', () {
      final points = [
        const Point(0.0, 100.0),
        const Point(50.0, 100.0),
        const Point(100.0, 100.0),
      ];
      final hint = computeDirectionHint(points);
      expect(hint, 'right');
    });

    test('returns down for vertical downward stroke', () {
      final points = [
        const Point(100.0, 0.0),
        const Point(100.0, 50.0),
        const Point(100.0, 100.0),
      ];
      final hint = computeDirectionHint(points);
      expect(hint, 'down');
    });

    test('returns left for horizontal leftward stroke', () {
      final points = [
        const Point(100.0, 100.0),
        const Point(50.0, 100.0),
        const Point(0.0, 100.0),
      ];
      final hint = computeDirectionHint(points);
      expect(hint, 'left');
    });

    test('returns up for vertical upward stroke', () {
      final points = [
        const Point(100.0, 100.0),
        const Point(100.0, 50.0),
        const Point(100.0, 0.0),
      ];
      final hint = computeDirectionHint(points);
      expect(hint, 'up');
    });

    test('returns unknown for empty points', () {
      final hint = computeDirectionHint([]);
      expect(hint, 'unknown');
    });

    test('returns unknown for single point', () {
      final hint = computeDirectionHint([const Point(100.0, 100.0)]);
      expect(hint, 'unknown');
    });
  });

  group('computeStartAngle', () {
    test('returns angle for valid stroke', () {
      final points = [
        const Point(0.0, 0.0),
        const Point(100.0, 0.0),
      ];
      final angle = computeStartAngle(points);
      expect(angle, closeTo(0, 1)); // 0 degrees (rightward)
    });

    test('returns 0 for empty points', () {
      final angle = computeStartAngle([]);
      expect(angle, 0);
    });

    test('returns 0 for single point', () {
      final angle = computeStartAngle([const Point(100.0, 100.0)]);
      expect(angle, 0);
    });
  });
}
