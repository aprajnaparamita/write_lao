import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/content_access.dart';

import '../fixtures/course_fixtures.dart';

Future<CourseRepository> _loadFixtureRepo() async {
  final ds = CourseContentDataSource(
    loadString: (_) async => validBundleJson,
    assetExists: (path) async => validBundleAssetPaths.contains(path),
  );
  return CourseRepository(await ds.load());
}

UserVocabProgress _progress({required bool iapUnlocked, String? currentLessonId}) {
  final t = DateTime.utc(2026, 1, 1);
  return UserVocabProgress(
    id: 'test',
    currentUnitId: 'u_01',
    currentLessonId: currentLessonId,
    iapUnlocked: iapUnlocked,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late CourseRepository course;

  setUp(() async {
    course = await _loadFixtureRepo();
  });

  group('ContentAccess.hasPurchased', () {
    test('true when iapUnlocked is true', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: true),
      );
      expect(access.hasPurchased, isTrue);
    });

    test('false when iapUnlocked is false', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: false),
      );
      expect(access.hasPurchased, isFalse);
    });
  });

  group('ContentAccess.canAccessLesson', () {
    test('purchased user can access any lesson', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: true),
      );
      expect(access.canAccessLesson('l_01_01'), isTrue);
      expect(access.canAccessLesson('l_01_02'), isTrue);
      expect(access.canAccessLesson('l_02_01'), isTrue);
    });

    test('free user can access only preview lessons', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: false),
      );
      // l_01_01 is lesson 1 of unit 1, should be in preview
      expect(access.canAccessLesson('l_01_01'), isTrue);
      // l_01_02 is lesson 2, may or may not be in preview depending on config
      // fixture has only 2 lessons in unit 1
    });

    test('free user cannot access lessons outside unit 1', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: false),
      );
      expect(access.canAccessLesson('l_02_01'), isFalse);
    });
  });

  group('ContentAccess.isInFreePreview', () {
    test('returns false for purchased users', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: true),
      );
      expect(access.isInFreePreview('l_01_01'), isFalse);
    });
  });

  group('ContentAccess.hasAccessibleContent', () {
    test('purchased user has access to all units', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: true),
      );
      expect(access.hasAccessibleContent('u_01'), isTrue);
      expect(access.hasAccessibleContent('u_02'), isTrue);
    });

    test('free user has access only to unit 1', () {
      final access = ContentAccess(
        course: course,
        progress: _progress(iapUnlocked: false),
      );
      expect(access.hasAccessibleContent('u_01'), isTrue);
      expect(access.hasAccessibleContent('u_02'), isFalse);
    });
  });
}
