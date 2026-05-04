import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/course_navigation.dart';

import '../fixtures/course_fixtures.dart';

Future<CourseRepository> _loadFixtureRepo() async {
  final ds = CourseContentDataSource(
    loadString: (_) async => validBundleJson,
    assetExists: (path) async => validBundleAssetPaths.contains(path),
  );
  return CourseRepository(await ds.load());
}

UserVocabProgress _progress({
  String? currentUnitId,
  String? currentLessonId,
  bool iapUnlocked = true,
}) {
  final t = DateTime.utc(2026, 1, 1);
  return UserVocabProgress(
    id: 'progress',
    currentUnitId: currentUnitId,
    currentLessonId: currentLessonId,
    iapUnlocked: iapUnlocked,
    createdAt: t,
    updatedAt: t,
  );
}

UserWord _userWord(String id, WordStatus status) {
  final t = DateTime.utc(2026, 1, 1);
  return UserWord(
    id: 'uuid-$id',
    wordId: id,
    status: status,
    createdAt: t,
    updatedAt: t,
  );
}

void main() {
  late CourseRepository course;

  setUp(() async {
    course = await _loadFixtureRepo();
  });

  group('iap-locked', () {
    test('unit 1 is free, unit 2+ are locked when iapUnlocked is false', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_01',
          iapUnlocked: false,
        ),
      );
      expect(nav.isUnitUnlocked('u_01'), isTrue);
      expect(nav.isUnitUnlocked('u_02'), isFalse);
      expect(nav.isLessonUnlocked('l_01_01'), isTrue);
    });
  });

  group('unit gating (iap unlocked)', () {
    test('unit 1 is unlocked when iap is unlocked', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_01',
        ),
      );
      expect(nav.isUnitUnlocked('u_01'), isTrue);
    });

    test('unit 2 is locked while u_01 is in progress', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_02',
        ),
      );
      expect(nav.isUnitUnlocked('u_02'), isFalse);
    });

    test('unit 2 unlocks once every lesson in u_01 is complete', () {
      final nav = CourseNavigation(
        course: course,
        // u_01 has lessons [l_01_01, l_01_02]; both come before l_02_01
        // canonically, so being on l_02_01 means u_01 is done.
        progress: _progress(
          currentUnitId: 'u_02',
          currentLessonId: 'l_02_01',
        ),
      );
      expect(nav.isUnitComplete('u_01'), isTrue);
      expect(nav.isUnitUnlocked('u_02'), isTrue);
    });
  });

  group('lesson gating', () {
    test('lesson 1 of unit 1 is unlocked at the start of the course', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_01',
        ),
      );
      expect(nav.isLessonUnlocked('l_01_01'), isTrue);
    });

    test('lesson 2 is locked until lesson 1 is complete', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_01',
        ),
      );
      expect(nav.isLessonUnlocked('l_01_02'), isFalse);
    });

    test('lesson 2 unlocks once lesson 1 is complete', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_02',
        ),
      );
      expect(nav.isLessonComplete('l_01_01'), isTrue);
      expect(nav.isLessonUnlocked('l_01_02'), isTrue);
    });

    test('completed lessons remain "unlocked" for re-study', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_02',
          currentLessonId: 'l_02_01',
        ),
      );
      expect(nav.isLessonComplete('l_01_01'), isTrue);
      expect(nav.isLessonUnlocked('l_01_01'), isTrue);
    });

    test('lessons in a locked unit are reported as locked', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_01',
        ),
      );
      // u_02 is locked while u_01 is in progress.
      expect(nav.isLessonUnlocked('l_02_01'), isFalse);
    });
  });

  group('progress counters', () {
    test('completedLessonCount reports lessons before currentLessonId', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_02',
        ),
      );
      expect(nav.completedLessonCount('u_01'), 1);
      expect(nav.totalLessonCount('u_01'), 2);
    });

    test('isCourseComplete is true when currentLessonId is null', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(),
      );
      expect(nav.isCourseComplete, isTrue);
      expect(nav.isLessonComplete('l_01_01'), isTrue);
      expect(nav.isUnitComplete('u_01'), isTrue);
    });

    test('isCurrentLesson identifies the next-up lesson', () {
      final nav = CourseNavigation(
        course: course,
        progress: _progress(
          currentUnitId: 'u_01',
          currentLessonId: 'l_01_02',
        ),
      );
      expect(nav.isCurrentLesson('l_01_02'), isTrue);
      expect(nav.isCurrentLesson('l_01_01'), isFalse);
    });
  });

  group('masteredWordCount', () {
    test('counts mature and retired words', () {
      final words = [
        _userWord('a', WordStatus.newWord),
        _userWord('b', WordStatus.learning),
        _userWord('c', WordStatus.reviewing),
        _userWord('d', WordStatus.mature),
        _userWord('e', WordStatus.mature),
        _userWord('f', WordStatus.retired),
      ];
      expect(masteredWordCount(words), 3);
    });

    test('returns 0 for an empty pool', () {
      expect(masteredWordCount(const []), 0);
    });
  });
}
