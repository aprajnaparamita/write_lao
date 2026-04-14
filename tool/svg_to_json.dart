#!/usr/bin/env dart
// SVG to JSON Converter Tool
//
// Converts SVG stroke files to JSON format for the Write Lao app.
//
// Usage:
//   dart run tool/svg_to_json.dart input.svg -o output.json
//   dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/
//
// Options:
//   --resample N     Resample to N points per stroke (default: 48)
//   --canvas-size N  Reference canvas size (default: 512)
//   --min-length N   Minimum stroke length in px to include (default: 20)
//   --verbose        Print details about each stroke found

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Simple Point class for CLI tool (doesn't depend on Flutter)
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  @override
  String toString() => 'Point($x, $y)';
}

/// Path utilities for CLI tool (pure Dart version)
class PathUtils {
  /// Euclidean distance between two points.
  static double distance(Point a, Point b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Angle in degrees from point a to point b.
  /// 0=right, 90=down, 180=left, 270=up (screen coordinates).
  static double angleBetween(Point a, Point b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    var angle = atan2(dy, dx) * 180.0 / pi;
    if (angle < 0) angle += 360.0;
    return angle;
  }

  /// Smallest angular difference between two angles in degrees (0-180).
  static double angleDifference(double a, double b) {
    var diff = (a - b).abs() % 360;
    if (diff > 180) diff = 360 - diff;
    return diff;
  }
}

/// Compute direction hint for a stroke based on its points.
String computeDirectionHint(List<Point> points) {
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
double computeStartAngle(List<Point> points) {
  if (points.length < 2) return 0.0;
  // Return angle from first to second point
  return PathUtils.angleBetween(points[0], points[1]);
}

/// Parse an SVG path d-attribute string into a list of point lists.
class SvgPathParser {
  List<List<Point>> parse(String pathData, {int curveResolution = 20}) {
    if (pathData.isEmpty) return [];

    final commands = _tokenizeCommands(pathData);
    final subPaths = <List<Point>>[];
    var currentPath = <Point>[];
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
              currentPath = <Point>[];
            }

            currentPath.add(Point(x, y));
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
            currentPath.add(Point(x, y));
            currentX = x;
            currentY = y;
            lastControlX = x;
            lastControlY = y;
          }
          break;

        case 'H':
          for (final x in args) {
            final px = isRelative ? currentX + x : x;
            currentPath.add(Point(px, currentY));
            currentX = px;
            lastControlX = px;
            lastControlY = currentY;
          }
          break;

        case 'V':
          for (final y in args) {
            final py = isRelative ? currentY + y : y;
            currentPath.add(Point(currentX, py));
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
              Point(currentX, currentY),
              Point(x1, y1),
              Point(x2, y2),
              Point(x, y),
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

            var x1 = currentX;
            var y1 = currentY;
            if (cmdUpper == 'S' && (lastCommand == 'C' || lastCommand == 'S')) {
              x1 = 2 * currentX - lastControlX;
              y1 = 2 * currentY - lastControlY;
            }

            final samples = _sampleCubicBezier(
              Point(currentX, currentY),
              Point(x1, y1),
              Point(x2, y2),
              Point(x, y),
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
              Point(currentX, currentY),
              Point(x1, y1),
              Point(x, y),
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
            currentPath.add(Point(startX, startY));
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

  List<Map<String, dynamic>> _tokenizeCommands(String pathData) {
    final commands = <Map<String, dynamic>>[];

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
        commands.add({'command': text, 'args': <double>[]});
        lastCommand = text;
        i++;

        if (text.toUpperCase() == 'M') {
          implicitRepeatCount = 2;
        }
      } else if (lastCommand != null) {
        final value = double.tryParse(text);
        if (value != null) {
          final currentCmd = commands.last;
          final existingArgs = currentCmd['args'] as List<double>;
          currentCmd['args'] = [...existingArgs, value];

          final cmdUpper = lastCommand.toUpperCase();
          if (cmdUpper == 'M') {
            implicitRepeatCount = (implicitRepeatCount ?? 2) - 1;
            if (implicitRepeatCount == 0 && i + 1 < matches.length) {
              final nextMatch = matches.elementAt(i + 1);
              final nextText = nextMatch.group(0)!;
              if (!RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(nextText)) {
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
        i++;
      }
    }

    return commands;
  }

  List<Point> _sampleCubicBezier(
    Point p0,
    Point p1,
    Point p2,
    Point p3,
    int n,
  ) {
    final points = <Point>[];
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      final mt = 1 - t;
      final mt2 = mt * mt;
      final mt3 = mt2 * mt;
      final t2 = t * t;
      final t3 = t2 * t;

      final x = mt3 * p0.x + 3 * mt2 * t * p1.x + 3 * mt * t2 * p2.x + t3 * p3.x;
      final y = mt3 * p0.y + 3 * mt2 * t * p1.y + 3 * mt * t2 * p2.y + t3 * p3.y;
      points.add(Point(x, y));
    }
    return points;
  }

  List<Point> _sampleQuadraticBezier(
    Point p0,
    Point p1,
    Point p2,
    int n,
  ) {
    final points = <Point>[];
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      final mt = 1 - t;

      final x = mt * mt * p0.x + 2 * mt * t * p1.x + t * t * p2.x;
      final y = mt * mt * p0.y + 2 * mt * t * p1.y + t * t * p2.y;
      points.add(Point(x, y));
    }
    return points;
  }
}

/// Parse an SVG file and extract stroke paths.
class SvgFileParser {
  final SvgPathParser _pathParser = SvgPathParser();

  List<List<Point>> parseFile(String svgContent, {int curveResolution = 20}) {
    var paths = _extractPathsFromGroup(svgContent, 'strokes');

    if (paths.isEmpty) {
      paths = _extractAllPaths(svgContent);
    }

    final result = <List<Point>>[];
    for (final pathD in paths) {
      final subPaths = _pathParser.parse(pathD, curveResolution: curveResolution);
      result.addAll(subPaths);
    }

    return result;
  }

  List<String> _extractPathsFromGroup(String svg, String groupId) {
    final paths = <String>[];

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

  List<String> _extractAllPaths(String svg) {
    var content = svg;

    for (final groupId in ['background', 'reference', 'label', 'defs', 'metadata']) {
      content = content.replaceAll(
        RegExp('<g[^>]*id=["\']$groupId["\'][^>]*>[\\s\\S]*?</g>', caseSensitive: false),
        '',
      );
    }

    return _extractPathDs(content);
  }

  List<String> _extractPathDs(String content) {
    final paths = <String>[];
    final pathPattern = RegExp(r'<path[^>]+\sd=["\x27]([^"\x27]+)["\x27]', caseSensitive: false);
    final matches = pathPattern.allMatches(content);

    for (final match in matches) {
      final d = match.group(1);
      if (d != null && d.trim().isNotEmpty) {
        paths.add(d.trim());
      }
    }

    return paths;
  }

  Map<String, String> extractMetadata(String svgContent) {
    final metadata = <String, String>{};

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

/// Resample a list of points to exactly [targetCount] evenly-spaced points.
class PointResampler {
  List<Point> resample(List<Point> rawPoints, int targetCount) {
    if (rawPoints.length < 2 || targetCount < 2) return [];

    final totalLen = _pathLength(rawPoints);
    if (totalLen == 0) {
      return List.filled(targetCount, rawPoints.first);
    }

    final spacing = totalLen / (targetCount - 1);
    final result = <Point>[rawPoints.first];
    var currentPos = 0;
    var distanceAlongPath = 0.0;
    var exhausted = false;

    while (result.length < targetCount && !exhausted) {
      final targetDistance = result.length * spacing;
      var placed = false;

      while (currentPos + 1 < rawPoints.length) {
        final segLen = PathUtils.distance(rawPoints[currentPos], rawPoints[currentPos + 1]);

        if (distanceAlongPath + segLen >= targetDistance) {
          final t = (targetDistance - distanceAlongPath) / segLen;
          final nx = rawPoints[currentPos].x + t * (rawPoints[currentPos + 1].x - rawPoints[currentPos].x);
          final ny = rawPoints[currentPos].y + t * (rawPoints[currentPos + 1].y - rawPoints[currentPos].y);
          result.add(Point(nx, ny));
          distanceAlongPath = targetDistance;
          placed = true;
          break;
        } else {
          distanceAlongPath += segLen;
          currentPos++;
        }
      }

      if (!placed) {
        exhausted = true;
      }
    }

    while (result.length < targetCount) {
      result.add(rawPoints.last);
    }

    return result;
  }

  double _pathLength(List<Point> points) {
    if (points.length < 2) return 0.0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += PathUtils.distance(points[i - 1], points[i]);
    }
    return total;
  }
}

class ConversionOptions {
  int resamplePoints;
  int canvasSize;
  double minLength;
  bool verbose;

  ConversionOptions({
    this.resamplePoints = 48,
    this.canvasSize = 512,
    this.minLength = 20.0,
    this.verbose = false,
  });
}

void main(List<String> args) async {
  if (args.isEmpty) {
    printUsage();
    exit(1);
  }

  final options = ConversionOptions();
  String? inputPath;
  String? outputPath;

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '-h':
      case '--help':
        printUsage();
        exit(0);
      case '-o':
      case '--output':
        if (i + 1 < args.length) {
          outputPath = args[++i];
        }
        break;
      case '--resample':
        if (i + 1 < args.length) {
          options.resamplePoints = int.tryParse(args[++i]) ?? 48;
        }
        break;
      case '--canvas-size':
        if (i + 1 < args.length) {
          options.canvasSize = int.tryParse(args[++i]) ?? 512;
        }
        break;
      case '--min-length':
        if (i + 1 < args.length) {
          options.minLength = double.tryParse(args[++i]) ?? 20.0;
        }
        break;
      case '--verbose':
      case '-v':
        options.verbose = true;
        break;
      default:
        if (!arg.startsWith('-')) {
          inputPath = arg;
        }
    }
  }

  if (inputPath == null) {
    print('Error: No input path specified');
    printUsage();
    exit(1);
  }

  if (outputPath == null) {
    print('Error: No output path specified (-o)');
    printUsage();
    exit(1);
  }

  final input = Directory(inputPath);
  if (input.existsSync()) {
    await processDirectory(inputPath, outputPath, options);
  } else {
    final file = File(inputPath);
    if (!file.existsSync()) {
      print('Error: File not found: $inputPath');
      exit(1);
    }
    await processFile(inputPath, outputPath, options);
  }
}

void printUsage() {
  print('''
SVG to JSON Converter for Write Lao

Usage:
  dart run tool/svg_to_json.dart <input> -o <output> [options]

Arguments:
  <input>              SVG file or directory of SVG files
  -o, --output <path>  Output file or directory

Options:
  --resample N         Resample to N points per stroke (default: 48)
  --canvas-size N      Reference canvas size (default: 512)
  --min-length N       Minimum stroke length in px (default: 20)
  --verbose, -v       Print details about each stroke found
  -h, --help          Show this help message

Examples:
  dart run tool/svg_to_json.dart input.svg -o output.json
  dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/
  dart run tool/svg_to_json.dart input.svg -o output.json --resample 32 --verbose
''');
}

Future<void> processDirectory(String inputDir, String outputDir, ConversionOptions options) async {
  final dir = Directory(inputDir);
  final outDir = Directory(outputDir);

  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final svgFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.svg'))
      .toList();

  if (svgFiles.isEmpty) {
    print('No SVG files found in $inputDir');
    return;
  }

  print('Found ${svgFiles.length} SVG file(s)');

  for (final svgFile in svgFiles) {
    final basename = path.basenameWithoutExtension(svgFile.path);
    final outputFile = path.join(outputDir, '$basename.json');

    if (options.verbose) {
      print('\nProcessing: ${svgFile.path}');
    }

    try {
      await processFile(svgFile.path, outputFile, options);
    } catch (e) {
      print('Error processing ${svgFile.path}: $e');
    }
  }

  print('\nProcessed ${svgFiles.length} file(s)');
}

Future<void> processFile(String inputPath, String outputPath, ConversionOptions options) async {
  final svgContent = await File(inputPath).readAsString();
  final parser = SvgFileParser();

  final metadata = parser.extractMetadata(svgContent);
  final codepoint = metadata['codepoint'] ?? 'UNKNOWN';
  final char = metadata['char'] ?? '';
  final name = metadata['name'] ?? '';
  final romanization = metadata['romanization'] ?? '';
  final phase = metadata['phase'] ?? '1';
  final order = metadata['order'] ?? '1';
  final notes = metadata['notes'] ?? '';

  final rawStrokes = parser.parseFile(svgContent);

  if (options.verbose) {
    print('  Found ${rawStrokes.length} raw stroke path(s)');
  }

  final strokes = <Map<String, dynamic>>[];
  var strokeIndex = 0;

  for (var i = 0; i < rawStrokes.length; i++) {
    final rawPoints = rawStrokes[i];

    if (rawPoints.length < 2) {
      if (options.verbose) {
        print('  Stroke $strokeIndex: Skipped (too few points: ${rawPoints.length})');
      }
      continue;
    }

    final length = _calculatePathLength(rawPoints);

    if (length < options.minLength) {
      if (options.verbose) {
        print('  Stroke $strokeIndex: Skipped (length ${length.toStringAsFixed(1)} < ${options.minLength})');
      }
      continue;
    }

    final resampler = PointResampler();
    final resampled = resampler.resample(rawPoints, options.resamplePoints);

    final startAngle = computeStartAngle(resampled);
    final direction = computeDirectionHint(resampled);

    final points = resampled.map((p) => [p.x, p.y]).toList();

    strokes.add({
      'index': strokeIndex,
      'points': points,
      'startAngle': startAngle,
      'direction': direction,
    });

    if (options.verbose) {
      print('  Stroke $strokeIndex: ${points.length} points, start=${startAngle.toStringAsFixed(1)}°, direction=$direction');
    }

    strokeIndex++;
  }

  final output = {
    'codepoint': codepoint,
    'char': char,
    'name': name,
    'romanization': romanization,
    'phase': int.tryParse(phase) ?? 1,
    'order': int.tryParse(order) ?? 1,
    'notes': notes,
    'strokeCount': strokes.length,
    'strokes': strokes,
    'viewBox': [0, 0, options.canvasSize, options.canvasSize],
  };

  final encoder = const JsonEncoder.withIndent('  ');
  final jsonString = encoder.convert(output);
  await File(outputPath).writeAsString(jsonString);

  if (options.verbose) {
    print('  Wrote: $outputPath');
  } else {
    print('${path.basename(outputPath)}: $codepoint ($char), ${strokes.length} strokes');
  }
}

double _calculatePathLength(List<Point> points) {
  if (points.length < 2) return 0.0;
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    final dx = points[i].x - points[i - 1].x;
    final dy = points[i].y - points[i - 1].y;
    total += sqrt(dx * dx + dy * dy);
  }
  return total;
}
