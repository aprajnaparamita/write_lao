import 'dart:math';
import 'package:write_lao/domain/stroke_matching/path_utils.dart';

/// Parses SVG path `d` attributes into lists of points.
/// Supports common SVG path commands: M, L, C, S, Q, Z (absolute and relative).
class SvgPathParser {
  /// Parse an SVG path d-attribute string into a list of point lists.
  /// Each sub-path (split at M commands) becomes one list of points.
  /// Bezier curves are sampled at [curveResolution] points per curve segment.
  List<List<Point<double>>> parse(String pathData, {int curveResolution = 20}) {
    if (pathData.isEmpty) return [];

    final commands = _tokenizeCommands(pathData);
    final subPaths = <List<Point<double>>>[];
    var currentPath = <Point<double>>[];
    var currentX = 0.0;
    var currentY = 0.0;
    var startX = 0.0;
    var startY = 0.0;
    var lastControlX = 0.0;
    var lastControlY = 0.0;
    var lastCommand = '';

    for (var i = 0; i < commands.length; i++) {
      final cmd = commands[i];
      final command = cmd['command'] as String;
      final args = cmd['args'] as List<double>;

      final isRelative = command == command.toLowerCase();
      final cmdUpper = command.toUpperCase();

      switch (cmdUpper) {
        case 'M':
          // Start a new sub-path
          for (var j = 0; j < args.length; j += 2) {
            if (j + 1 >= args.length) break;
            var x = args[j];
            var y = args[j + 1];
            if (isRelative) {
              x += currentX;
              y += currentY;
            }

            if (currentPath.isNotEmpty) {
              subPaths.add(currentPath);
              currentPath = <Point<double>>[];
            }

            currentPath.add(Point<double>(x, y));
            currentX = startX = x;
            currentY = startY = y;
            lastControlX = x;
            lastControlY = y;
          }
          break;

        case 'L':
          for (var j = 0; j < args.length; j += 2) {
            if (j + 1 >= args.length) break;
            var x = args[j];
            var y = args[j + 1];
            if (isRelative) {
              x += currentX;
              y += currentY;
            }
            currentPath.add(Point<double>(x, y));
            currentX = x;
            currentY = y;
            lastControlX = x;
            lastControlY = y;
          }
          break;

        case 'H':
          for (final x in args) {
            final px = isRelative ? currentX + x : x;
            currentPath.add(Point<double>(px, currentY));
            currentX = px;
            lastControlX = px;
            lastControlY = currentY;
          }
          break;

        case 'V':
          for (final y in args) {
            final py = isRelative ? currentY + y : y;
            currentPath.add(Point<double>(currentX, py));
            currentY = py;
            lastControlX = currentX;
            lastControlY = py;
          }
          break;

        case 'C':
          for (var j = 0; j < args.length; j += 6) {
            if (j + 5 >= args.length) break;
            var x1 = args[j];
            var y1 = args[j + 1];
            var x2 = args[j + 2];
            var y2 = args[j + 3];
            var x = args[j + 4];
            var y = args[j + 5];
            if (isRelative) {
              x1 += currentX;
              y1 += currentY;
              x2 += currentX;
              y2 += currentY;
              x += currentX;
              y += currentY;
            }

            final samples = _sampleCubicBezier(
              Point<double>(currentX, currentY),
              Point<double>(x1, y1),
              Point<double>(x2, y2),
              Point<double>(x, y),
              curveResolution,
            );
            currentPath.addAll(samples);
            lastControlX = x2;
            lastControlY = y2;
            currentX = x;
            currentY = y;
          }
          break;

        case 'S':
          for (var j = 0; j < args.length; j += 4) {
            if (j + 3 >= args.length) break;
            var x2 = args[j];
            var y2 = args[j + 1];
            var x = args[j + 2];
            var y = args[j + 3];
            if (isRelative) {
              x2 += currentX;
              y2 += currentY;
              x += currentX;
              y += currentY;
            }

            // Implicit control point for S
            var x1 = currentX;
            var y1 = currentY;
            if (cmdUpper == 'S' && (lastCommand == 'C' || lastCommand == 'S')) {
              x1 = 2 * currentX - lastControlX;
              y1 = 2 * currentY - lastControlY;
            }

            final samples = _sampleCubicBezier(
              Point<double>(currentX, currentY),
              Point<double>(x1, y1),
              Point<double>(x2, y2),
              Point<double>(x, y),
              curveResolution,
            );
            currentPath.addAll(samples);
            lastControlX = x2;
            lastControlY = y2;
            currentX = x;
            currentY = y;
          }
          break;

        case 'Q':
          for (var j = 0; j < args.length; j += 4) {
            if (j + 3 >= args.length) break;
            var x1 = args[j];
            var y1 = args[j + 1];
            var x = args[j + 2];
            var y = args[j + 3];
            if (isRelative) {
              x1 += currentX;
              y1 += currentY;
              x += currentX;
              y += currentY;
            }

            final samples = _sampleQuadraticBezier(
              Point<double>(currentX, currentY),
              Point<double>(x1, y1),
              Point<double>(x, y),
              curveResolution,
            );
            currentPath.addAll(samples);
            lastControlX = x1;
            lastControlY = y1;
            currentX = x;
            currentY = y;
          }
          break;

        case 'Z':
          if (currentPath.isNotEmpty &&
              (currentX != startX || currentY != startY)) {
            currentPath.add(Point<double>(startX, startY));
          }
          currentX = startX;
          currentY = startY;
          break;
      }

      lastCommand = cmdUpper;
    }

    if (currentPath.isNotEmpty) {
      subPaths.add(currentPath);
    }

    return subPaths;
  }

  /// Tokenize SVG path string into commands with arguments.
  List<Map<String, dynamic>> _tokenizeCommands(String pathData) {
    final commands = <Map<String, dynamic>>[];

    // Normalize: split on command letters while preserving them
    final normalized = pathData
        .replaceAll(',', ' ')
        .replaceAll('-', ' -')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final pattern = RegExp(r'([MmLlHhVvCcSsQqTtAaZz])|([-+]?[\d.]+)');
    final matches = pattern.allMatches(normalized);

    var i = 0;
    String? lastCommand;
    int? implicitRepeatCount;

    while (i < matches.length) {
      final match = matches.elementAt(i);
      final text = match.group(0)!;

      if (RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(text)) {
        // It's a command
        commands.add({'command': text, 'args': <double>[]});
        lastCommand = text;
        i++;

        // Handle implicit lineto after moveto
        if (text.toUpperCase() == 'M') {
          implicitRepeatCount = 2; // M expects pairs
        }
      } else if (lastCommand != null) {
        // It's a number, add to current command
        final value = double.tryParse(text);
        if (value != null) {
          final currentCmd = commands.last;
          final existingArgs = currentCmd['args'] as List<double>;
          currentCmd['args'] = [...existingArgs, value];

          // Handle implicit repetition for L, C, etc.
          final cmdUpper = lastCommand.toUpperCase();
          if (cmdUpper == 'M') {
            implicitRepeatCount = (implicitRepeatCount ?? 2) - 1;
            if (implicitRepeatCount == 0 && i + 1 < matches.length) {
              final nextMatch = matches.elementAt(i + 1);
              final nextText = nextMatch.group(0)!;
              if (!RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(nextText)) {
                // Switch to L command
                lastCommand = lastCommand == 'M' ? 'L' : 'l';
                commands.add({'command': lastCommand, 'args': <double>[]});
                implicitRepeatCount = 2;
              } else {
                implicitRepeatCount = 2;
              }
            }
          }
          i++;
        } else {
          i++;
        }
      } else {
        // Number without command, skip
        i++;
      }
    }

    return commands;
  }

  /// Sample a cubic Bezier curve with [n] points.
  List<Point<double>> _sampleCubicBezier(
    Point<double> p0,
    Point<double> p1,
    Point<double> p2,
    Point<double> p3,
    int n,
  ) {
    final points = <Point<double>>[];
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      final mt = 1 - t;
      final mt2 = mt * mt;
      final mt3 = mt2 * mt;
      final t2 = t * t;
      final t3 = t2 * t;

      final x = mt3 * p0.x + 3 * mt2 * t * p1.x + 3 * mt * t2 * p2.x + t3 * p3.x;
      final y = mt3 * p0.y + 3 * mt2 * t * p1.y + 3 * mt * t2 * p2.y + t3 * p3.y;
      points.add(Point<double>(x, y));
    }
    return points;
  }

  /// Sample a quadratic Bezier curve with [n] points.
  List<Point<double>> _sampleQuadraticBezier(
    Point<double> p0,
    Point<double> p1,
    Point<double> p2,
    int n,
  ) {
    final points = <Point<double>>[];
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      final mt = 1 - t;

      final x = mt * mt * p0.x + 2 * mt * t * p1.x + t * t * p2.x;
      final y = mt * mt * p0.y + 2 * mt * t * p1.y + t * t * p2.y;
      points.add(Point<double>(x, y));
    }
    return points;
  }
}

/// Parse an SVG file and extract stroke paths.
class SvgFileParser {
  final SvgPathParser _pathParser = SvgPathParser();

  /// Parse a single SVG file and extract stroke paths.
  /// Looks for paths inside `<g id="strokes">`, falls back to any `<path>` elements.
  /// Returns: List of point lists in document order (one per `<path>` element).
  List<List<Point<double>>> parseFile(String svgContent, {int curveResolution = 20}) {
    // Try to find paths inside <g id="strokes">
    var paths = _extractPathsFromGroup(svgContent, 'strokes');

    if (paths.isEmpty) {
      // Fall back to all paths, excluding certain groups
      paths = _extractAllPaths(svgContent);
    }

    final result = <List<Point<double>>>[];
    for (final pathD in paths) {
      final subPaths = _pathParser.parse(pathD, curveResolution: curveResolution);
      result.addAll(subPaths);
    }

    return result;
  }

  /// Extract all paths from a specific group.
  List<String> _extractPathsFromGroup(String svg, String groupId) {
    final paths = <String>[];

    // Match the group
    final groupPattern = RegExp(
      '<g[^>]*id=["\']$groupId["\'][^>]*>([\\s\\S]*?)</g>',
      caseSensitive: false,
    );

    final match = groupPattern.firstMatch(svg);
    if (match != null) {
      final groupContent = match.group(1) ?? '';
      paths.addAll(_extractPathDs(groupContent));
    }

    return paths;
  }

  /// Extract all paths from SVG, excluding certain groups.
  List<String> _extractAllPaths(String svg) {
    // First remove excluded groups
    var content = svg;

    // Remove background, reference, and label groups
    for (final groupId in ['background', 'reference', 'label', 'defs', 'metadata']) {
      content = content.replaceAll(
        RegExp('<g[^>]*id=["\']$groupId["\'][^>]*>[\\s\\S]*?</g>', caseSensitive: false),
        '',
      );
    }

    return _extractPathDs(content);
  }

  /// Extract path d attributes from SVG content.
  List<String> _extractPathDs(String content) {
    final paths = <String>[];
    final pathPattern = RegExp('<path[^>]+d=["\']([^"\']+)["\']', caseSensitive: false);
    final matches = pathPattern.allMatches(content);

    for (final match in matches) {
      final d = match.group(1);
      if (d != null && d.trim().isNotEmpty) {
        paths.add(d.trim());
      }
    }

    return paths;
  }

  /// Extract metadata from SVG data attributes.
  Map<String, String> extractMetadata(String svgContent) {
    final metadata = <String, String>{};

    // Extract data-lao-* attributes from the root <svg> element
    final svgPattern = RegExp(r'<svg[^>]*>', caseSensitive: false);
    final svgMatch = svgPattern.firstMatch(svgContent);

    if (svgMatch != null) {
      final svgTag = svgMatch.group(0) ?? '';
      final attrPattern = RegExp('data-lao-([a-z-]+)=["\']([^"\']+)["\']', caseSensitive: false);
      final attrMatches = attrPattern.allMatches(svgTag);

      for (final attrMatch in attrMatches) {
        final key = attrMatch.group(1) ?? '';
        final value = attrMatch.group(2) ?? '';
        metadata[key] = value;
      }
    }

    return metadata;
  }
}

/// Compute direction hint for a stroke based on its points.
String computeDirectionHint(List<Point<double>> points) {
  if (points.length < 2) return 'unknown';

  // Compute start to end angle
  final startAngle = PathUtils.angleBetween(points.first, points.last);

  // Compute total turning (sum of angle changes)
  var totalTurning = 0.0;
  for (var i = 1; i < points.length - 1; i++) {
    final angle1 = PathUtils.angleBetween(points[i - 1], points[i]);
    final angle2 = PathUtils.angleBetween(points[i], points[i + 1]);
    totalTurning += PathUtils.angleDifference(angle1, angle2);
  }

  // Determine direction based on turning
  if (totalTurning > 270) {
    // Significant turning - could be clockwise or counterclockwise
    return totalTurning > 400 ? 'clockwise' : 'counterclockwise';
  }

  // Determine based on start→end angle
  if (startAngle >= 337.5 || startAngle < 22.5) {
    return 'right';
  } else if (startAngle >= 22.5 && startAngle < 67.5) {
    return 'down-right';
  } else if (startAngle >= 67.5 && startAngle < 112.5) {
    return 'down';
  } else if (startAngle >= 112.5 && startAngle < 157.5) {
    return 'down-left';
  } else if (startAngle >= 157.5 && startAngle < 202.5) {
    return 'left';
  } else if (startAngle >= 202.5 && startAngle < 247.5) {
    return 'up-left';
  } else if (startAngle >= 247.5 && startAngle < 292.5) {
    return 'up';
  } else {
    return 'up-right';
  }
}

/// Compute start angle in degrees (0=right, 90=down in screen coordinates).
double computeStartAngle(List<Point<double>> points) {
  if (points.length < 2) return 0.0;
  // Return angle from first to second point
  return PathUtils.angleBetween(points[0], points[1]);
}
