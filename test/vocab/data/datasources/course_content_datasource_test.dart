import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/datasources/course_content_datasource.dart';

import '../../fixtures/course_fixtures.dart';

CourseContentDataSource _make({
  required String json,
  required Set<String> existingAssetPaths,
  String coursePath = 'assets/vocab/course.json',
}) {
  return CourseContentDataSource(
    coursePath: coursePath,
    loadString: (path) async {
      if (path == coursePath) return json;
      throw Exception('Unexpected loadString call: $path');
    },
    assetExists: (path) async => existingAssetPaths.contains(path),
  );
}

void main() {
  group('CourseContentDataSource', () {
    test('parses a valid bundle', () async {
      final ds = _make(
        json: validBundleJson,
        existingAssetPaths: validBundleAssetPaths,
      );
      final content = await ds.load();
      expect(content.units, hasLength(2));
      expect(content.lessons, hasLength(3));
      expect(content.words, hasLength(10));
      expect(content.units.first.unitId, 'u_01');
      expect(content.words.first.wordId, 'w_0001');
      expect(
        content.words.first.examples.first.translations['en'],
        contains('test sentence'),
      );
    });

    test('rejects bundle with dangling word reference', () async {
      final ds = _make(
        json: bundleWithDanglingWordJson,
        existingAssetPaths: validBundleAssetPaths,
      );
      await expectLater(
        ds.load(),
        throwsA(
          isA<CourseValidationException>().having(
            (e) => e.errors.join(' '),
            'errors',
            contains('w_does_not_exist'),
          ),
        ),
      );
    });

    test('rejects bundle whose image_path is not present in the asset set',
        () async {
      final ds = _make(
        json: bundleWithMissingImageJson,
        existingAssetPaths: validBundleAssetPaths,
      );
      await expectLater(
        ds.load(),
        throwsA(
          isA<CourseValidationException>().having(
            (e) => e.errors.join(' '),
            'errors',
            contains('does_not_exist.webp'),
          ),
        ),
      );
    });

    test('rejects bundle with invalid character type', () async {
      final ds = _make(
        json: bundleWithInvalidCharTypeJson,
        existingAssetPaths: validBundleAssetPaths,
      );
      // json_serializable throws when an enum value isn't recognized; we
      // accept any thrown exception here since the contract is "fail loud".
      await expectLater(ds.load(), throwsA(anything));
    });
  });
}
