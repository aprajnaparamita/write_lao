import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_lao/vocab/data/repositories/course_repository.dart';

import '../../fixtures/course_fixtures.dart';

Future<CourseRepository> _loadFixtureRepo() async {
  final ds = CourseContentDataSource(
    loadString: (_) async => validBundleJson,
    assetExists: (path) async => validBundleAssetPaths.contains(path),
  );
  return CourseRepository(await ds.load());
}

void main() {
  group('CourseRepository', () {
    test('getWordsInUnit returns words across all lessons in the unit',
        () async {
      final repo = await _loadFixtureRepo();
      // u_01 has lessons l_01_01 (3 new) + l_01_02 (3 new + 2 review).
      // Deduped union: w_0001..w_0006 (review words for l_01_02 are w_0001
      // and w_0002, already counted).
      final words = repo.getWordsInUnit('u_01').map((w) => w.wordId).toList();
      expect(
        words,
        equals([
          'w_0001',
          'w_0002',
          'w_0003',
          'w_0004',
          'w_0005',
          'w_0006',
        ]),
      );
    });

    test('getWordsIntroducedBefore scopes by canonical lesson order',
        () async {
      final repo = await _loadFixtureRepo();
      // Lesson order: l_01_01, l_01_02, l_02_01.
      // Before l_01_01 → nothing introduced yet.
      expect(repo.getWordsIntroducedBefore('l_01_01'), isEmpty);
      // Before l_01_02 → l_01_01's new words (w_0001..w_0003).
      final beforeL2 = repo
          .getWordsIntroducedBefore('l_01_02')
          .map((w) => w.wordId)
          .toList();
      expect(beforeL2, equals(['w_0001', 'w_0002', 'w_0003']));
      // Before l_02_01 → l_01_01 + l_01_02's new words. Review words from
      // l_01_02 (w_0001/w_0002) are NOT considered first introductions.
      final beforeU2 = repo
          .getWordsIntroducedBefore('l_02_01')
          .map((w) => w.wordId)
          .toList();
      expect(
        beforeU2,
        equals([
          'w_0001',
          'w_0002',
          'w_0003',
          'w_0004',
          'w_0005',
          'w_0006',
        ]),
      );
    });

    test('lookups return null for unknown ids', () async {
      final repo = await _loadFixtureRepo();
      expect(repo.getUnit('u_does_not_exist'), isNull);
      expect(repo.getLesson('l_does_not_exist'), isNull);
      expect(repo.getWord('w_does_not_exist'), isNull);
    });

    test('getAllUnits preserves declared order', () async {
      final repo = await _loadFixtureRepo();
      expect(repo.getAllUnits().map((u) => u.unitId), ['u_01', 'u_02']);
    });
  });
}
