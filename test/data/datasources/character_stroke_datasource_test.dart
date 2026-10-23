import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:write_lao/data/datasources/character_stroke_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CharacterStrokeDataSource', () {
    late CharacterStrokeDataSource dataSource;

    setUp(() {
      dataSource = CharacterStrokeDataSource();
    });

    tearDown(() {
      dataSource.clearCache();
    });

    test('handles different codepoint formats consistently', () async {
      // Set up a mock that returns valid JSON for all assets
      const strokeJson = '''
      {
        "codepoint": "U+0E81",
        "char": "A",
        "strokeCount": 1,
        "strokes": [
          {
            "index": 0,
            "points": [[100.0, 100.0], [200.0, 200.0]],
            "startAngle": 45.0,
            "direction": "down-right"
          }
        ],
        "canvasSize": 512
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final encoded = utf8.encode(strokeJson);
          return ByteData.sublistView(Uint8List.fromList(encoded));
        },
      );

      // Load the same asset with different formats
      final result1 = await dataSource.loadStrokeData('U+0E81');
      final result2 = await dataSource.loadStrokeData('0E81');
      final result3 = await dataSource.loadStrokeData('0e81');

      // All should return valid stroke data
      expect(result1, isNotNull);
      expect(result1!.strokeCount, 1);

      // The second and third calls should hit the cache
      expect(result2, isNotNull);
      expect(result3, isNotNull);
    });

    test('returns null for character with strokeCount 0', () async {
      const strokeJson = '''
      {
        "codepoint": "U+0E82",
        "char": "B",
        "strokeCount": 0,
        "strokes": [],
        "canvasSize": 512
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final encoded = utf8.encode(strokeJson);
          return ByteData.sublistView(Uint8List.fromList(encoded));
        },
      );

      final result = await dataSource.loadStrokeData('U+0E82');
      expect(result, isNull);
    });

    test('clearCache removes all cached data', () async {
      const strokeJson = '''
      {
        "codepoint": "U+0E81",
        "char": "A",
        "strokeCount": 1,
        "strokes": [{"index": 0, "points": [[0,0]], "startAngle": 0, "direction": "right"}],
        "canvasSize": 512
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final encoded = utf8.encode(strokeJson);
          return ByteData.sublistView(Uint8List.fromList(encoded));
        },
      );

      await dataSource.loadStrokeData('U+0E81');
      expect(dataSource.hasStrokeData('U+0E81'), true);

      dataSource.clearCache();
      expect(dataSource.hasStrokeData('U+0E81'), false);
    });

    test('hasStrokeData returns true after loading', () async {
      const strokeJson = '''
      {
        "codepoint": "U+0E81",
        "char": "A",
        "strokeCount": 1,
        "strokes": [{"index": 0, "points": [[0,0]], "startAngle": 0, "direction": "right"}],
        "canvasSize": 512
      }
      ''';

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final encoded = utf8.encode(strokeJson);
          return ByteData.sublistView(Uint8List.fromList(encoded));
        },
      );

      // Before loading, should return false (not in cache)
      expect(dataSource.hasStrokeData('U+0E81'), false);

      // After loading, should return true
      await dataSource.loadStrokeData('U+0E81');
      expect(dataSource.hasStrokeData('U+0E81'), true);
    });
  });
}
